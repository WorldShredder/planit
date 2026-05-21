#!/usr/bin/env bash

set -e

#
# Read global cache
#

Plan::log.mod 'read: root <- global_a <- global'
if [ "$global_a" != 'global->global_a' ]; then
    Plan::log.mod -c 1 "read: global_a -- not set in root [FAIL]"
    exit 1
fi

Plan::log.mod 'read: root <- global_b <- root'
if [ "$global_b" != 'root->global_b' ]; then
    Plan::log.mod -c 1 "read: global_b -- not set in root [FAIL]"
    exit 1
fi

#
# Read root cache
#

Plan::log.mod 'read: root <- root_a <- root'
if [ "$root_a" != 'root->root_a' ]; then
    Plan::log.mod -c 1 "read: root_a -- not set in root [FAIL]"
    exit 1
fi

Plan::log.mod 'read: root <- local_a <- root'
if [ "$local_a" != 'root->local_a' ]; then
    Plan::log.mod -c 1 "read: local_a -- not set in root [FAIL]"
    exit 1
fi

Plan::log.mod -c 2 'OK'
