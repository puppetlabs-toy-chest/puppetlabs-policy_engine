Feature: Manage policy tests as resources
  As a security engineer
  I want to manage system policy tests as Puppet resources
  so that I can easily apply tests to all appropriate systems
  so that I can manage my policies in the same tooling as my configuration management

  Scenario: A test should exist
    Given a policy test named 'test_name' is declared
    And the policy test should exist on the node
    When puppet runs
    Then the policy test should exist

  Scenario: A test shouldn't exist
    Given a policy test named 'test_name' is declared
    And the policy test shouldn't exist on the node
    When puppet runs
    Then the policy test shouldn't exist
