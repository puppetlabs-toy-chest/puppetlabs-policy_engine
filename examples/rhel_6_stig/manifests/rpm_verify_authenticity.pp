class rhel_6_stig::rpm_verify_authenticity(
  $command = 'grep nosignature /etc/rpmrc /usr/lib/rpm/rpmrc ~root/.rpmrc',
  $expect_output = '',
  $tag = []
) inherits rhel_6_stig {

  $default_tags = ['stig','V-38462']

  $tags_real = concat($default_tags, $tag)

  policy_engine::test { 'rpm_verify_authenticity':
    code          => $command,
    expect_output => $expect_output,
    tag           => $tags_real,
  }
}
