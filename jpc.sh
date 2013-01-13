#!/bin/bash

eval `./bashfoo --eval-out`
bashfoo_require queue
bashfoo_require log
rule_file=$1

# TBD, parse source or get from command line


var_dir=.

readonly inbox_dir="$var_dir/inbox"
readonly in_progress_dir="$var_dir/working"

readonly failed_dir="$var_dir/done/failed"
readonly partially_failed_dir="$var_dir/done/partially_failed"
readonly succeded_dir="$var_dir/done/succeded"
readonly interrupted_dir="$var_dir/done/interrupted"

rule()
{
    # job_id
    quiet_if_success "$@"
    
    # TBD, in case of failure save output in 
    # $failed_dir/$job_id_something.failed.log
}

#
# move all jobs from in_progress_dir to
# interrupted_dir
#

queue_restore "$interrupted_dir" "$in_progress_dir"

mkdir -p "$inbox_dir"
mkdir -p "$in_progress_dir"

queue_read "$inbox_dir" "$in_progress_dir" | while read job_id ; do
    
    job_file="$in_progress_dir/$job_id"
    
    #check_exists $job_file || continue
    
    log_info "processing job: $job_id ($job_file)"
    
    pattern_matches=0
    something_succeeded=0
    something_failed=0
    
    while read COMMAND REST; do
        
        case $COMMAND in
        \#*)
            true
            ;;
        *pattern*)
            pattern_matches=0
            if [[ "$job_id" == $REST ]] ; then
                #echo "pattern $REST matches"
                pattern_matches=1
            fi
            ;;
        *rule*)
            if [[ $pattern_matches == 1 ]] ; then
                log_info "executing rule $REST (job $job_id)"
                if $REST ; then
                    something_succeeded=1
                else
                    something_failed=0
                fi
            fi
            ;;
        *variable*)
            echo "variable $REST"
            ;;
        esac
    done < $rule_file
    
    #
    # now save the results somewhere
    #
    if [ "$something_succeeded" = 1 ] ; then
        if [ "$something_failed" = 1 ] ; then
            mkdir -p "$partially_failed_dir"
            mv $job_file "$partially_failed_dir"
            log_info "result: partial fail, moving $job_id to $partially_failed_dir"
        else
            #log_info "result: success, moving $job_id to $succeded_dir"
            mkdir -p "$succeded_dir"
            mv $job_file "$succeded_dir"
        fi
    else
        log_info "result: fail, moving $job_id to $failed_dir" 
        mkdir -p "$failed_dir"
        mv $job_file "$failed_dir"
    fi
    
done        

