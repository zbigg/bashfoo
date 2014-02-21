#
# tests for bashfoo text module
#
bashfoo_require test
bashfoo_require triplet

_test_sample1()
{
    cat << 'EOF'
# comment
bar  ref feature-new-ui
foo  ref foo-1.3
spam ref spam-1.4.1.1
* url git+ssh://somehost/*
* git.reference_repository /var/cache/git-repos-somehost/*
bar  update_cmd xxx baz
bar  update_cmd ./gen.sh
*    update_cmd $HOME/scan_sources.sh
EOF
}

#@bashfoo.test test_triplet_get_first
test_triplet_get_first()
{
    _test_sample1 > test_sample1.txt

    assert_equals feature-new-ui "`triplet_get_first test_sample1.txt bar ref`"
    assert_equals foo-1.3        "`triplet_get_first test_sample1.txt foo ref`"
    assert_equals spam-1.4.1.1   "`triplet_get_first test_sample1.txt spam ref`"
    assert_equals feature-new-ui "`triplet_get_first test_sample1.txt bar ref`"

    assert_equals "xxx baz" "`triplet_get_first test_sample1.txt bar update_cmd`"
}

#@bashfoo.test test_triplet_get_all
test_triplet_get_all()
{
    _test_sample1 > test_sample1.txt
    triplet_get_all test_sample1.txt bar update_cmd | {
        # shall yield two lines, so check them ...
        read C
        assert_equals "xxx baz" "$C"
        read C
        assert_equals "./gen.sh" "$C"
        read C
        assert_equals '$HOME/scan_sources.sh' "$C"
    }
}

autotest

