class policy_engine (
  $test_dir = "${::puppet_vardir}/policy_tests",
) {

  file { '/etc/puppet/policy.yaml':
    content => template('policy_engine/policy_config.erb'),
    owner   => 0,
    group   => 0,
  }

  file { $test_dir:
    ensure  => directory,
    purge   => true,
    recurse => true,
    owner   => 0,
    group   => 0,
  }

  file { '/etc/puppet/policies':
    ensure  => directory,
    purge   => true,
    recurse => true,
    owner   => 0,
    group   => 0,
  }
}
