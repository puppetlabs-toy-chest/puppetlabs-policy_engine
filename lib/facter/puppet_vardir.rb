require 'puppet'

Facter.add(:puppet_vardir) do
  setcode do
    begin
      Puppet.initialize_settings
    rescue
    end

    Puppet[:vardir]
  end
end
