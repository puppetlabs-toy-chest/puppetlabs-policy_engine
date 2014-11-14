require 'yaml'
require 'fileutils'

Puppet::Type.type(:policy_test).provide(:policy_test) do
  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end

  def payload_file_path
    self.class.payload_file(@resource[:name])
  end

  def metadata_file_path
    self.class.metadata_file(@resource[:name])
  end

  def self.metadata_file(test)
    "#{self.resource_type.config[:test_dir]}/metadata/#{test}.yml"
  end

  def self.payload_file(test)
    "#{self.resource_type.config[:test_dir]}/payloads/#{test}"
  end

  def self.metadata(test)
    data = YAML::load(IO.read(metadata_file(test)))
    data[:name] = test
    data[:metadata_file] = metadata_file(test)
    data[:payload_file] = payload_file(test)
    data
  end

  def self.instances
    Dir["#{self.resource_type.config[:test_dir]}/metadata/*"].map do |test|
      name = File.basename test, '.yml'
      new(metadata(name))
    end
  end

  def exists?
    metadata_present = File.exists?(metadata_file_path)
    @property_hash[:ensure] = if metadata_present
                                :present
                              else
                                :absent
                              end
    metadata_present
  end

  def create
    @property_hash = {:ensure => :present,
                      :script => @resource[:script], 
                      :interpreter => @resource[:interpreter], 
                      :output_format => @resource[:output_format], 
                      :expected_output => @resource[:expected_output], 
                      :expected_exit_code => @resource[:expected_exit_code],
                      :payload_file => payload_file_path,
                      :metadata_file => metadata_file_path}

    self.script = @resource[:script]
  end

  def destroy
    FileUtils.rm_f payload_file_path
    FileUtils.rm_f metadata_file_path
  end

  mk_resource_methods

  def expected_output
    if @property_hash[:expected_output].empty?
      @property_hash[:expected_output] = '""'
    else
      @property_hash[:expected_output] = @resource[:expected_output]
    end
  end

  def script
    if File.exists?(payload_file_path)
      IO.read payload_file_path
    else
      ''
    end
  end

  def script=(s)
    File.open(payload_file_path, 'w') do |f|
      f.write s
    end
  end

  def flush
    if @resource[:ensure] != :absent
      File.open(metadata_file_path, 'w') do |f|
        f.write @property_hash.to_yaml
      end
    end
  end
end
