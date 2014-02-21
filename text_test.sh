#
# tests for bashfoo text module
#
bashfoo_require test
bashfoo_require text

#@bashfoo.test test_text_prefix
test_text_prefix()
{
    ( echo "a" ; echo ; echo "zz" ) | bashfoo.prefix FOO: > stdout
    
    assert_equals 3 $(wc -l stdout)
    assert_grep '^FOO:zz$' stdout
    assert_grep '^FOO:$' stdout
    assert_grep '^FOO:a$' stdout
    
    assert_grepv '^a$' stdout
    assert_grepv '^zz$' stdout
    assert_grepv '^$' stdout
}

#@bashfoo.test test_text_tac
test_text_tac()
{
    #set -x
    
    ( echo "a" ; echo "exp" ; echo ; echo "zz" )  > f1
    ( echo "zz" ; echo ; echo "exp"; echo "a" )  > f2
    
    bashfoo.tac f1 > f1.rev
    bashfoo.tac f2 > f2.rev
    
    assert_files_equal f1 f2.rev
    assert_files_equal f2 f1.rev
}

autotest

