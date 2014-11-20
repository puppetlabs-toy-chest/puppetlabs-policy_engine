Feature: Use exit codes for determining pass/fail
  As a security engineer
  I want policy tests to pass if the exit matches what I expect
  so that I don't have to parse structured data output

  Scenario: Specified exit code is wrong on the node
    Given a policy test named 'exit_code_is_wrong' is declared
    And an inline shell script that runs 'echo hello'
    And the expectation is the script's exit code returns 3
    And the exit code is 1 on the node
    When puppet runs
    Then the exit code should be 3

  Scenario: Specified exit code is correct on the node
    Given a policy test named 'exit_code_is_wrong' is declared
    And an inline shell script that runs 'echo hello'
    And the expectation is the script's exit code returns 3
    And the exit code is 3 on the node
    When puppet runs
    Then the exit code should be 3

  Scenario: An expected exit code passes
    Given a policy test named 'exit_codes' is declared
    And an inline shell script that runs 'exit 3'
    And the expectation is the script's exit code returns 3
    And the policy test exists on the node
    When the test is run
    Then the test should pass

  Scenario: An unexpected exit code fails
    Given a policy test named 'exit_codes' is declared
    And an inline shell script that runs 'exit 3'
    And the expectation is the script's exit code returns 1
    And the policy test exists on the node
    When the test is run
    Then the test should fail

  Scenario: Multiple exit codes specified where one is expected passes
    Given a policy test named 'exit_codes' is declared
    And an inline shell script that runs 'exit 3'
    And the expectation is the script's exit code returns one of [3,2,1]
    And the policy test exists on the node
    When the test is run
    Then the test should pass

  Scenario: Multiple exit codes specified where none are expected fails
    Given a policy test named 'exit_codes' is declared
    And an inline shell script that runs 'exit 3'
    And the expectation is the script's exit code returns one of [2,1]
    And the policy test exists on the node
    When the test is run
    Then the test should fail

