#!/bin/sh

normalize_name_as_file()
{
    echo "$@" | tr "/{} \"'" "_______"
}

memoized()
{
    #set -x
    local mangled_file_name="$(normalize_name_as_file $@)"
    local tmp_cached_file_name="/tmp/.memoized_$USER_$$_$mangled_file_name"
    if [ ! -f $tmp_cached_file_name ] ; then
        "$@" > $tmp_cached_file_name
        local r="$?"
        if [ "$r" = 1 ] ; then
            cat $tmp_cached_file_name
            rm -rf $tmp_cached_file_name
            return $r
        else
            memoized_files="$memoized_files $tmp_cached_file_name"
        fi
    #else
    #    log "reusing output for $*"
    fi
    #set +x
    cat $tmp_cached_file_name
}

clean_memoize_cache()
{
    if [ -n "$memoized_files" ] ; then
        #rm -rf $memoized_files
        true
    fi
}
