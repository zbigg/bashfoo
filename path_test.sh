#
# path test suite
#
#

bashfoo_require test
bashfoo_require path

#@bashfoo.test test_path_abspath
test_path_abspath()
{
    local cwd="$(pwd)"
    local parent_cwd="$(cd .. ; pwd)"
    
    assert_equals "$cwd"        "$(abspath .)"
    assert_equals "$parent_cwd" "$(abspath ..)"
}

autotest

# jedit: :tabSize=8:indentSize=4:noTabs=true:mode=shell:

