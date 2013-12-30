#
# queue.sh
#
# Filesystem queue routines.
#

#
# queue_read
#
queue_read()
    ##   queue_read Q_FOLDER T_FOLDER
    ##
    ##   Waits for files to appear in Q_FOLDER and if a file is detected
    ##   then it atomicatlly moves it to T_FOLDER and yields
    ##   name of file on stdout as single line.
    ##
    ##   All old files are reported on function start.
    ##   *.tmp files are ignored.
    ##   inotify is used when available (inotifywait interface is used), 
    ##   elsewhere, folder is polled periodically (default $QUEUE_READ_SLEEP_INTERVAL=10)
{
    if exists_in_path inotifywait ; then
        queue_read_inotify "$@"
    else
        queue_read_sleep "$@"
    fi
}

#
# restore jobs that were not necessarily
# handled after reading.
#
queue_restore()
    ##   queue_restore Q_FOLDER T_FOLDER
    ##
    ##   Puts back all files existing in T_FOLDER back into Q_FOLDER.
    ##
    ##   Useful, on start of scripts that use 'queue_read' and were
    ##   potentially aborted and files shall be processed again.
{
    local queue="$1"
    local target_folder="$2"

    if [ -d "$target_folder" ] ; then

        for file in $(ls -1 "$target_folder") ; do
            mkdir -p "$queue"
            mv "$target_folder/$file" "$queue" 
        done
    fi
}

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

exists_in_path()
{
    type $1 >/dev/null 2>&1
}

