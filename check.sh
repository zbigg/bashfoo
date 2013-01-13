#!/bin/bash
#
# test driver for bashfoo
#

top_srcdir=${top_srcdir-.}
bashfoo_libdir="${top_srcdir-.}"
source ${top_srcdir}/bashfoo.sh

bashfoo_require test

bashfoo_autotest ${top_srcdir}/*_test.sh ${top_srcdir}/test_test_script1.sh

