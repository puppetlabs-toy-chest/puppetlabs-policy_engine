Policy Engine
-------------

This module is an early prototype of a [Policy Engine](https://docs.google.com/a/puppetlabs.com/document/d/1Pt6DAHQLqvYihRG8kaVHGjEcjNwrnDDwxPiSvVMIcXw/edit)
module.  This module allows for the declaration of policy tests that are custom
Facter facts. Since each test result is a fact value, it can be used in Puppet
manifests and queried from PuppetDB.

The tests follow the [rspec](http://rspec.info/) model of declaring what you
want to do and what you expect the result to be. If the result doesn't match
the expectation, the test fails.

Each test result is a structured value in a standard format. The output format is as follows:

**If the test passed**
{'result' => 'passed', 'tags' => ['tag1','tag2']}

**If the test fails**
{'result' => 'failed', 'tags' => ['tag1','tag2'], 'expected_output' => [], 'is' => ['example','output']}

##Declaring Tests 
Tests can be written in any language the system they run on supports. The code
that performs the test can range from a single shell command to a script file.
The user can specify an interpreter to use to run the code (defaults to
/bin/sh).

To validate a test passes or fails, an expectation can be specified. An expectation can be the following:
* Stdout output. The output can be parsed as a string, JSON, or YAML
* Stderr output. The output is parsed as a string
* Exit code. The exit code of the script execution

**Execute a command and expect no output**
policy_engine::test { 'name_of_test':
  code          => 'single command to run',
  expect_stdout => '',
}

**Execute a python script and expect an empty array in JSON**
policy_engine::test { 'another_test':
  source  => 'puppet:///modules/corp_policy/another_test.py',
  expect_stdout => [],
  expect_format => 'json',
}
