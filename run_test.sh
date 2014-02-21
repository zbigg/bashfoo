#!/bin/bash

bashfoo_require test
bashfoo_require assert
bashfoo_require run

#@bashfoo.test test_quiet_if_success_conveys_exit_code
test_quiet_if_success_conveys_exit_code()
{
    assert_succeeds quiet_if_success true
    assert_fails    quiet_if_success false
}

_failing_fun_return()
{
    echo "_failing_fun_return: error foobar"
    return 1
}

_failing_fun_exit()
{
    echo "_failing_fun_exit: error foobar"
    exit 1
}


#@bashfoo.test test_quiet_if_success_outputs_failed_command_output_return
test_quiet_if_success_outputs_failed_command_output_return()
{
    quiet_if_success _failing_fun_return >& out1 || true
    assert_grep    "_failing_fun_return: error foobar" out1
}

#@bashfoo.test test_quiet_if_success_outputs_failed_command_output_exit
test_quiet_if_success_outputs_failed_command_output_exit()
{
    quiet_if_success _failing_fun_exit >& out1 || true
    assert_grep    "_failing_fun_exit: error foobar" out1
}

autotest
