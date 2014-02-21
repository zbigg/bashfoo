#
# timeout test suite
#
#

bashfoo_require test
bashfoo_require timeout

#@bashfoo.test test_timeout_passes_exit_code
test_timeout_passes_exit_code()
{
    assert_succeeds with_timeout 10 true
    assert_fails    with_timeout 10 false
}

#@bashfoo.test test_timeout_basics
test_timeout_basics()
{
    assert_fails with_timeout 1 sleep 10
    assert_fails with_timeout 1 sleep 2
}

autotest

# jedit: :tabSize=8:indentSize=4:noTabs=true:mode=shell:

