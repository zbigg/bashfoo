#!/bin/sh

#bashfoo_require temp

normalize_name_as_file()
{
    echo "$@" | tr "/{} \"'" "_______"
}

memoized()
{
    #set -x
    local mangled_file_name="$(normalize_name_as_file $@)"
    
    #TBD, consider bashfoo.mktempname (which doesn't exist yet)
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

memoized_result()
{
    local mangled_file_name="bf_memoized_result_$(normalize_name_as_file $@)"
    if ! variable_exists "$mangled_file_name" ; then
        if "$@" ; then
            local r=0
        else
            local r=$?
        fi
        variable_set "$mangled_file_name" "$r" 
    else
        local r="$(variable_get "$mangled_file_name")"
    fi
    return $r
}

clean_memoize_cache()
{
    if [ -n "$memoized_files" ] ; then
        #rm -rf $memoized_files
        true
    fi
}
