#!/usr/bin/env bash

set -e

#
# Write global cache
#

Plan::log.mod 'write: local -> global_c'
Plan::vcache.add global 'global_c' 'local->global_c'

#
# Write root cache
#

Plan::log.mod 'write: local -> root_b'
Plan::vcache.add root 'root_b' 'local->root_b'

#
# Write local cache
#

Plan::log.mod 'write: local -> local_b'
Plan::vcache.add local 'local_b' 'local->local_b'

#
# Delete global cache
#

Plan::log.mod 'delete: local -> global_a'
Plan::vcache.del global 'global_a'

#
# Delete root cache
#

Plan::log.mod 'delete: local -> root_a'
Plan::vcache.del root 'root_a'

Plan::log.mod -c 2 'OK'
