Given(/^the policy test (.*) exist on the node$/) do |state|
  @ensure = case state
            when 'should'
              'present'
            when 'shouldn\'t'
              'absent'
            else
              raise "Unknown state #{state}"
            end
end

Then(/^the policy test (should|shouldn't) exist$/) do |state|
  output = shell("facter -p #{@test_name}").stdout

  if state == 'should'
    output.should_not eq("")
  elsif state == "shouldn't"
    output.should eq("\n")
  else
    raise "Unknown state #{state}"
  end
end

Then(/^the script should be '(.*)'$/) do |should_be_content|
  payload_content = shell("cat #{policy_engine_config['test_dir']}/payloads/#{@test_name}").stdout
  
  should_be_content.should eq(payload_content)
end
