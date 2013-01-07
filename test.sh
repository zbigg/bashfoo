#
# testing
#  
#  bashfoo testing library
#
# use cases
#   1) set of *_test.sh files
#   2) tests.sh 
#         bashfoo_require testing
#         bashfoo_autotest *_test.sh
#         
# bashfoo_autotest will
#   for each file it will
#      if file is executable it till execute xxx_test
#      if file is shell script it will source it
#
#   after all it will by introspection execute all bash
#   functions named test_xxx in subprocess as tests
#
#   default test_timeout is 60 seconds unless redefined as follows
#
#    BASHFOO_TESTING_TEST_TIMEOUT=<seconds>
#    BASHFOO_TESTING_TEST_TIMEOUT=disabled

bashfoo_require assert
bashfoo_require log
bashfoo_require run
bashfoo_require introspection

test_invoke()
{
    bashfoo_test_last_command="$@"
    ( "$@" 2>&1 ) | tee stdout
}

skip_test()
{
    echo "$PNAME: skipped ($*)"
    exit 0
}

mark_test_result()
{
    local test_name="$1"
    local exit_code="$2"
    
    if [ "$exit_code" != 0 ]  ; then
        echo "---- $test_name failed! (exit_code=$exit_code)"
        something_failed=1
    fi
}
invoke_test_script()
{
    local test_script_file="$1"
    local test_name="$1"    
    echo "TEST $1 ... (script)"
    (       
        quiet_if_success ./$test_script_file
    )
    local r=$?
    mark_test_result "$test_name" "$r"
}
invoke_test_function()
{
    local test_script_function="$1"
    local test_name="$1"    
    echo "TEST $1 ... (function)"
    (       
        quiet_if_success $test_script_function
    )
    local r=$?
    mark_test_result "$test_name" "$r"
}

bashfoo_invoke_introspection_tests()
{
    for test_function in $(list_functions | egrep '^test_') ; do
        invoke_test_function $test_function
    done
}

bashfoo_autotest()
{
    for test_file in $* ; do
        if [ -x "$test_file" ] ; then
            invoke_test_script "$test_file"
        else
            bashfoo_testing_suspended=1
            source "$test_file"    
            bashfoo_testing_suspended=
        fi    
    done
    
    bashfoo_invoke_introspection_tests
    if [ -n "$something_failed" ] ; then
        log_info "some tests failed"
    else
        log_info "all tests succeded"
    fi
    exit $something_failed
}

autotest()
{
    if [ -n "$bashfoo_testing_suspended" ] ; then
        return
    else
        bashfoo_autotest
    fi
}
