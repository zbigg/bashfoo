bashfoo_require text

bashfoo.mktemp.prepare()
{
    if [ -z "$bashfoo_mktemp_template_base" ] ; then
        if [ -n "$SCRIPT_NAME" ] ; then
            bashfoo_mktemp_template_base="$SCRIPT_NAME"
        else
            local idx="${#BASH_SOURCE[*]}"
            bashfoo_mktemp_template_base="$(basename ${BASH_SOURCE[$idx-1]]})"
        fi
        
        if [ -n "$USER" ] ; then
            bashfoo_mktemp_template_base="$USER-$bashfoo_mktemp_template_base"
        fi
        
        local bashfoo_mktemp_temp="${TMP-/tmp}"
        bashfoo_mktemp_template_base="${bashfoo_mktemp_temp}/${bashfoo_mktemp_template_base}"
    fi
    # also first time, generate a name 
    # for temp-file list
    if [ -z "$bashfoo_mktemp_file_list" ] ; then
        bashfoo_mktemp_file_list="$(mktemp "${bashfoo_mktemp_template_base}-filelist-$$-XXXXXXX")"
    fi
}
bashfoo.mktemp.prepare

bashfoo.mktemp.register()
{
    echo "$1" >> "$bashfoo_mktemp_file_list"
}

bashfoo.mktemp() {
    # first time, prepare templace variables
    local localname="${1-file}"
    local result="$(mktemp "${bashfoo_mktemp_template_base}-${localname}-$$-XXXXXXX")"
    echo "$result" >> "$bashfoo_mktemp_file_list"
    
    echo "$result"
}

bashfoo.mktemp.cleanup()
{
    if [ -z "${bashfoo_mktemp_file_list}" ] ; then
        return
    fi
    if [ ! -f "${bashfoo_mktemp_file_list}" ] ; then
        return
    fi
    [ -n "${BASHFOO_DUMP_TEMPFILES-}" ] && echo "CLEANUP of ${bashfoo_mktemp_file_list}"
    (
        #IFS="\n"
        for file in $(bashfoo.tac "${bashfoo_mktemp_file_list}") ; do
            [ -n "${BASHFOO_DUMP_TEMPFILES-}" ] && { echo "START $file" ; cat $file ; echo "END $file" ; }
            rm -rf "$file"
        done
    )
    rm "${bashfoo_mktemp_file_list}"
    [ -n "${BASHFOO_DUMP_TEMPFILES-}" ] && echo "CLEANUP END"
    true
}

trap bashfoo.mktemp.cleanup EXIT
