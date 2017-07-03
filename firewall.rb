require 'tty'
require './known_ip_ranges.rb'
require './service_groups.rb'

class Firewall
  attr_accessor :options
  attr_accessor :tty_cmd
  attr_accessor :pastel
  
  def initialize( options = {} )
    # puts "Options: "
    # puts options
    
    self.options ={}
    self.options[:blocks] = options['BLOCKS'].collect{ |b| b.to_sym }
    self.options[:additional_blocks] = options['ADDITIONAL_BLOCKS']
    self.options[:firewall_rule_number] = options['FIREWALL_RULE_NUMBER']
    self.options[:distraction_address_group_name] = options['DISTRACTION_ADDRESS_GROUP_NAME']
    self.options[:router_ip_address] = options['ROUTER_IP_ADDRESS']
    self.options[:ssh_keyfile] = options['SSH_KEYFILE']
    self.options[:ssh_user] = options['SSH_USER']
    self.options[:firewall_policy_name] = options['FIREWALL_POLICY_NAME']
    
    self.tty_cmd = TTY::Command.new( printer: :null )
    self.pastel  = Pastel.new
  end
  
  def install
    uninstall_existing_address_groups
    install_address_groups
    install_on_script
    install_off_script
  end
  
  def uninstall_existing_address_groups
    show_group_cmd = "ssh #{options[:ssh_user]}@#{options[:router_ip_address]} -i #{options[:ssh_keyfile]} \"/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper show firewall group address-group #{options[:distraction_address_group_name]}\" | grep address"

    self.run_command( cmd, "Fetching existing address group addresses" )

    print pastel.white "Creating address group uninstall script..."

    remove_rules = out.split( "\n" ).collect{ |line| line.gsub( "address", "$run delete firewall group address-group #{options[:distraction_address_group_name]} address" ).strip }
    uninstall_script = File.read( './uninstall_existing_rules_template.txt' )
    uninstall_script = uninstall_script.gsub( '### REMOVE_EXISTING_RULES ###', remove_rules.join( "\n" ) )

    filename = "#{normalized_group_name}.sh"
    remote_filename = "/config/scripts/#{filename}"

    # puts "filename: #{filename}"
    # puts "remote_filename: #{remote_filename}"

    Dir.mktmpdir {|dir|
      local_filename = File.join( dir, filename )
      # puts "local_filename: #{local_filename}"

      File.open( local_filename, 'w' ){ |f| f.write(uninstall_script) }
      print pastel.green( " [SUCCESS]\n" )

      chmod_cmd = "chmod 755 #{local_filename}"
      self.run_command( chmod_cmd, "Marking address group uninstall script executable" )

      ssh_copy_cmd = "scp -i #{options[:ssh_keyfile]} #{local_filename} #{options[:ssh_user]}@#{options[:router_ip_address]}:#{remote_filename}"
      self.run_command( ssh_copy_cmd, "Copying address group uninstall script to router" )

      ssh_run_cmd = "ssh #{options[:ssh_user]}@#{options[:router_ip_address]} -i #{options[:ssh_keyfile]} \"#{remote_filename}\""
      self.run_command( ssh_run_cmd, "Removing existing address groups on router" )
    }
  end
  
  def install_address_groups
    print pastel.white "Building address blocklist..."
    
    addresses_to_block = []

    options[:blocks].each do |block|
      if !options[:service_groups][block].nil?
        addresses_to_block += options[:service_groups][block].collect{ |g| options[:known_ip_ranges][g] }
      elsif !options[:known_ip_ranges][block].nil?
        addresses_to_block += options[:known_ip_ranges][block]
      else
        puts pastel.yellow "  Couldn't find anything with the name #{block} to load blocks."
      end
    end

    if !options[:additional_blocks].nil?
      addresses_to_block += options[:additional_blocks]
    end

    addresses_to_block = addresses_to_block.flatten

    print pastel.green( " [SUCCESS]\n" )
    print pastel.white "Creating address group install script..."

    add_rules = addresses_to_block.collect{ |a| "$run set firewall group address-group #{options[:distraction_address_group_name]} address #{a}" }

    install_script = File.read( './install_rules_template.txt' )
    install_script = install_script.gsub( '### INSTALL_RULES ###', add_rules.join( "\n" ) )


    install_filename = "#{normalized_group_name}_install.sh"
    remote_install_filename = "/config/scripts/#{install_filename}"

    # puts "install_filename: #{install_filename}"
    # puts "remote_install_filename: #{remote_install_filename}"

    Dir.mktmpdir {|dir|
      local_install_filename = File.join( dir, install_filename )
      # puts "local_install_filename: #{local_install_filename}"

      File.open( local_install_filename, 'w' ){ |f| f.write(install_script) }
      print pastel.green( " [SUCCESS]\n" )

      chmod_cmd = "chmod 755 #{local_install_filename}"
      self.run_command( chmod_cmd, "Marking address group install script executable" )

      ssh_copy_cmd = "scp -i #{options[:ssh_keyfile]} #{local_install_filename} #{options[:ssh_user]}@#{options[:router_ip_address]}:#{remote_install_filename}"
      self.run_command( ssh_copy_cmd, "Copying address group install script to router" )

      ssh_run_cmd = "ssh #{options[:ssh_user]}@#{options[:router_ip_address]} -i #{options[:ssh_keyfile]} \"#{remote_install_filename}\""
      self.run_command( ssh_run_cmd, "Installing new address groups on router" )
    }
  end
  
  def install_on_script
    Dir.mktmpdir {|dir|
      print pastel.white "Generating firewall on script..."
      
      on_filename = "#{normalized_group_name}_on.sh"
  
      local_on_filename  = File.join( dir, on_filename )
      remote_on_filename = "/config/scripts/#{on_filename}"
      # puts "local_install_filename: #{local_off_filename}"
  
      firewall_on_script = File.read( './firewall_on_template.txt' ).gsub( 'FIREWALL_POLICY_NAME', options[:firewall_policy_name] ).gsub( 'FIREWALL_RULE_NUMBER', options[:firewall_rule_number] )

      File.open( local_on_filename, 'w' ){ |f| f.write(firewall_on_script) }
      print pastel.green( " [SUCCESS]\n" )

      puts "chmod"
      chmod_cmd = "chmod 755 #{local_on_filename}"
      self.run_command( chmod_cmd, "Marking firewall on script executable" )

      puts "scp"
      ssh_copy_cmd = "scp -i #{options[:ssh_keyfile]} #{local_on_filename} #{options[:ssh_user]}@#{options[:router_ip_address]}:#{remote_on_filename}"
      self.run_command( ssh_copy_cmd, "Installing firewall on script on router" )
    }
  end
  
  def install_off_script
    Dir.mktmpdir {|dir|
      print pastel.white "Generating firewall off script..."
      
      off_filename = "#{normalized_group_name}_off.sh"
  
      local_off_filename  = File.join( dir, off_filename )
      remote_off_filename = "/config/scripts/#{off_filename}"
      # puts "local_install_filename: #{local_off_filename}"
  
      firewall_off_script = File.read( './firewall_off_template.txt' ).gsub( 'FIREWALL_POLICY_NAME', options[:firewall_policy_name] ).gsub( 'FIREWALL_RULE_NUMBER', options[:firewall_rule_number] )

      File.open( local_off_filename, 'w' ){ |f| f.write(firewall_off_script) }
      print pastel.green( " [SUCCESS]\n" )

      puts "chmod"
      chmod_cmd = "chmod 755 #{local_off_filename}"
      self.run_command( chmod_cmd, "Marking firewall off script executable" )

      puts "scp"
      ssh_copy_cmd = "scp -i #{options[:ssh_keyfile]} #{local_off_filename} #{options[:ssh_user]}@#{options[:router_ip_address]}:#{remote_off_filename}"
      self.run_command( ssh_copy_cmd, "Installing firewall off script on router" )
    }
  end

  def turn_on
    on_filename = "#{normalized_group_name}_on.sh"

    ssh_run_cmd = "ssh #{options[:ssh_user]}@#{options[:router_ip_address]} -i #{options[:ssh_keyfile]} \"/config/scripts/#{on_filename}\""
    run_command( ssh_run_cmd, "Enabling firewall" )
  end
  
  def turn_off
    off_filename = "#{normalized_group_name}_off.sh"

    ssh_run_cmd = "ssh #{options[:ssh_user]}@#{options[:router_ip_address]} -i #{options[:ssh_keyfile]} \"/config/scripts/#{off_filename}\""
    run_command( ssh_run_cmd, "Disabling firewall" )
  end

  private
  
  def run_command( cmd, desc = nil )
    if !desc.nil?
      print pastel.white "#{desc}..."
    end
    
    result = tty_cmd.run(cmd)

    if result.success?
      print pastel.green( " [SUCCESS]\n" )
    else
      print pastel.red " [ERROR]\n" 
      puts pastel.red  "  Command: #{ssh_run_cmd}"
      puts pastel.red  "  out: #{result.out}"
      puts pastel.red  "  err: #{result.err}"
    end

    result.success?
  end
  
  def normalized_group_name
    options[:distraction_address_group_name].gsub( ' ', '_' ).gsub( '-', '_' ).strip.downcase
  end
  
end