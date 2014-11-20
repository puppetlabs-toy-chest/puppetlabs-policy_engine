Feature: Parse output of a script as structured data
  As a security engineer
  I want to have a script return structured data
  so that I can more accurately determine if a test passes or fails
  so that I can use policy test results in a programmatic way

  Scenario: Capture output as YAML
    Given a policy test named 'test_name' is declared
    And an inline ruby script that runs 'require "yaml"; ["1","2","3"].to_yaml'
    And the expectation is the script output returns an array containing ['1','2','3']
    And the expected output format is 'yaml'
    And the policy test exists on the node
    When the test is run
    Then the test should pass

  Scenario: Capture output as JSON
    Given a policy test named 'test_name' is declared
    And the json gem is installed
    And an inline ruby script that runs 'require "json"; ["1","2","3"].to_json'
    And the expectation is the script output returns an array containing ['1','2','3']
    And the expected output format is 'json'
    And the policy test exists on the node
    When the test is run
    Then the test should pass
