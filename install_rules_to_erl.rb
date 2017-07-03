require 'tty-command'
require './known_ip_ranges.rb'
require './service_groups.rb'

config_file = ARGV[0]

if config_file[0] == '/'
  require config_file
else
  require File.join( ".", config_file )
end

normalized_group_name = DISTRACTION_ADDRESS_GROUP_NAME.gsub( ' ', '_' ).gsub( '-', '_' ).strip.downcase
tty = TTY::Command.new

## REMOVE OLD RULES FIRST ##

# show_group_cmd = "ssh #{SSH_USER}@#{ROUTER_IP_ADDRESS} -i #{SSH_KEYFILE} \"/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper show firewall group address-group #{DISTRACTION_ADDRESS_GROUP_NAME}\" | grep address"
#
# out, err = tty.run(show_group_cmd)
#
# puts "Out: #{out}"
# puts "Err: #{err}"
#
# remove_rules = out.split( "\n" ).collect{ |line| line.gsub( "address", "$run delete firewall group address-group #{DISTRACTION_ADDRESS_GROUP_NAME} address" ).strip }
#
# uninstall_script = File.read( './uninstall_existing_rules_template.txt' )
#
# uninstall_script = uninstall_script.gsub( '### REMOVE_EXISTING_RULES ###', remove_rules.join( "\n" ) )
#
# puts "\n\n\n"
# puts uninstall_script
#
# filename = "#{normalized_group_name}.sh"
# remote_filename = "/config/scripts/#{filename}"
#
# puts "filename: #{filename}"
# puts "remote_filename: #{remote_filename}"
#
# Dir.mktmpdir {|dir|
#   local_filename = File.join( dir, filename )
#   puts "local_filename: #{local_filename}"
#
#   File.open( local_filename, 'w' ){ |f| f.write(uninstall_script) }
#
#   puts "chmod"
#   chmod_cmd = "chmod 755 #{local_filename}"
#   puts "  #{chmod_cmd}"
#   out, err = tty.run(chmod_cmd)
#   puts "  out: #{out}"
#   puts "  err: #{err}"
#
#   puts "scp"
#   ssh_copy_cmd = "scp -i #{SSH_KEYFILE} #{local_filename} #{SSH_USER}@#{ROUTER_IP_ADDRESS}:#{remote_filename}"
#   puts "  #{ssh_copy_cmd}"
#   out, err = tty.run(ssh_copy_cmd)
#   puts "  out: #{out}"
#   puts "  err: #{err}"
#
#   puts "run"
#   ssh_run_cmd = "ssh #{SSH_USER}@#{ROUTER_IP_ADDRESS} -i #{SSH_KEYFILE} \"#{remote_filename}\""
#   puts "  #{ssh_run_cmd}"
#   out, err = tty.run(ssh_run_cmd)
#   puts "  out: #{out}"
#   puts "  err: #{err}"
# }
#
# ## NOW ADD NEW RULES ##
#
# addresses_to_block = []
#
# BLOCKS.each do |block|
#   if !SERVICE_GROUPS[block].nil?
#     addresses_to_block += SERVICE_GROUPS[block].collect{ |g| KNOWN_IP_RANGES[g] }
#   elsif !KNOWN_IP_RANGES[block].nil?
#     addresses_to_block += KNOWN_IP_RANGES[block]
#   else
#     puts "  Couldn't find anything with the name #{block} to load blocks."
#   end
# end
#
# addresses_to_block = addresses_to_block.flatten
#
# add_rules = addresses_to_block.collect{ |a| "$run set firewall group address-group #{DISTRACTION_ADDRESS_GROUP_NAME} address #{a}" }
#
# install_script = File.read( './install_rules_template.txt' )
# install_script = install_script.gsub( '### INSTALL_RULES ###', add_rules.join( "\n" ) )
#
# puts "\n\n\n"
# puts install_script
#
# install_filename = "#{normalized_group_name}_install.sh"
# remote_install_filename = "/config/scripts/#{install_filename}"
#
# puts "install_filename: #{install_filename}"
# puts "remote_install_filename: #{remote_install_filename}"
#
# Dir.mktmpdir {|dir|
#   local_install_filename = File.join( dir, install_filename )
#   puts "local_install_filename: #{local_install_filename}"
#
#   File.open( local_install_filename, 'w' ){ |f| f.write(install_script) }
#
#   puts "chmod"
#   chmod_cmd = "chmod 755 #{local_install_filename}"
#   puts "  #{chmod_cmd}"
#   out, err = tty.run(chmod_cmd)
#   puts "  out: #{out}"
#   puts "  err: #{err}"
#
#   puts "scp"
#   ssh_copy_cmd = "scp -i #{SSH_KEYFILE} #{local_install_filename} #{SSH_USER}@#{ROUTER_IP_ADDRESS}:#{remote_install_filename}"
#   puts "  #{ssh_copy_cmd}"
#   out, err = tty.run(ssh_copy_cmd)
#   puts "  out: #{out}"
#   puts "  err: #{err}"
#
#   puts "run"
#   ssh_run_cmd = "ssh #{SSH_USER}@#{ROUTER_IP_ADDRESS} -i #{SSH_KEYFILE} \"#{remote_install_filename}\""
#   puts "  #{ssh_run_cmd}"
#   out, err = tty.run(ssh_run_cmd)
#   puts "  out: #{out}"
#   puts "  err: #{err}"
# }
#
# puts "New group has been setup."



Dir.mktmpdir {|dir|
  off_filename = "#{normalized_group_name}_off.sh"
  
  local_off_filename  = File.join( dir, off_filename )
  remote_off_filename = "/config/scripts/#{off_filename}"
  puts "local_install_filename: #{local_off_filename}"
  
  firewall_off_script = File.read( './firewall_off_template.txt' ).gsub( 'FIREWALL_POLICY_NAME', FIREWALL_POLICY_NAME ).gsub( 'FIREWALL_RULE_NUMBER', FIREWALL_RULE_NUMBER )

  File.open( local_off_filename, 'w' ){ |f| f.write(firewall_off_script) }

  puts "chmod"
  chmod_cmd = "chmod 755 #{local_off_filename}"
  puts "  #{chmod_cmd}"
  out, err = tty.run(chmod_cmd)
  puts "  out: #{out}"
  puts "  err: #{err}"

  puts "scp"
  ssh_copy_cmd = "scp -i #{SSH_KEYFILE} #{local_off_filename} #{SSH_USER}@#{ROUTER_IP_ADDRESS}:#{remote_off_filename}"
  puts "  #{ssh_copy_cmd}"
  out, err = tty.run(ssh_copy_cmd)
  puts "  out: #{out}"
  puts "  err: #{err}"
}

puts "Off script has been installed"

Dir.mktmpdir {|dir|
  on_filename = "#{normalized_group_name}_on.sh"
  
  local_on_filename  = File.join( dir, on_filename )
  remote_on_filename = "/config/scripts/#{on_filename}"
  puts "local_install_filename: #{local_on_filename}"
  
  firewall_on_script = File.read( './firewall_on_template.txt' ).gsub( 'FIREWALL_POLICY_NAME', FIREWALL_POLICY_NAME ).gsub( 'FIREWALL_RULE_NUMBER', FIREWALL_RULE_NUMBER )

  File.open( local_on_filename, 'w' ){ |f| f.write(firewall_on_script) }

  puts "chmod"
  chmod_cmd = "chmod 755 #{local_on_filename}"
  puts "  #{chmod_cmd}"
  out, err = tty.run(chmod_cmd)
  puts "  out: #{out}"
  puts "  err: #{err}"

  puts "scp"
  ssh_copy_cmd = "scp -i #{SSH_KEYFILE} #{local_on_filename} #{SSH_USER}@#{ROUTER_IP_ADDRESS}:#{remote_on_filename}"
  puts "  #{ssh_copy_cmd}"
  out, err = tty.run(ssh_copy_cmd)
  puts "  out: #{out}"
  puts "  err: #{err}"
}

puts "On script has been installed"
