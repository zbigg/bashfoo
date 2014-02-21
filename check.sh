#!/bin/bash
#
# test driver for bashfoo
#

top_srcdir=${top_srcdir-.}
bashfoo_libdir="${top_srcdir-.}"
source ${top_srcdir}/bashfoo.sh

bashfoo_require test

bashfoo_autotest_add_function_tests ${top_srcdir}/*_test.sh 
bashfoo_autotest_add_script_test ${top_srcdir}/test_test_script1.sh

bashfoo_autotest_run

