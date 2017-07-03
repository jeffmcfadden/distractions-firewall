require 'tty-command'
require './known_ip_ranges.rb'
require './service_groups.rb'

config_file = ARGV[0]

if config_file[0] == '/'
  require config_file
else
  require File.join( ".", config_file )
end

tty = TTY::Command.new

normalized_group_name = DISTRACTION_ADDRESS_GROUP_NAME.gsub( ' ', '_' ).gsub( '-', '_' ).strip.downcase
on_filename = "#{normalized_group_name}_on.sh"

ssh_run_cmd = "ssh #{SSH_USER}@#{ROUTER_IP_ADDRESS} -i #{SSH_KEYFILE} \"/config/scripts/#{on_filename}\""
puts "  #{ssh_run_cmd}"
out, err = tty.run(ssh_run_cmd)
puts "  out: #{out}"
puts "  err: #{err}"
