#
# test
#

#@bashfoo.test test_test_envitonment
test_test_envitonment()
{
    assert_variable_present test_name
    assert_variable_present test_src_dir

    assert_exists ${test_src_dir}/test_test_script1.sh
    assert_exists ${test_src_dir}/test_test.sh
}
