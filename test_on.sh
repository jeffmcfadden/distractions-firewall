#!/bin/vbash
# source /opt/vyatta/etc/functions/script-template

# Rule 2 is a magic number (pulled from the UI)
# It's my rule that blocks things from my devices address group to the distracting sites address group

run=/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper

$run begin
$run delete firewall name ETH1_IN rule 2 disable
$run commit
$run save
$run end