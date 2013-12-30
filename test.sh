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
bashfoo_require path
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
execute_test_script()
{
    local test_script_file="$1"
    local test_name="${2-$(basename $1)}"
    echo "TEST ${test_name} ... (script)"
    (
        local dir="$(dirname $test_script_file)"
        export test_src_dir="$(abspath $dir)"
        export test_name
        
        quiet_if_success ./$test_script_file
    )
    local r=$?
    mark_test_result "$test_name" "$r"
    return $r
}

execute_test_function_int()
(
    export test_name
    quiet_if_success $test_function
)
execute_test_function()
{
    local test_function="$1"
    local test_name="$(basename $1)"
    echo "TEST $test_name ... (function)"
    if execute_test_function_int ; then
        mark_test_result "$test_name" "0"
    else
        mark_test_result "$test_name" "$?"
    fi
    
}

execute_all_test_functions()
{
    for test_function in $(list_functions | egrep '^test_' | egrep -v "^test_invoke") ; do
        execute_test_function $test_function
    done
}

execute_tests_from_script()
{
    local test_script_file="$1"
    echo "SUITE ${test_script_file}"
    (
        local dir="$(dirname $test_script_file)"
        export test_src_dir="$(abspath $dir)"
        source $test_script_file
        
        execute_all_test_functions
        exit $something_failed
    )
}

# bashfoo_autotest <test scripts>
#  executes test scripts (executable) in cotrolled environment
#   - log test execution if failed
#   - OOS build supported, test_src_dir shall be used
#     to access auxilirary files in source tree
#   - timeout (not yet added)
#   - aggregate all results in exit code
#
#  if param is executable script then it is executted
#  otherwise, script is sourced and
#  all functions named test_ are executed as a test
#

bashfoo_autotest()
{
    for test in $* ; do
        if [ -d "$test" ] ; then
            if [ -x "$test/test_driver.sh" ] ; then
                execute_test_script "$test/test_driver.sh" "$(basename $test)" 
            else
                log_error "folder $test doesn't contain test_driver.sh"
            fi
        elif [ -x "$test" ] ; then
            execute_test_script "$test"
        else
            export bashfoo_testing_suspended=1
            execute_tests_from_script "$test"
            bashfoo_testing_suspended=
        fi    
    done
    
    
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
        execute_all_test_functions
        
        if [ -n "$something_failed" ] ; then
	    log_info "some tests failed"
        else
	    log_info "all tests succeded"
        fi
        exit $something_failed
    fi
}
