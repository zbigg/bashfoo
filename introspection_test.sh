#!/bin/bash

bashfoo_require test
bashfoo_require introspection

test_introspection_list()
{
    test_invoke list_functions
    assert_grep test_introspection_list stdout 
}

autotest
