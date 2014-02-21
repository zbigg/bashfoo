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
        failed_tests="$failed_tests $test_name"
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
        
        quiet_if_success $test_script_file
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

bashfoo_run_test_suite()
{
    while read cmd name dir ; do
        if   [ "$cmd" = standalone ] ; then
            execute_test_script "$name"
        elif [ "$cmd" = function ] ; then
            test_src_dir="$dir"
            execute_test_function "$name"
        elif [ "$cmd" = load ] ; then
            echo "SUITE ${name}"
            source "$(abspath $name)"
        else
            log_error "unknown test command '$cmd' (name=$name, dir=$dir)"
        fi
    done
}

#
# bashfoo_autotest
#
bashfoo_autotest_add_cmd()
{
    if [ -z "$bashfoo_autotest_tmpfile" ] ; then
        bashfoo_autotest_tmpfile="$(bashfoo.mktemp test_suite)"
        rm -rf "$bashfoo_autotest_tmpfile"
    fi
    log_debug "_bashfoo_add_test: $@"
    echo "$@" >> "$bashfoo_autotest_tmpfile"
}

_bashfoo_get_annotated_test_names()
{
    local tab=`echo -en '\t'`
    local bashfoo_test_re="@bashfoo.test[ $tab]+([a-zA-Z_0-9]*)"
    while read line ; do
        if [[ $line =~ $bashfoo_test_re ]] ; then
            echo "${BASH_REMATCH[1]}"
        fi
    done
}

bashfoo_autotest_add_function_tests()
    # adds all functions tagged @bashfoo.test to test suite
{
    for f in "$@" ; do
        local dir="$(dirname $f)"
        local loaded=0
        for match in $(_bashfoo_get_annotated_test_names < $f) ; do
            fun=$match
            if [ "$loaded" = 0 ] ; then
                bashfoo_autotest_add_cmd "load $f $dir"
                loaded=1
            fi
            bashfoo_autotest_add_cmd "function $fun $dir"
        done
    done
}

bashfoo_autotest_add_script_test()
    # adds all script files to test suite
{
    for f in "$@" ; do
        local dir="$(dirname $f)"
        if   [ -f "$f" -a -x "$f" ] ; then
            bashfoo_autotest_add_cmd "standalone $f $dir"
        elif [ -d "$f" -a -x $f/test_driver.sh ] ; then
            bashfoo_autotest_add_cmd "standalone $f/test_driver.sh $f"
        fi
    done
}


bashfoo_test_run_summary()
{
    if [ -n "$something_failed" ] ; then
        log_info "some tests failed ($failed_tests)"
    else
        log_info "all tests succeded"
    fi
    exit $something_failed
}

bashfoo_autotest_run()
{
    if [ -z "$bashfoo_autotest_tmpfile" ] ; then
        log_info "bashfoo_test_run: no tests to run!"
        return 1
    else
        export bashfoo_testing_suspended=1
        bashfoo_run_test_suite < "$bashfoo_autotest_tmpfile"
        unset bashfoo_testing_suspended
        
        bashfoo_test_run_summary
    fi
}

autotest()
{
    if [ -n "$bashfoo_testing_suspended" ] ; then
        return
    else
        bashfoo_autotest_add_function_tests ${BASH_SOURCE[1]}
        bashfoo_autotest_run

        bashfoo_test_run_summary
    fi
}
