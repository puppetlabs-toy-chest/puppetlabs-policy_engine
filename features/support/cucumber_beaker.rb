class Cucumber::Beaker
  include ::Beaker::DSL

  def pluginsync
    shell("puppet agent -t --noop") unless @pluginsynced
    @pluginsynced = true
  end

  def policy_engine_config
    return @config if @config

    #pluginsync 

    defaults = {
      'test_dir' => "#{shell("facter -p puppet_vardir").stdout.chomp}/policy_tests"
    }

    cfg = Hash.new


    file = shell("facter -p policy_engine_config_dir").stdout.chomp

    begin
      cfg = YAML::load( shell("cat #{file}").stdout.chomp )
    rescue
    end

    @config = defaults.merge(cfg)
  end

  def generate_manifest
    parameters = Array.new

    name            = @test_name || 'test_name'
    res_ensure      = @ensure || 'present'

    parameters << "ensure => #{res_ensure},"

    if @expected_output.is_a?(String)
      @expected_output = "''" if @expected_output.empty?
      @expected_output = @expected_output.gsub("'","\'")
      @expected_output = "'#{@expected_output}'"
    elsif @expected_output.is_a?(Array)
      @expected_output.map! do |e| 
        if e.is_a?(Regexp)
          e = e.inspect
        else
          String(e)
        end
      end
    end

    @script = @script.gsub("'",'\'') if @script
    @interpreter = @interpreter.gsub("'",'\'') if @interpreter

    parameters << "expected_output => #{@expected_output}," if @expected_output
    parameters << "expected_exit_code => #{@expected_exit_code}," if @expected_exit_code
    parameters << "script => '#{@script}'," if @script
    parameters << "source => '#{@source}'," if @source
    parameters << "interpreter => '#{@interpreter}'," if @interpreter

    @manifest = <<-EOS
      include policy_engine
      policy_engine::test { '#{name}':
      #{parameters.join("\n")}
      }
    EOS
  end

  def puppet_module_install_on_all_hosts(opts)
    puppet_module_install opts
    pluginsync
  end

  def puppet_installed?
    shell("puppet --version").exit_code == 0
  end

  def install_puppet_on_all_hosts
    unless puppet_installed?
      if default.is_pe?; then install_pe; else install_puppet; end
    end
  end

  def install_masters
    install_package master, 'puppet-server'
    on master, 'service puppetmaster start'
  end

  def set_hosts
    master_ip = fact_on master, 'ipaddress'
    master_hostname = fact_on master,  'hostname'

    #These get returned as arrays
    agent_ip  = fact_on agents, 'ipaddress'
    agent_hostname = fact_on agents,  'hostname'

    manifest = <<-EOS
    host { '#{master_hostname}':
      ip => '#{master_ip}',
      host_aliases => 'puppet'
    }
    EOS

    agent_hostname.delete(master_hostname)

    agent_hostname.each_with_index do |hostname, index|
      manifest = manifest +  <<-EOS
      host { '#{hostname}':
        ip => '#{agent_ip[index]}',
      }
      EOS
    end

    apply_manifest_on hosts, manifest
  end

  def logger
    options[:logger]
  end

  def options
    @@options
  end

  def environment
    @@options
  end

  def hosts
    @@hosts
  end

  def setup(args = [])
    options_parser = ::Beaker::Options::Parser.new
    @@options = options_parser.parse_args(args)
    @@options[:quiet] = true
    @@options[:log_level] = :warn unless @@options[:log_devel] == :debug
    @@options[:logger] = ::Beaker::Logger.new(@@options)
  end

  def provision(options)
    network_manager = ::Beaker::NetworkManager.new(options, ::Beaker::Logger.new)
    @@hosts = network_manager.provision
    network_manager.validate
    network_manager.configure
    hosts
  end
end
