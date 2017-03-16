#!/bin/bash

# Check if users have previous VAC bans on their account, if they do kick and ban them.

# Recommended cronjob:
# * * * * * /home/rustserver/bin/vac.sh

# You can get your steam API key from https://steamcommunity.com/dev/apikey
steamkey="CHANGEME"

rconhost="127.0.0.1"
rconport="28016"
rconpass="CHANGEME"
lgsm_server_log_dir="/home/rustserver/log/server"
checkedvac_log="/home/rustserver/log/checkedvac.log"
vacban_log="/home/rustserver/log/vacban.log"

latest=$(for i in "$(ls -haltr "$lgsm_server_log_dir" | tail -n1 | awk '{print $9}')";do echo "$i"; done)
people=$(cat $lgsm_server_log_dir/$latest | grep -Eo '[0-9]{17}' | sort -u)

for steam64 in $people
do
        if ! grep -qo $steam64 $checkedvac_log 
	then
        	bancount=$(curl -s http://api.steampowered.com/ISteamUser/GetPlayerBans/v1/?key=$steamkey\&steamids=$steam64 | jq -a '.players[].NumberOfVACBans')
        	if [ $bancount != 0 ]
        	then
                	check_vacban_log=$(grep -qo $steam64 $vacban_log)
                	if [ $check_vacban_log -n ]
                	then
                        	echo "$steam64" >> $vacban_log
                        	echo "kick $steam64 \"Fuck off. You have $bancount VAC bans on record.\"" | webrcon $rconhost $rconport $rconpass
                        	echo "banid $steam64" | webrcon $rconhost $rconport $rconpass
                	fi
        	fi
	echo $steam64 >> $checkedvac_log
	fi
done

