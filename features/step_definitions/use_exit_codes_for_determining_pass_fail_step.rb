Given(/^the expectation is the script's exit code returns (\d+)$/) do |exit_code|
  @expected_exit_code = exit_code
end

Given(/^the expectation is the script's exit code returns one of (.*)$/) do |exit_codes|
  exit_code_array = eval(exit_codes)

  unless exit_code_array.is_a?(Array)
    raise 'Specify return codes as arrays. For example: [1,2,4]'
  end

  @expected_exit_code = exit_code_array
end

Given(/^the exit code is (\d+) on the node$/) do |exit_code|
  manifest = <<-EOS
  policy_engine::test { "#{@test_name}":
    script => 'echo hello',
    expected_exit_code => '#{exit_code}',
  }
  EOS
  apply_manifest manifest, {:catch_errors => true}
end

Then(/^the exit code should be (\d+)$/) do |exit_code|
  metadata_content = shell("cat #{policy_engine_config['test_dir']}/metadata/#{@test_name}.yml").stdout.chomp
  config = YAML::load(metadata_content)
  actual_exit_code = begin 
                       Integer(exit_code)
                     rescue ArgumentError
                       Array(exit_code)
                     end

  config[:expected_exit_code].should eq(actual_exit_code)
end
