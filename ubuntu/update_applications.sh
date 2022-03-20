#!/bin/bash

logger -ip '==============================================================='
logger -ip '    Update applications'
logger -ip '==============================================================='
logger -ip "Current time $(date '+%Y-%m-%dT%H:%M:%S%z')"

logger -ip 'user.info' 'apt update ---------------------------------------------------'
{ apt update 2>&1 1>&3 3>&- | logger -ip 'user.warning'; } 3>&1 1>&2 | logger -ip 'user.info'
logger -ip 'user.info' 'apt upgrade --------------------------------------------------'
{ apt upgrade -y 2>&1 1>&3 3>&- | logger -ip 'user.warning'; } 3>&1 1>&2 | logger -ip 'user.info'
