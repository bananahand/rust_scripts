#!/bin/bash

currnet_version=$(grep -R "buildid" /home/rustserver/serverfiles/steamapps/appmanifest_258550.acf | awk '{print $2}' | sed "s/\"//g")
public_version=$(curl -s https://steamdb.info/app/258550/depots/?branch=public | grep -o "<i>buildid:</i> <b>[0-9]*</b>" | grep -o [0-9]*)

set -e

( flock -n 9001

if [ $currnet_version == $public_version ]
then
	exit 0
else
	/home/rustserver/rustserver stop
	/home/rustserver/rustserver update
	/home/rustserver/rustserver monitor
fi

) 9001>/tmp/rust_version_check.lock
