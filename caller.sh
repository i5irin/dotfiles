#!/bin/bash

readonly INSTALL_SCRIPT_PATH=$(cd "$(dirname ${BASH_SOURCE})/"; pwd)
echo $INSTALL_SCRIPT_PATH
/bin/sh "${INSTALL_SCRIPT_PATH}/repro.sh" "${INSTALL_SCRIPT_PATH}/apps/git"
