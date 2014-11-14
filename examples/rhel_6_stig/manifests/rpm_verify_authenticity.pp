class rhel_6_stig::rpm_verify_authenticity(
  $source = undef,
  $script = 'grep nosignature /etc/rpmrc /usr/lib/rpm/rpmrc ~root/.rpmrc',
  $expected_output = undef,
  $expected_exit_code = 1,
  $output_format = undef,
  $tags = []
) inherits rhel_6_stig {

  $default_tags = ['stig','V-38462']

  $tags_real = concat($default_tags, $tags)

  policy_engine::test { 'rpm_verify_authenticity':
    source             => $source,
    script             => $script,
    interpreter        => $interpreter,
    expected_output    => $expected_output,
    expected_exit_code => $expected_exit_code,
    output_format      => $output_format,
    tags               => $tags_real,
  }

}
