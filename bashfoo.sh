#
# bashfoo.sh
#
#   bootstrap bashfoo environment in script
#  

if [ -z "$bashfoo_source_path" ] ; then
    echo "bashfoo_source_path not set"
    exit 1
fi

source "$bashfoo_source_path/log.sh"
source "$bashfoo_source_path/flag.sh"

set_flag bashfoo_loaded_modules log
set_flag bashfoo_loaded_modules flag

bashfoo_require()
{
    local module="$1"
    
    local module_loaded_flag="${module}_loaded" 
    if ! check_flag bashfoo_loaded_modules $module ; then
        local module_path="$bashfoo_source_path/$module.sh"
        log_debug "loading bashfoo module $module_path"
        source $module_path
        
        set_flag  bashfoo_loaded_modules $module
    fi   
}


