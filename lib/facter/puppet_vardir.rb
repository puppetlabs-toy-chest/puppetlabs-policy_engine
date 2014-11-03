require 'puppet'

Facter.add('puppet_vardir') do
  setcode do
    Puppet[:vardir]
  end
end
