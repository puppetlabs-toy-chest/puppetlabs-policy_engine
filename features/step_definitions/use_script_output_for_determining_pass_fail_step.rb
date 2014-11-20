Given(/^the expectation is the script output returns (a|an) (.*) (string|array|hash)$/) do |throw_away, state, expectation|
  object = case expectation
           when 'string'
             state == 'non empty' ? "not empty" : String.new
           when 'array'
             state == 'non empty' ? ['not','empty'] : Array.new
           when 'hash'
             state == 'non empty' ? {'not' => 'empty'} : Hash.new
           end

  @expectated_output = object
end

Given(/^the expectation is the script output returns '(.*)'$/) do |expected_stdout|
  @expected_output = expected_stdout
end

Given(/^the expectation is the script output returns (a|an) (string|array|hash) containing (.*)$/) do |throw_away, object, content|
  content = eval(content)

  object = case object
           when 'string'
             String(content)
           when 'array'
             Array(content)
           when 'hash'
             Hash(content)
           end


  @expectated_output = object
end
Given(/^the expected output is [^(one of )](.*)'$/) do |expectation|
  @expected_output = expectation
end

Given(/^the expected output is one of (.*)$/) do |expectation|
  expectation = eval(expectation)
  raise "Expected an array" unless expectation.is_a?(Array)
  @expected_output = expectation
end

Given(/^the expected output matches [^(one of )](.*)$/) do |expectation|
  @expected_output = "/" + expectation
end

Given(/^the expected output matches one of (.*)$/) do |expectation|
  expectation = eval(expectation)
  raise "Expected an array" unless expectation.is_a?(Array)
  @expected_output = expectation
end

Then(/^the expected output should be '(.*)'$/) do |expected_output|
  metadata_content = shell("cat #{policy_engine_config['test_dir']}/metadata/#{@test_name}.yml").stdout.chomp
  config = YAML::load(metadata_content)

  config[:expected_output].should eq(expected_output)
end

Given(/^the expected output on the node is '(.*)'$/) do |output|
  manifest = <<-EOS
  policy_engine::test { "#{@test_name}":
    script => "#{@script}",
    expected_output => "#{output}",
  }
  EOS
  apply_manifest manifest, {:catch_errors => true}
end

Given(/^the expected output on the node matches (.*)$/) do |output|
  manifest = <<-EOS
  policy_engine::test { "#{@test_name}":
    script => "#{@script}",
    expected_output => '#{output}',
  }
  EOS
  apply_manifest manifest, {:catch_errors => true}
end
