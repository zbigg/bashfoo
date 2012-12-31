#
# bashfoo  timeout
#
#
#
# with_timeout SECONDS COMMAND...
#

with_timeout()
{
    local timeout=$1
    shift
    
    local mark_timeout=.timeout_finished
    local mark_cmd_finished=.cmd_finished
    local result_file=.result
    
    # remove temporaries
    rm -rf $mark_timeout $mark_cmd_finished $result_file
    
    # spawn command control subprocess ($cmd_pid)
    (
        exec "$@"
    ) &
    local cmd_pid=$!
    
    # spawn timeout control subprocess $(timeout_pid)
    
    (
        sleep $timeout
        if [ ! -f "$mark_cmd_finished" ] ; then
            log_error "timeout ${timeout}s reached for '$@', terminating job"
            echo "timeout" >> "$result_file"
            kill -TERM $cmd_pid
            sleep 10
            log_error "command '$@' still alive, KILL-ing it"
            kill -KILL $cmd_pid
        fi
        touch "$mark_timeout"
    ) &
    local timeout_pid=$!
    
    # wait for command subprocess
    wait $cmd_pid 2>/dev/null

    # save the result    
    local command_result=$?
    touch "$mark_cmd_finished"
    
    log_debug "job done -> $command_result"
    echo "$command_result" >> "$result_file"
    
    
    if [ ! -f "$mark_timeout" ] ; then
        log_debug "killing timeout job"
        kill -TERM $timeout_pid 2>/dev/null
    fi
    
    # and for timeout subprocess
    wait 2>/dev/null
    result="$(cat "$result_file")"
    
    # remove temporaries
    rm -rf $mark_timeout $mark_cmd_finished $result_file
    
    log_debug "done, result -> '$result'"
    if [ "$result" = 0 ] ; then
        return 0
    else
        return 1
    fi
}
# jedit: :tabSize=8:indentSize=4:noTabs=true:mode=shell:

