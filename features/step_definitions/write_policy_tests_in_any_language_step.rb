Given(/^a policy test using the inline script is declared$/) do
  @test_name = 'inline_script'
end

Given(/^a policy test using the external script is declared$/) do
  @test_name = 'external_script'
end

Given(/^the script is '(.*)' on the node$/) do |command|
  manifest = <<-EOS
  policy_engine::test { "#{@test_name}":
    script => '#{command}',
    expected_output => '',
  }
  EOS
  apply_manifest manifest, {:catch_errors => true}
end

Given(/^an inline (.*) script that runs '(.*)'$/) do |interpreter, command|
  if interpreter.empty? or interpreter == 'shell'
    @interpreter = '/bin/sh'
  else
    @interpreter = interpreter
  end

  @script = command
end

Given(/^the (.*) directory is empty$/) do |directory|
  shell "rm -rf #{directory}"
end

Given(/^the (.*) directory is not empty$/) do |directory|
  shell "mkdir -p #{directory}"
  shell "touch #{directory}/not_empty"
end

Given(/^an external ruby script that lists all users on the system$/) do
  content = <<-EOS
  require 'puppet'
  
  begin
    Puppet.initialize_settings
  rescue
  end

  system_packages = Puppet::Type.type(:package).instances
  EOS

  create_remote_file default, "/tmp/external_test", content

  @source = "/tmp/external_test"
  @interpreter = 'ruby'
end

Given(/^an external ruby script that prints '(.*)'$/) do |print_string|
  print_string = print_string.gsub("'","\'")

  content = <<-EOS
  print '#{print_string}'
  EOS

  create_remote_file default, "/tmp/external_test", content

  @source = "/tmp/external_test"
  @interpreter = 'ruby'
end

Then(/^the script should be the external script$/) do
  payload_content = shell("cat #{policy_engine_config['test_dir']}/payloads/#{@test_name}").stdout.chomp
  source_content = shell("cat #{@source}").stdout.chomp

  payload_content.should eq(source_content)
end

