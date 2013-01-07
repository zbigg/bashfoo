#!/bin/bash
#
# test driver for bashfoo
#

bashfoo_libdir=.
source bashfoo.sh

bashfoo_require test

bashfoo_autotest *_test.sh

