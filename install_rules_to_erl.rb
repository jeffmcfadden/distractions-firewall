require 'tty-command'

config_file = ARGV[0]

if config_file[0] == '/'
  require config_file
else
  require File.join( ".", config_file )
end

#/config/scripts

show_group_cmd = "ssh #{SSH_USER}@#{ROUTER_IP_ADDRESS} -i #{SSH_KEYFILE} \"/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper show firewall group address-group #{DISTRACTION_ADDRESS_GROUP_NAME}\" | grep address"

tty = TTY::Command.new
out, err = tty.run(show_group_cmd)

puts "Out: #{out}"
puts "Err: #{err}"

remove_rules = out.split( "\n" ).collect{ |line| line.gsub( "address", "$run delete firewall group address-group Distracting-Stuff address" ).strip }

uninstall_script = File.read( './uninstall_existing_rules_template.txt' )


uninstall_script = uninstall_script.gsub( '### REMOVE_EXISTING_RULES ###', remove_rules.join( "\n" ) )


puts "\n\n\n"
puts uninstall_script