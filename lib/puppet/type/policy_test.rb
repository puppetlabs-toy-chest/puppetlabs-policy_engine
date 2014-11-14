Puppet::Type.newtype(:policy_test) do
  ensurable

  def self.config
    return @config if @config


    defaults = {
      :test_dir => "#{Puppet[:vardir]}/policy_tests"
    }

    cfg = Hash.new

    file = if File.directory?('/etc/puppetlabs/puppet')
             '/etc/puppetlabs/puppet/policy_engine/config.yml'
           else 
             '/etc/puppet/policy_engine/config.yml'
           end

    if File.exists?(file)
      cfg = YAML::load file
    end

    @config = defaults.merge(cfg)

    FileUtils.mkdir_p "#{@config[:test_dir]}/payloads"
    FileUtils.mkdir_p "#{@config[:test_dir]}/metadata"
    
    @config
  end

  newparam(:name)

  newproperty(:script) do 
    desc "A script to run"
  end

  newproperty(:interpreter) do
    defaultto '/bin/sh'
  end

  newproperty(:output_format) do
    defaultto 'string'

    newvalue 'string'
    newvalue 'yaml'
    newvalue 'json'
  end

  newproperty(:expected_output) do
    desc "The expected stdout value from running the command or script"
  end

  newproperty(:expected_exit_code) do
  end
end
