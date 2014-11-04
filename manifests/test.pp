define policy_engine::test (
  $confine = undef,
  $expect_stdout = '',
  $expect_stderr = '',
  $expect_exit_code = 0,
  $expect_format = 'string',
  $code = undef,
  $source = undef,
  $tag = [],
  $interpreter = '/bin/sh',
) {
  include policy_engine

  file { "/etc/puppet/policies/${title}.yaml":
    content => template('policy_engine/test_config.erb'),
    owner   => 0,
    group   => 0,
  }

  file { "${::policy_engine::test_dir}/${title}":
    content => $code,
    source  => $source,
    owner   => 0,
    group   => 0,
  }
}
