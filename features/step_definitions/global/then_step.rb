Then(/^the test should (pass|fail)$/) do |state|
  @test_result['result'].should eq(state)
end
