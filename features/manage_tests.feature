Feature: Manage policy tests as resources
  As Reis
  I want to manage system policy tests as Puppet resources
  so that I can easily apply tests to all appropriate systems
  so that I can manage my policies in the same tooling as my configuration management

  Scenario: A test should exist
    Given a policy test should exist
    When puppet runs
    Then the test should exist

  Scenario: A test shouldn't exist
    Given a policy test shouldn't exist
    When puppet runs
    Then the test shouldn't exist
