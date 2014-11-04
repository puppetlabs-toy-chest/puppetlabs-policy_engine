class rhel_6_stig::no_blank_passwords(
  $source = 'puppet:///modules/rhel_6_stig/no_blank_passwords.rb',
  $expect_stdout = [],
  $expect_format = 'json',
  $tag = [],
) inherits rhel_6_stig {

  $default_tags = ['stig','V-38497']

  $tags_real = concat($default_tags, $tag)

  policy_engine::test { 'no_blank_passwords':
    source        => $source,
    interpreter   => 'ruby',
    expect_stdout => $expect_output,
    expect_format => $expect_format,
    tag           => $tags_real,
  }
}
