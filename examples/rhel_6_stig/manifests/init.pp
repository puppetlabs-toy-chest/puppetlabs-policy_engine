class rhel_6_stig {
  Policy_engine::Test {
    confine => { 'osfamily' => 'Redhat' }
  }
}
