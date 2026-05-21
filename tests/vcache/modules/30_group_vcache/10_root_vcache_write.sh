#!/usr/bin/env bash

set -e

#
# Write global cache
#

Plan::log.mod 'write: root -> global_b'
Plan::vcache.add global 'global_b' 'root->global_b'

#
# Write root cache
#

Plan::log.mod 'write: root -> root_a'
Plan::vcache.add -e root 'root_a' 'root->root_a'

Plan::log.mod 'read var: root_a (export)'
if [ "$root_a" != 'root->root_a' ]; then
    Plan::log.mod -c 1 "read var: root_a -- failed to export [FAIL]"
    exit 1
fi

#
# Write local cache
#

Plan::log.mod 'write: root -> local_a'
Plan::vcache.add local 'local_a' 'root->local_a'

Plan::log.mod -c 2 'OK'
