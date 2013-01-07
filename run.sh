

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
    #local tmp_file=`tmpfile_name quiet_if_success`
    #cleanup_file "$tmp_file"
    local tmp_file=/tmp/.$USER--$$--bashfoo--quiet-if-success
    
    "$@" > $tmp_file 2>&1
    local r=$?
    if [ "$r" != 0 ] ; then
        log "$@ execution failed (exit_code $r), log output follows"
        cat $tmp_file
    fi
    rm -rf $tmp_file
    return $r
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

