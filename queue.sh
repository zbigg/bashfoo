#
# queue.sh
#


queue_read_inotify()
{
    local queue=$1
    local target_folder=$2
         
    (
        cd $queue
        
        # list old files
        ls -1 | awk '{printf(". CLOSE %s\n",$1);}'
        
        # and wait for new events
        exec inotifywait --quiet --monitor --timeout 0 .
    ) | while read root event name ; do
        log_debug "queue_read_inotify: $root $event $name"
        if [[ $name = *.tmp ]] ; then
            log_info "queue_read_inotify $queue, ignoring tmp file $name"
            continue
        fi
        case $event in
            *CLOSE*|*MOVED_TO*)
                if ! mv $queue/$name $target_folder ; then
                    log_error "queue_read_inotify: unable to move 'queue/$name' to '$target_folder', queue broken, stopping read"
                    exit 1
                fi
                echo $name
                ;;
            *)
                log_debug "queue_read_inotify: $queue, ignoring events $event"
                ;;
        esac
    done
}

QUEUE_READ_SLEEP_INTERVAL=${QUEUE_READ_SLEEP_INTERVAL-10}
queue_read_sleep()
{
    local queue=$1
    local target_folder=$2
         
    while true ; do
        # periodiclaly just list all files
        
        ls -1 $queue | while read name ; do
            log_debug "queue_read_sleep: $name"
            if [[ $name = *.tmp ]] ; then
                log_info "queue_read_sleep: $queue, ignoring tmp file $name"
                continue
            fi
            if ! mv $queue/$name $target_folder ; then
                log_error "queue_read_sleep: unable to move 'queue/$name' to '$target_folder', queue broken, stopping read"
                exit 1
            fi
            echo $name
        done
        sleep ${QUEUE_READ_SLEEP_INTERVAL}
    done
}

queue_read()
{
    queue_read_inotify "$@"
}
