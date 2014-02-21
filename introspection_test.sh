#!/bin/bash

bashfoo_require test
bashfoo_require assert
bashfoo_require introspection

#@bashfoo.test test_introspection_list
test_introspection_list()
{
    test_invoke list_functions
    assert_grep test_introspection_list stdout 
}

#@bashfoo.test test_variable_functions
test_variable_functions()
{
    assert_fails variable_exists TTvar
    variable_set TTvar foo

    assert_equals "foo" $TTvar
    assert_equals foo "$(variable_get TTvar)"

    variable_set TTvar spam-bar
    assert_equals "spam-bar" $TTvar
    assert_equals spam-bar "$(variable_get TTvar)"
}

autotest

