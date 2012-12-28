

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
quiet()
{
    "$@" >/dev/null 2>&1
    return $?
}

quiet_if_success()
{
    local tmp_file=`tmpfile_name quiet_if_success`
    cleanup_file "$tmp_file"
    
    "$@" > $tmp_file 2>&1
    local r=$?
    if [ "$r" != 0 ] ; then
        log "$@ execution failed (exit_code $r), log output follows"
        cat $tmp_file
    fi
    return $r
}

log_run()
{
    log '!' "$@"
        #  TBD: wishlist
        #   we shall support composing of log_run with other
        #   "run modifiers"
        #
        #   log_run quiet git pull
        #     shall log "git pull"
        #     not       "quiet git pull"
        #   we shall shift all "first elements of $@" which are functions
        
    "$@"
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

