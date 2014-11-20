Feature: Use script output for determing pass/fail
  As a security engineer
  I want policy tests to pass if the output matches what I expect
  so that I don't have to parse structured data output

  Scenario: Specified regular expression is wrong on the node
    Given a policy test named 'regular_express_wrong' is declared
    And an inline shell script that runs 'echo -n hello'
    And the expected output matches /ello$/
    And the expected output on the node matches /wrong/
    When puppet runs
    Then the expected output should be '/ello$/'

  Scenario: Specified regular expression is correct on the node
    Given a policy test named 'regular_express_correct' is declared
    And an inline shell script that runs 'echo -n hello'
    And the expected output matches /ello$/
    And the expected output on the node matches /ello$/
    When puppet runs
    Then the expected output should be '/ello$/'

  Scenario: Specified expected string is wrong on the node
    Given a policy test named 'string_wrong' is declared
    And an inline shell script that runs 'echo -n hello'
    And the expected output is 'hello'
    And the expected output on the node is 'wrong'
    When puppet runs
    Then the expected output should be 'hello'

  Scenario: Specified expected string is correct on the node
    Given a policy test named 'string_correct' is declared
    And an inline shell script that runs 'echo -n hello'
    And the expected output is 'hello'
    And the expected output on the node is 'hello'
    When puppet runs
    Then the expected output should be 'hello'

  Scenario: A specified regular expression that matches output passes
    Given a policy test named 'regex_matches' is declared
    And an inline shell script that runs 'echo -n hello'
    And the expected output matches /ello$/
    And the policy test exists on the node
    When the test is run
    Then the test should pass

  Scenario: A specified regular expression that doesn't match output fails
    Given a policy test named 'regex_no_match' is declared
    And an inline shell script that runs 'echo -n hello'
    And the expected output matches /nope$/
    And the policy test exists on the node
    When the test is run
    Then the test should fail

  Scenario: Multiple regular expressions specified where one matches output passes
    Given a policy test named 'multiple_regex_matches' is declared
    And an inline shell script that runs 'echo -n hello'
    And the expected output matches one of [/nope$/,/ello$/]
    And the policy test exists on the node
    When the test is run
    Then the test should pass

  Scenario: Multiple regular expressions specified where none matches output fails
    Given a policy test named 'multiple_regex_matches' is declared
    And an inline shell script that runs 'echo -n hello'
    And the expected output matches one of [/nope$/,/nuhuh$/]
    And the policy test exists on the node
    When the test is run
    Then the test should fail

  Scenario: A specified string matches complete output passes
    Given a policy test named 'match_output' is declared
    And an inline shell script that runs 'echo -n hello'
    And the expected output is 'hello'
    And the policy test exists on the node
    When the test is run
    Then the test should pass

  Scenario: A specified string doesn't match complete output fails
    Given a policy test named 'no_match_output' is declared
    And an inline shell script that runs 'echo -n hello'
    And the expected output is 'not hello'
    And the policy test exists on the node
    When the test is run
    Then the test should fail

  Scenario: Multiple strings specified where one matches complete output passes
    Given a policy test named 'match_one_of_output' is declared
    And an inline shell script that runs 'echo -n hello'
    And the expected output is one of ['hello','not hello']
    And the policy test exists on the node
    When the test is run
    Then the test should pass

  Scenario: Multiple strings specified where none matches complete output fails
    Given a policy test named 'match_none_of_output' is declared
    And an inline shell script that runs 'echo -n hello'
    And the expected output is one of ['neither hello','nor hello']
    And the policy test exists on the node
    When the test is run
    Then the test should fail

  Scenario: Both multiple strings and regular expressions are specified where one string matches complete output passes
    Given a policy test named 'match_one_of_output' is declared
    And an inline shell script that runs 'echo -n hello'
    And the expected output is one of ['hello', /wrong$/]
    And the policy test exists on the node
    When the test is run
    Then the test should pass

  Scenario: Both multiple strings and regular expressions are specified where one regular expression matches output passes
    Given a policy test named 'match_one_of_output' is declared
    And an inline shell script that runs 'echo -n hello'
    And the expected output is one of [/ello$/, 'wrong']
    And the policy test exists on the node
    When the test is run
    Then the test should pass

  Scenario: Both multiple strings and regular expressions are specified where no regular expression nor string matches output fails
    Given a policy test named 'match_one_of_output' is declared
    And an inline shell script that runs 'echo -n hello'
    And the expected output is one of [/wrong$/, 'wrong']
    And the policy test exists on the node
    When the test is run
    Then the test should fail
