#!/usr/bin/env bash

set -e

#
# Read global cache
#

Plan::log.mod 'read: root <- global_a <- global (deleted in local)'
if [ -n "$global_a" ]; then
    Plan::log.mod -c 1 "read: global_a -- set in root [FAIL]"
    exit 1
fi

Plan::log.mod 'read: root <- global_b <- root'
if [ "$global_b" != 'root->global_b' ]; then
    Plan::log.mod -c 1 "read: global_b -- not set in root [FAIL]"
    exit 1
fi

Plan::log.mod 'read: root <- global_c <- local'
if [ "$global_c" != 'local->global_c' ]; then
    Plan::log.mod -c 1 "read: global_c -- not set in root [FAIL]"
    exit 1
fi

#
# Read root cache
#

Plan::log.mod 'read: root <- root_a <- root (deleted in local)'
if [ -n "$root_a" ]; then
    Plan::log.mod -c 1 "read: root_a -- set in root [FAIL]"
    exit 1
fi

Plan::log.mod 'read: root <- root_b <- local'
if [ "$root_b" != 'local->root_b' ]; then
    Plan::log.mod -c 1 "read: root_b -- not set in root [FAIL]"
    exit 1
fi

#
# Read local cache
#

Plan::log.mod 'read: root <- local_a <- root'
if [ "$local_a" != 'root->local_a' ]; then
    Plan::log.mod -c 1 "read: local_a -- not set in root [FAIL]"
    exit 1
fi

Plan::log.mod 'read: root <- local_b <- local'
if [ -n "$local_b" ]; then
    Plan::log.mod -c 1 "read: local_b -- set in root [FAIL]"
    exit 1
fi

Plan::log.mod -c 2 'OK'
