#!/bin/bash

set -e 
( flock -n 9001 
/bin/bash /home/rustserver/rustserver update 
) 9001>/tmp/rust_version_check.lock
