define policy_engine::test(
  $ensure = present,
  $source = undef,
  $script = undef,
  $interpreter = '/bin/sh',
  $output_format = 'string',
  $expected_output = undef,
  $expected_exit_code = undef,
  $tags = [],
) {

  if $ensure == 'present' {
    $ensure_real = 'file'
  } elsif $ensure == 'absent' {
    $ensure_real = 'absent'
  } else {
    fail "\$ensure for Policy_engine::Test[${title}] must be present or absent. Not ${ensure}"
  }

  file { "${policy_engine::test_dir}/metadata/${name}.yml":
    ensure  => $ensure,
    content => policy_engine_test_config( $interpreter,
      $output_format,
      $expected_output,
      $expected_exit_code,
      $tags,
      "${policy_engine::test_dir}/metadata/${name}.yml",
      "${policy_engine::test_dir}/payloads/${name}"),
    mode    => '0440',
  }

  file { "${policy_engine::test_dir}/payloads/${name}":
    ensure  => $ensure,
    content => $script,
    source  => $source,
    mode    => '0550',
  }
}
