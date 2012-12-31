#
# timeout test suite
#
#

bashfoo_libdir=.
source bashfoo.sh

bashfoo_require log
bashfoo_require timeout

assert_fails()
{
    "$@"
    local r=$?
    if [ "$r" = 0 ] ; then
        log_error "expected '$@' to fail, but it succeeded (exit_code=$r)"
        exit 1
    else
        log_info "success: $@ failed (exit_code=$r) as expected"
    fi
}

assert_succeeds()
{
    "$@"
    local r=$?
    if [ "$r" != 0 ] ; then
        log_error "expected '$@' to succeed, but it failed(exit_code=$r)"
        exit 1
    else
        log_info "success: $@ succeeded as expected"
    fi
}

test_timeout_passes_exit_code()
{
    assert_succeeds with_timeout 10 true
    assert_fails    with_timeout 10 false
}

test_timeout_basics()
{
    assert_fails with_timeout 1 sleep 10
    assert_fails with_timeout 1 sleep 2
}

test_timeout_passes_exit_code
test_timeout_basics

# jedit: :tabSize=8:indentSize=4:noTabs=true:mode=shell:

