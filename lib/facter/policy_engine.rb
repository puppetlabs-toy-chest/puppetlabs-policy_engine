require 'yaml'
require 'json'

def policy_fact_config
  unless File.exists?('/etc/puppet/policy.yaml')
    @config = Hash.new
    @config['test_directory'] = "#{Puppet[:vardir]}/policies"
  end

  @config ||= YAML.load_file('/etc/puppet/policy.yaml')
end

def tests
  return @tests if @tests

  @tests = Array.new

  Dir["#{policy_fact_config['test_directory']}/*"].each do |test_file|
    name = File.basename(test_file).split('.').first
    config = YAML.load_file("/etc/puppet/policies/#{name}.yaml")

    @tests << {'name' => name, 'config' => config, 'location' => test_file}
  end

  @tests
end

def parse_output(options)
  format = options[:format]
  output = options[:output]

  case format
  when 'string'
    output
  when 'yaml'
    YAML::load output
  when 'json'
    JSON::parse output
  end
end

def process_result(options)
  expectation = options[:expectation]
  result = options[:result]

  processed_result = Hash.new

  if result == expectation
    processed_result['result'] = 'pass'
  else
    processed_result['result'] = 'fail'
    processed_result['is'] = result
    processed_result['expected_output'] = expectation
  end
  processed_result
end

def apply_tags(options)
  tags = [*options[:tags]]
  result = options[:result]

  result['tags'] = tags
  result
end

tests.each do |test|
  Facter.add(test['name']) do
    test['config']['confine'].each do |fact,value|
      confine fact.to_sym => value
    end

    setcode do
      test_execution = "#{test['config']['interpreter']} #{test['location']} 2> /dev/null"
      execution_output = Facter::Core::Execution.execute(test_execution)

      execution_result = parse_output :format => test['config']['expect_format'], :output => execution_output

      result = process_result :expectation => test['config']['expect_stdout'], :result => execution_result

      apply_tags :tags => test['config']['tag'], :result => result
    end
  end
end
