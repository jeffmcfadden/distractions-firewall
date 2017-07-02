## Getting SSH Keys onto the EdgeRouter Lite

http://www.forshee.me/2016/03/01/ubiquiti-edgerouter-lite-setup-part-1-the-basics.html

## How to get all Facebook IP Addresses

    whois -h whois.radb.net '!gAS32934'

## IPTables blocking of Facebook

    /usr/bin/whois -h whois.radb.net '!gAS32934' | head -n -1 | tail -n -1 | /usr/bin/xargs --max-args=1 | /usr/bin/xargs -I {} --max-args=1 iptables -A OUTPUT -d {} -j REJECT

See: [https://askubuntu.com/questions/774666/how-to-block-facebook](https://askubuntu.com/questions/774666/how-to-block-facebook)

## IPTables Chains

http://www.linuxquestions.org/questions/linux-security-4/iptables-and-groups-of-ips-523971/

## Add an IP or Subnet to the disctractions group on ERL

    configure
    set firewall group address-group Distracting-Stuff address 208.65.153.251
    set firewall group address-group Distracting-Stuff address 208.65.152.0/24
    commit
    save
    exit

## Remove an IP or Subnet to the disctractions group on ERL

    configure
    delete firewall group address-group Distracting-Stuff address 208.65.153.251
    delete firewall group address-group Distracting-Stuff address 208.65.152.0/24
    commit
    save
    exit
  
## SSH and run a command on the router

    ssh me@192.168.0.1 -i ~/.ssh/mykey "./test_on.sh"

## ASN Block Lists

https://www.enjen.net/asn-blocklist/names.php

## Useful Links
    
https://community.ubnt.com/t5/EdgeMAX/GUI-not-updating-number-of-group-members-for-Firewall-Group/m-p/1685174/highlight/false#M129456
https://community.ubnt.com/t5/EdgeMAX/script-to-change-configuration-not-working/td-p/640689
https://community.ubnt.com/t5/EdgeMAX/How-enable-firewall-rule-in-CLI/td-p/540836
https://github.com/remfalc/vyt-vyatta-cfg/blob/master/scripts/vyatta-cfg-cmd-wrapper
https://wiki.vyos.net/wiki/Command_scripting
https://community.ubnt.com/t5/EdgeMAX/Configure-ER-over-non-interactive-SSH/td-p/1618544
https://community.ubnt.com/t5/EdgeMAX/ssh-authorized-keys/td-p/458361
https://community.ubnt.com/t5/EdgeMAX/Unable-to-delete-address-group-entries-with-leading-whitespace/td-p/1243857