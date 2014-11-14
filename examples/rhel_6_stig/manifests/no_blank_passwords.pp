class rhel_6_stig::no_blank_passwords(
  $source = 'puppet:///modules/rhel_6_stig/no_blank_passwords.rb',
  $script = undef,
  $interpreter = 'ruby',
  $expected_output = [],
  $expected_exit_code = undef,
  $output_format = 'json',
  $tags = [],
) inherits rhel_6_stig {

  $default_tags = ['stig','V-38497']

  $tags_real = concat($default_tags, $tags)

  policy_engine::test { 'no_blank_passwords':
    source             => $source,
    interpreter        => $interpreter,
    expected_output    => $expected_output,
    expected_exit_code => $expected_exit_code,
    output_format      => $output_format,
    tags               => $tags_real,
  }
}
