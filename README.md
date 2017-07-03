# distractions-firewall
Firewall scripts, configurations, and rules for blocking unwanted sites and services

## Installation

    # Setup Your Edgerouter Lite with the necessary settings. [Details still to come.]
    
    $ git clone https://github.com/jeffmcfadden/distractions-firewall.git
    $ cd distractions-firewall
    $ bundle install
    $ cp config.example.yml my-config.yml
    
    # Edit my-config.yml
    
    # Install the firewall rules
    $ bundle exec firewall -c my-config.yml install
    
    # Now turn it on
    $ bundle exec firewall -c my-config.yml on
    
    # Now turn it off
    $ bundle exec firewall -c my-config.yml off

## Misc Notes

[See them here](misc.md)