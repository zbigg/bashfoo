#!/bin/bash

bashfoo_require test
bashfoo_require assert
bashfoo_require memoize

test_memoized_result_basics_false()
{
    assert_equals           "" "$bf_memoized_result_false"

    assert_fails            memoized_result false

    assert_variable_present bf_memoized_result_false
    assert_equals           1 "$bf_memoized_result_false"
}

test_memoized_result_basics_true()
{
    assert_equals           "" "$bf_memoized_result_true"

    assert_succeeds memoized_result true

    assert_variable_present bf_memoized_result_true
    assert_equals           0 "$bf_memoized_result_true"
}

autotest
