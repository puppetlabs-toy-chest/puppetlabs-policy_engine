Given(/^a bash command that lists files in \/opt$/) do
  @command = 'ls /opt'

end

Given(/^the \/opt directory is empty$/) do
  shell 'rm -rf /opt/*'
end

Given(/^the expected output is empty$/) do
  @expected_output = ''
end

When(/^I run the test$/) do
  @test_result = fact(@test_name)
end

Given(/^the \/opt directory is not empty$/) do
  shell('touch /opt/test')
end

Given(/^the expected output isn't empty$/) do
  @expected_output = /^(?!\s*$).+/
end

Given(/^a ruby script that lists all package resources$/) do
    pending # express the regexp above with the code you wish you had
end

Given(/^a policy test should exist$/) do
    pending # express the regexp above with the code you wish you had
end

Given(/^a policy test shouldn't exist$/) do
  @ensure = 'absent'
end

Then(/^the test should exist$/) do
  @ensure = 'present'
end

Then(/^the test shouldn't exist$/) do
  @test_result.should eq(nil)
end
