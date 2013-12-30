

# quiet COMMAND
#   execute args as command but be quiet
#   stdout and stderr are discarded
#   exit code is propagated
#
#   example
#     if quiet diff A B ; then ...
#     more or less equal to if diff -q A B but useful for command that 
#     doesn't suppor -q
#

bashfoo_require temp

quiet()
{
    "$@" >/dev/null 2>&1
    return $?
}

quiet_if_success()
{
    #local tmp_file=`tmpfile_name quiet_if_success`
    #cleanup_file "$tmp_file"
    local quiet_if_success_quiet=0
    if [ "$1" = "-q" ] ; then
        quiet_if_success_quiet=1
        shift
    fi
    local tmp_file="$(bashfoo.mktemp quiet-invocation)"
    if ( "$@" ; ) > "$tmp_file" 2>&1 ; then
        return 0
    else
        local r="$?"
        if [ "$quiet_if_success_quiet" != 1 ] ; then
            log_error "$@ execution failed (exit_code $r), log output follows"
        fi
        cat $tmp_file
        return $r
    fi
}

# run_in folder COMMAND
#   execute args as command in specified folder
#   exit code is propagated
#
#   example
#     run_in /etc cat passwd
#
run_in()
{
    (
        cd $1 ; shift
        "$@"
        return $?
    )
    return $?    
}

