require 'tty'

require './known_ip_ranges.rb'
require './service_groups.rb'

config_file = ARGV[0]

if config_file[0] == '/'
  require config_file
else
  require File.join( ".", config_file )
end

tty = TTY::Command.new( printer: :null )
pastel = Pastel.new

normalized_group_name = DISTRACTION_ADDRESS_GROUP_NAME.gsub( ' ', '_' ).gsub( '-', '_' ).strip.downcase
on_filename = "#{normalized_group_name}_on.sh"

ssh_run_cmd = "ssh #{SSH_USER}@#{ROUTER_IP_ADDRESS} -i #{SSH_KEYFILE} \"/config/scripts/#{on_filename}\""

print pastel.white( "Enabling firewall..." )

result = tty.run( ssh_run_cmd )

if result.success?
  print pastel.green( " [SUCCESS]\n" )
else
  print pastel.red " [ERROR]\n" 
  puts pastel.red  "  Command: #{ssh_run_cmd}"
  puts pastel.red  "  out: #{result.out}"
  puts pastel.red  "  err: #{result.err}"
end