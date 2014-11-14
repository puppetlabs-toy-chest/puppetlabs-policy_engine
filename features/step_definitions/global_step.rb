When(/^puppet runs$/) do
  apply_manifest @manifest, {:catch_failures => true}
end

Given(/^the test exists$/) do
  @test_name = 'list_files'

  @ensure        = 'present'
  @cmd           = @command || 'undef'
  @expect_output = @expected_output || 'undef'
  @expect_exit   = @expected_exit_code || 'undef'
  @prov          = @provisioner || 'undef'
  @scrpt         = @script || 'undef'

  @manifest = <<-EOS
  include policy_engine
  policy_test { '#{@test_name}':
    ensure           => #{@ensure},
    command          => '#{@cmd}',
    script           => '#{@scrpt}',
    expect_output    => '#{@expect_output}',
    expect_exit_code => '#{@expect_exit}',
  }
  EOS

  apply_manifest @manifest, {:catch_failures => true}
end

Then(/^the test should fail$/) do
  @test_result['result'].should eq('fail')
end

Then(/^the test should pass$/) do
  @test_result['result'].should eq('pass')
end
