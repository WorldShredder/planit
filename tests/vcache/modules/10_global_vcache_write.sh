#!/usr/bin/env bash

set -e

#
# Write global cache
#

Plan::log.mod 'write: global -> global_a'
Plan::vcache.add -s global 'global_a' 'global->global_a'

Plan::log.mod 'read var: global_a (set)'
if [ "$global_a" != 'global->global_a' ]; then
    Plan::log.mod -c 1 "read var: global_a -- failed to set [FAIL]"
    exit 1
fi

Plan::log.mod -c 2 'OK'
