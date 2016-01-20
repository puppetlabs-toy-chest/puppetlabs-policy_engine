class policy_engine (
  String $test_dir = "${::puppet_vardir}/policy_tests",
) {

  file { $::policy_engine_config_dir:
    ensure  => directory,
  }

  file { "${::policy_engine_config_dir}/config.yml":
    ensure  => file,
    content => template('policy_engine/policy_config.erb'),
    mode    => '0440',
  }

  file { $test_dir:
    ensure  => directory,
  }

  file { "${test_dir}/metadata":
    ensure  => directory,
    recurse => true,
    purge   => true,
  }

  file { "${test_dir}/payloads":
    ensure  => directory,
    recurse => true,
    purge   => true,
  }
}
