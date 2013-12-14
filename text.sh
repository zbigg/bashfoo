#
# bashfoo.text
#
#  text processing helper functions
#

bashfoo.tac.tac()
{
    tac "$@"
}

bashfoo.tac.tail_rev()
{
    tail -r "$@"
}

#
# TBD, make shalll create feature set file which
# would ultimately tell which tac version shall be used
#
case "$OSTYPE" in
    *linux*|*msys*)
        bashfoo.tac() { 
            bashfoo.tac.tac "$@" 
        }
        ;;
     *darwin*|*)
        bashfoo.tac() { 
             bashfoo.tac.tail_rev "$@" 
        }
        ;;
esac

bashfoo.prefix()
    # bashfoo.prefix <PREFIX>
    #    cat that prefixes all lines with <PREFIX>
{
    local prefix="$1"
    shift
    awk -v "prefix=$prefix" '// {printf("%s%s\n",prefix,$0);}' "$@"
}
