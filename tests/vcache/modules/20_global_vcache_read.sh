#!/usr/bin/env bash

set -e

#
# Read global cache
#

Plan::log.mod 'read: global <- global_a <- global'
if [ "$global_a" != 'global->global_a' ]; then
    Plan::log.mod -c 1 "read: global_a -- not set in global [FAIL]"
    exit 1
fi

Plan::log.mod -c 2 'OK'
