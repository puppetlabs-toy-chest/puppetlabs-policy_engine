Facter.add(:policy_engine_config_dir) do
  setcode do
    File.exists?('/etc/puppetlabs/puppet') ? '/etc/puppetlabs/puppet/policy_engine' : '/etc/puppet/policy_engine'
  end
end
