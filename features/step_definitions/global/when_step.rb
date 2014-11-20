When(/^puppet runs$/) do
  generate_manifest
  @run_result = apply_manifest(@manifest, {:catch_failures => true})
end

When(/^puppet runs on the \s+$/) do |role|
  generate_manifest
  @run_result = apply_manifest_on role, @manifest
end

When(/^the test is run$/) do
  #Make sure pluginsync as occured
  pluginsync
  
  evaluate = shell("facter -p #{@test_name}").stdout.chomp
  @test_result = eval(evaluate)
end
