#
# usage helpers
#

#
# show "usage" text as parsed from shell script source
# lines beginning with "## " are taken from output
#
# note, the original "top-level" source script is sourced
# BASH_SOURCE is needed for this

bashfoo require log

auto_usage()
{
    local idx="${#BASH_SOURCE[*]}"
    local source="${BASH_SOURCE[$idx-1]]}"
    
    # tbd rewrite as one-shot awk
    cat $source | egrep '^##( |$)' | cut -c4- >&2
}

# exit with message and
# usage text
fail_on_bad_usage()
{
    log_error "$*"
    auto_usage
    exit 1
}

# if "$1" is  generic help option 
#   --help
#   -h
# then invoke auto_usage and exit
#
#  usage example
#  while [ -n "$1" ] ; do
#     maybe_show_auto_help
#     (...)
#     shift
#  done
maybe_show_auto_help()
{
    if [ "$1" = "--help" -o "$1" = "-h" ] ; then
        auto_usage
        exit 0
    fi
}


