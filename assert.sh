#
# asserts.
#
#  assert_fails    COMMAND        -- assert that command fails
#  assert_succeeds COMMAND        -- assert that command succeeds
#  assert_equals   VALUE VALUE    -- check that values are equal
#
#  assert_grep     REGEXP FILE    -- check that FILE matches REGEXP
#  assert_grepv    REGEXP FILE    -- check that FILE doesn't match REGEXP
#
#  assert_exists   NAMES...       -- check that all NAMES are existing file names
#


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
        log_error "expected '$@' to succeed, but it failed (exit_code=$r)"
        exit 1
    else
        log_info "success: $@ succeeded as expected"
    fi
}


assert_equals()
{
    local expected="$1"
    local actual="$2"
    
    if [ "$expected" != "$actual" ] ; then
        log_error "expected '$expected', but actual value is '$actual'"
        exit 1
    fi
}

secho() {
    echo "$PNAME: $*" 1>&2
}
show_file()
{
    echo "$PNAME: contents of '$1' after last command ($last_command)"
    egrep -H "^" $1
}
assert_grep() {
    egrep -q "$@" || {
        log_error "expected '$1' in '$2' not found"
        show_file $2
        exit 1
    }
}

assert_grepv() {
    
    egrep -qv "$@" || {
        log_error "not expected '$1' found in $2"
        show_file $2
        exit 1
    }
}

assert_exists() {
    local r=0
    for f in "$@" ; do 
        if ! test -f $f ; then
            log_error "expected file '$f' doesn't exist"
            r=1
        fi
    done
    if [ "$r" = 1 ] ; then
        exit 1
    fi
}

