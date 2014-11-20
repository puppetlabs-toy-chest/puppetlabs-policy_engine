Given(/^the (.*) gem is (.*)$/) do |gem, state|
  case state
  when 'installed'
    install_package(default, 'ruby-devel')
    shell("gem install #{gem}")
  when 'uninstalled'
    shell("gem list #{gem} && gem uninstall #{gem}")
  else
    raise "Unknown gem package state #{state}"
  end
end

Given(/^the expected output format is '(.*)'$/) do |format|
  @output_format = format
end
