class Cucumber::Beaker
  include ::Beaker::DSL

  def puppet_module_install_on_all_hosts(opts)
    puppet_module_install opts
  end

  def install_puppet_on_all_hosts
    if default.is_pe?; then install_pe; else install_puppet; end
  end

  def logger
    @@logger ||= ::Beaker::Logger.new
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
