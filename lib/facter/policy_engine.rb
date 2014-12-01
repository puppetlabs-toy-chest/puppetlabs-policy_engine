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

def format_result(result, is, expectation, should)
  if result == 'pass'
    {'result' => result}
  else
    {'result' => result, 'is' => is, expectation => should}
  end
end

def process_exit_code_result(exit_code, expected_exit_code)
  test_result = if expected_exit_code.is_a?(Integer)
                  expected_exit_code == exit_code ? 'pass' : 'fail'
                elsif expected_exit_code.is_a?(Array)
                  expected_exit_code = expected_exit_code.map { |e| Integer(e) }
                  expected_exit_code.include?(exit_code) ? 'pass' : 'fail'
                end

  format_result(test_result, exit_code, 'expected_exit_code', expected_exit_code)
end

def is_regex?(string)
  string[0] == '/' and string[-1] == '/'
end

def parse_regex(regex)
  new_regex = regex.dup
  new_regex[0] = ''
  new_regex[-1] = ''
  Regexp.new(new_regex)
end

def process_output_result(output, expected_output, format)
  test_result = 'fail'

  if format == 'string'
    if expected_output.is_a?(Array)
      expected_output.each do |e|
        if (is_regex?(e) and output =~ parse_regex(e)) or output == e
          test_result = 'pass'
          break
        end
      end
    elsif expected_output.is_a?(String)
      if is_regex?(expected_output)
        test_result = output =~ parse_regex(expected_output) ? 'pass' : 'fail'
      else
        test_result = output == expected_output ? 'pass' : 'fail'
      end
    end
  else
    test_result = output == expected_output ? 'pass' : 'fail'
  end

  format_result(test_result, output, 'expected_output', expected_output)
end

def process_result(options)
  output = options[:output]
  exit_code = options[:exit_code]
  expected_exit_code = options[:expected_exit_code]
  expected_output = options[:expected_output]
  format = options[:format]

  if expected_exit_code
    process_exit_code_result exit_code, expected_exit_code
  elsif expected_output
    process_output_result output, expected_output, format
  end
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
        :exit_code => exit_code,
        :format => test['config'][:output_format]

      apply_tags :tags => test['config'][:tags], :result => result
    end
  end
end
