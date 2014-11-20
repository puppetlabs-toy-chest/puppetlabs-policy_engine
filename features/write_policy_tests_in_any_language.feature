Feature: Write policy tests in any language
  As a security engineer
  I want to write policy tests in the language I’m most comfortable with
  so that I don’t have to learn a new language to write policy tests

  Scenario: Inline script is wrong on node
    Given an inline shell script that runs 'ls -l /opt'
    And a policy test using the inline script is declared
    And the script is 'echo wrong' on the node
    When puppet runs
    Then the script should be 'ls -l /opt'

  Scenario: Inline script is correct on node
    Given an inline shell script that runs 'ls -l /opt'
    And a policy test using the inline script is declared
    And the script is 'ls -l /opt' on the node
    When puppet runs
    Then the script should be 'ls -l /opt'

  Scenario: Inline script succeeds
    Given an inline shell script that runs 'ls -l /opt'
    And a policy test using the inline script is declared
    And the expectation is the script output returns an empty string
    And the policy test exists on the node
    And the /opt directory is empty
    When the test is run
    Then the test should pass

  Scenario: Inline script fails
    Given an inline shell script that runs 'ls -l /opt'
    And the expectation is the script output returns an empty string
    And the /opt directory is not empty
    And a policy test using the inline script is declared
    And the policy test exists on the node
    When the test is run
    Then the test should fail

  Scenario: External script is wrong on node
    Given an external ruby script that prints 'hello world'
    And a policy test using the external script is declared
    And the script is 'echo wrong' on the node
    When puppet runs
    Then the script should be the external script

  Scenario: External script is correct on node
    Given an external ruby script that prints 'hello world'
    And a policy test using the external script is declared
    And the script is 'puts \'hello world\'' on the node
    When puppet runs
    Then the script should be the external script

  Scenario: External script succeeds
    Given an external ruby script that prints 'hello world'
    And a policy test using the external script is declared
    And the expectation is the script output returns 'hello world'
    And the policy test exists on the node
    When the test is run
    Then the test should pass

  Scenario: External script fails
    Given an external ruby script that prints 'hello world'
    And a policy test using the external script is declared
    And the expectation is the script output returns an empty string
    And the policy test exists on the node
    When the test is run
    Then the test should fail
