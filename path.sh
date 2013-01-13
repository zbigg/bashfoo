#
# path.sh
#
# bashfoo path tools
#

abspath() (
    local target="$1"
    
    if [ -d "$target" ] ; then
        cd $target
        pwd
    else
        local name="$(basename "$target")"
        cd "$(dirname "$target")"
        echo "$(pwd)/${name}"
    fi
)

# jedit: :tabSize=8:indentSize=4:noTabs=true:mode=shell:
