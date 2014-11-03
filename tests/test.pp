include policy_engine

policy_engine::test { 'V-38462':
  confine       => {
    'kernel'   => 'Linux',
    'osfamily' => 'Redhat'
  },
  code          => 'grep nosignature /etc/rpmrc /usr/lib/rpm/rpmrc /usr/lib/rpm/rpmrc ~root/.rpmrc',
  expect_output => '',
}
