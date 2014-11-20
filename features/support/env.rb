require "minitest/autorun"
require 'beaker'
require 'rspec'
require 'rspec/expectations'

cur_dir = File.dirname(__FILE__)
proj_root = File.join(cur_dir, '../..')

require File.join(cur_dir, 'cucumber_beaker')

#default option values
defaults = {
  :nodeset     => 'default',
}

#read env vars
env_vars = {
  :nodeset     => ENV['BEAKER_set'] || ENV['RS_SET'],
  :nodesetfile => ENV['BEAKER_setfile'] || ENV['RS_SETFILE'],
  :provision   => ENV['BEAKER_provision'] || ENV['RS_PROVISION'],
  :keyfile     => ENV['BEAKER_keyfile'] || ENV['RS_KEYFILE'],
  :debug       => ENV['BEAKER_debug'] || ENV['RS_DEBUG'],
  :destroy     => ENV['BEAKER_destroy'] || ENV['RS_DESTROY'],
}.delete_if {|key, value| value.nil?}

#combine defaults and env_vars to determine overall options
options = defaults.merge(env_vars)

# Configure all nodes in nodeset

# process options to construct beaker command string
nodesetfile = options[:nodesetfile] || File.join('features/nodesets',"#{options[:nodeset]}.yml")
fresh_nodes = options[:provision] == 'no' ? '--no-provision' : nil
keep_nodes = options[:destroy] == 'no' ? ['--preserve-hosts','always'] : nil
keyfile = options[:keyfile] ? ['--keyfile', options[:keyfile]] : nil
debug = options[:log_level] ? ['--log-level', 'debug'] : nil

bkr = Cucumber::Beaker.new

#Create the environment
bkr.setup([fresh_nodes, keep_nodes, '--hosts', nodesetfile, keyfile, debug].flatten.compact)
bkr.provision bkr.environment
  
#Install Puppet and current module
bkr.install_puppet_on_all_hosts
bkr.install_masters
bkr.set_hosts
bkr.puppet_module_install_on_all_hosts(:source => proj_root, :module_name => 'policy_engine')

#Use Cucumber::Beaker class as World
#since it has the Beaker::DSL module included
#
#NOTE: We cannot include the Beaker::DSL module
#in this class since the Beaker::DSL::InstallUtils#step method
#overwrites the Cucumber#step method
World do
  Cucumber::Beaker.new
end

Before do
  @script = nil
  @source = nil
  @expected_output = nil
  @expected_exit_code = nil
  @test_name = nil
  @ensure = nil
  @interpreter = nil
  @tag = nil
end
