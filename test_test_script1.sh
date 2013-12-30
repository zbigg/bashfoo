#!/usr/bin/env bash
#
# test script
#
# if bashfoo_autotest can sucessfully and correctly run
# "test scripts"
#

if [ -z "${test_src_dir}" ] ; then
    echo "$0: test_src_dir not defined ... :/"
fi

bashfoo_libdir="${test_src_dir}"
source ${bashfoo_libdir}/bashfoo.sh

bashfoo_require test

source "${test_src_dir}/test_test.sh"

# reuse test_test_environment to check
# if it's correct
test_test_envitonment

