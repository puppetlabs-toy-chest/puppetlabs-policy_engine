Feature: Write policy tests in any language
  As Reis
  I want to write policy tests in the language I’m most comfortable with
  so that I don’t have to learn a new language to write policy tests

  Scenario: bash command is wrong on node
    Given a bash command that lists files in /opt
    And the test on the node has the wrong command
    When puppet runs
    Then the test should be using the correct command

  Scenario: bash command succeeds
    Given a bash command that lists files in /opt
    And the /opt directory is empty
    And the expected output is empty
    And the test exists
    When I run the test
    Then the test should pass

  Scenario: bash command fails
    Given a bash command that lists files in /opt
    And the /opt directory is not empty
    And the expected output isn't empty
    And the test exists
    When I run the test
    Then the test should fail

  Scenario: ruby script succeeds
    Given a ruby script that lists all package resources
    And the expected output isn't empty
    And the test exists
    When I run the test
    Then the test should pass

  Scenario: ruby script fails
    Given a ruby script that lists all package resources
    And the expected output is empty
    And the test exists
    When I run the test
    Then the test should fail
