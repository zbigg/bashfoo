#
# logging of shell script activity
#

#
# log_process_options
#   to be used when parsing options
#
# usage:
#
#    if log_process_options $1 ; then shift ; continue ; fi
#
#
log_quiet=0

log_process_options()
{
    if [ "$1" = "--debug" -o "$1" = "-d" ] ; then
        log_debug=1
        return 0
    fi

    if [ "$1" = "--quiet" -o "$1" = "-q" ] ; then
        log_quiet=1
        return 0
    fi

    return 1
}

_log_impl()
{
    if [ -z "${SCRIPT_NAME-}" -a -n "${PNAME-}" ] ; then
        # my legacy scripts all used PNAME
        SCRIPT_NAME=$PNAME
    fi

    if [ -z "${SCRIPT_NAME-}" ] ; then
        local idx=$((${#BASH_SOURCE[*]} -1))
        local source="${BASH_SOURCE[$idx]}"
        SCRIPT_NAME="`basename $source`"
    fi

    echo -e "$SCRIPT_NAME: $*" >&2

}
log_debug()
{
    if [ "$log_debug" = 1 ] ; then
        _log_impl "$*"
    fi
}

log_error()
{
    _log_impl "$*"
}

log_info()
{
    if [ "$log_quiet" != 1 ] ; then
        _log_impl "$*"
    fi
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
    local r=$?
    if [ "$r" != 0 ] ; then
        log_error "-> failed, exit_code=$r"
    fi

    return $r
}
