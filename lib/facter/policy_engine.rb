require 'yaml'
require 'json'
require 'puppet'

def policy_fact_config
  return @config if @config

  # If the fact is called by Facter, we need to initialize Puppet's settings
  # If the fact is called by Puppet, the settings are already initialized and
  # Puppet#initialize_settings throws an exception
  begin
    Puppet.initialize_settings
  rescue
  end

  defaults = {
    'test_dir' => "#{Puppet[:vardir]}/policy_tests"
  }

  cfg = Hash.new

  file = "#{Facter.value(:policy_engine_config_dir)}/config.yml"

  if File.exists?(file)
    cfg = YAML::load( IO.read(file) )
  end

  @config = defaults.merge(cfg)
end

def tests
  return @tests if @tests

  @tests = Array.new

  Dir["#{policy_fact_config['test_dir']}/metadata/*"].each do |test_file|
    name = File.basename(test_file, '.yml')
    payload = "#{policy_fact_config['test_dir']}/payloads/#{name}"

    config = YAML.load_file(test_file)

    @tests << {'name' => name, 'config' => config, 'payload' => payload}
  end

  @tests
end

def parse_output(options)
  format = options[:output_format]
  output = options[:stdout]

  case format
  when 'string'
    output
  when 'yaml'
    YAML::load output
  when 'json'
    JSON::parse output
  else
    warn "Unknown format #{format}"
  end
end

def process_result(options)
  output = options[:output]
  exit_code = options[:exit_code]
  expected_exit_code = options[:expected_exit_code]
  expected_output = options[:expected_output]

  processed_result = Hash.new

  expectations = if expected_exit_code
                   if expected_exit_code.is_a?(String)
                     {:expect => 'expected_exit_code', :expectation => Integer(expected_exit_code), :is => exit_code, :method => :==}
                   elsif expected_exit_code.is_a?(Array)
                     expected_exit_code = expected_exit_code.map { |e| Integer(e) }
                     {:expect => 'expected_exit_code', :expectation => expected_exit_code, :is => exit_code, :method => :include?}
                   end
                 else
                   if expected_output.is_a?(Array)
                     {:expect => 'expected_output', :expectation => expected_output, :is => output, :method => :include?}
                   elsif expected_output.is_a?(String)
                     {:expect => 'expected_output', :expectation => expected_output, :is => output, :method => :==}
                   end
                 end

  if expectations[:expectation].send(expectations[:method], expectations[:is])
    processed_result['result'] = 'pass'
  else
    processed_result['result'] = 'fail'
    processed_result['is'] = expectations[:is]
    processed_result[expectations[:expect]] = expectations[:expectation]
  end

  processed_result
end

def apply_tags(options)
  tags = [*options[:tags]]
  result = options[:result]

  tags << 'policy_engine'

  result['tags'] = tags
  result
end

tests.each do |test|
  Facter.add(test['name']) do
    setcode do
      test_execution = "#{test['config'][:interpreter]} #{test['payload']} 2> /dev/null"
      output = Puppet::Util::Execution.execute(test_execution, :failonfail => false)
      exit_code = output.exitstatus

      execution_result = parse_output :output_format => test['config'][:output_format], :stdout => output

      result = process_result :expected_exit_code => test['config'][:expected_exit_code], 
        :expected_output => test['config'][:expected_output], 
        :output => execution_result, 
        :exit_code => exit_code

      apply_tags :tags => test['config'][:tags], :result => result
    end
  end
end
