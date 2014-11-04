require 'puppet/face'

Puppet::Type.loadall

results = Array.new

#Get all users on the system from the RAL and test them for blank passwords
Puppet::Face[:resource, :current].search('user').each do |user|
  if user[:password] == ''
    results << {'user' => user.title , 'blank_password' => true}
  end
end

#Output results in JSON
puts results.to_json
