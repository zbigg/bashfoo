#
# bashfoo.sh
#
#   bootstrap bashfoo environment in script
#  

if [ -z "$bashfoo_libdir" ] ; then
    echo "bashfoo_libdir not set"
    exit 1
fi

source "$bashfoo_libdir/log.sh"
source "$bashfoo_libdir/flag.sh"

set_flag bashfoo_loaded_modules log
set_flag bashfoo_loaded_modules flag

bashfoo_require()
{
    local module="$1"
    
    local module_loaded_flag="${module}_loaded" 
    if ! check_flag bashfoo_loaded_modules $module ; then
        local module_path="$bashfoo_libdir/$module.sh"
        log_debug "loading bashfoo module $module_path"
        source $module_path
        
        set_flag  bashfoo_loaded_modules $module
    fi   
}


