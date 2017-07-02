# distractions-firewall
Firewall scripts, configurations, and rules for blocking unwanted sites and services

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