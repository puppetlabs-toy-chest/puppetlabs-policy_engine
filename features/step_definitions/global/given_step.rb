Given(/^the policy test exists on the node$/) do
  @ensure = 'present'

  apply_manifest generate_manifest, {:catch_failures => true}

  #For pluginsync
  shell 'puppet agent -t'
end

Given(/^a policy test named '(.*)' is declared$/) do |test_name|
  @test_name = test_name
end
