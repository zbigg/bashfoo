bashfoo_require flag

##
## bashfoo budler - almost bash-package-manager or bash-pack
##
##
##  Build transferable scripts in fashion similar to
##  c/c++ linker and/or javascript webpack.
##
##  Usage:
##
##    Modularized code
##
##       log_exec() {
##            echo "$0: $@"
##            "$@"
##       }
##       my_function() {
##           : bashfoo-import-var DATA_ROOT_DIR
##           : bashfoo-import-fun log_exec
##           : bashfoo-import-fun timeout from bashfoo/timeout # future
##
##           log_exec mkdir -p $DATA_ROOT_DIR/$1
##           timeout 2 curl http://example.com/ > $DATA_ROOT_DIR/$1/index.html
##       }
##
##    Bundle and run code on remote machine
##
##       DATA_ROOT_DIR="/tmp/foo"
##       ssh foo@hot "$(bundle my_function) ; my_function foobar"
##
##     Call to bundle, will "export" `my_function` and all it's dependencies:
##       - `DATA_ROOT_DIR` variable content
##       - `log_exec` local function
##       - `timeout` function as imported from bashfoo/timeout using bashfoo_require
##
##     In such a way that remote bash can interpret it, and `my_function` .can be called.
##
## Problem
##
##   One might ask what problem does it solve. It solves
##   problem or running short (at beginning) scripts using tools like ssh on "remote"
##   shells/machines. Writing script inline works for short one-liners, but as one-liner grows,
##   escaping and \backslashing and semicoloning; everything makes script very awful e.g
##
##    ssh "$target" "set -x ; \
##    tf=\$(readlink -f $rollback_link) ; \
##    tv=\$(basename \$tf) ; \
##    if [ -e \$tf ] ; then \
##        ln -snf \$tf '$current_link' ; \
##        if [ -x '$activate_script' ] ; then echo 'rdt: invoking activate script $activate_script' ; '$activate_script' ; fi \
##    else \
##        echo rdt: unable to find version to rollback: \$tf ; \
##        exit 1 ; \
##    fi ; \
##      echo rdt: last version activated was \$tv"
##    then
##      echo "$0: activated $app_name@$version on $target"
##    fi
##
## So with this script, we can write it as it is normal script:
##
##  function activate_app() {
##      : bashfoo-import-var rollback_link
##      : bashfoo-import-var activate_script
##
##      local tf=$(readlink -f $rollback_link)
##      local tv=$(basename $tf)
##      if [ -e $tf ] ; then
##          ln -snf \$tf '$current_link'
##          if [ -x '$activate_script' ] ; then
##              echo 'rdt: invoking activate script $activate_script'
##             '$activate_script'
##          fi
##      else
##          echo rdt: unable to find version to rollback: $tf
##          exit 1
##      fi
##      echo "rdt: last version activated was $tv"
##  }
##
## And use like this:
##
##    ssh $target "$(bundle activate_app) ; activate_app"
##

export_function()
    ## use_function VAR [ALIAS]
    ##
    ## emits eval-able function source code so it can
    ## be used in target environment
{
    type $1 | tail -n +2
}

export_variable()
    ## use_variable VAR [ALIAS]
    ##
    ## emits eval-able script that
    ## sets VAR (or ALIAS) to actual value
    ## of $VAR from current execution context
{
    local name=${2-$1}
    local value="$(eval echo "\$""$1" | sed -e "s|\([\\\"\\\\]\)|\\\\\1|g")"
    echo "${2-$1}=\"$value\""
}

export_function_recursive_int()
{
    local body="$(use_function "$1")"

    while read type imports ; do
        echo "$1 -> $type $import"  >&2
        if check_flag _imported $import ; then
            echo "$1 -> $$import already included" >&2
            break
        fi
        set_flag _imported $import

        if   [ $type == 'bashfoo-import-var' ] ; then
            export_variable $import
        elif [ $type == 'bashfoo-import-fun' ] ; then
            export_function_recursive_int $import
        else
            echo "$1 -> unknown import type: $type" >&2
            return 1
        fi
    done < <(echo "$body" | egrep --only-matching 'bashfoo-import-(var|fun)\s+([a-z_A-Z0-9-]+)')
    echo "$body"
}

export_function_recursive()
    ##
    ## export_function_recursive NAME
    ##
    ## exports eval-able script which will
    ## contain function NAME and all it's
    ## dependencies as declared by : bashfoo-import-* directives
    ##
{
    _imported=""
    use_function_recursive_int "$1"
    _imported=""
}

bundle()
{
    export_function_recursive "$1"
}
