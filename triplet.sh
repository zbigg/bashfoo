#
# bashfoo.triplet
#
#  this module handles robust another incarnation of "object-property-value"
#  file format that may be useful for storing config.
#
#  format is use by avc (https://github.com/zbigg/avc) for it's "config spec"
#
# format specification

# triplet file specification
#
# triplet file is built from one-line object-property-value triplets.
# empty lines are ignored, 
# lines beginning with # are comments.
#
# AVC operates on OBJECTS whose properties are defined in file.
# Each OBJECT is identified, by it's relative path in workspace.
# Workspace is built-up from all OBJECTS that has enough definition
# to be used for particural command.
#
# When '*' (wildcard) is used as object name, then it constitute attribute
# of all objects in triplet file.

# Word '*' in value is replaced with matched current object name.
#
# For, example, of avc file file which use triplet syntax:
#   bar  ref feature-new-ui
#   foo  ref foo-1.3
#   spam ref spam-1.4.1.1
#   * url git+ssh://somehost/*
#   * git.reference_repository /var/cache/git-repos-somehost/*
#
# It yields following two objects: foo, bar with following properties:
#   object bar has properties
#     ref = feature-new-ui
#     url = git+ssh://somehost/bar
#     git.reference_repository = /var/cache/git-repos-somehost/bar
#
#   object foo has properties
#     ref = foo-1.3
#     url = git+ssh://somehost/foo
#     git.reference_repository = /var/cache/git-repos-somehost/foo
#

triplet_all()
    ## triplet_all FILE
    ##
    ## Get names of all objects in FILE.
{
    local file="$1"
    awk '
        /^#/ {
                next;
        }
        /^([^ \t]+)[ \t]+/ {
            if( $1 != "*" ) {
                print $1;
            }
        }
        ' $file | sort -u
}

triplet_get_first()
    ## triplet_get_first FILE OBJECT PROP_NAME
    ##
    ## Get first matching PROP_NAME value of OBJECT 
    ## (triplet file format allows multiple entries with same OBJECT & PROP_NAME)
{
    local file="$1"
    local object="$2"
    local prop="$3"
    awk -v object="$object" '
        /^#/ {
            next;
        }
        /^([^ \t]+)[ \t]+'${prop}'[ \t]+/ {
            found_obj=$1
            if( found_obj == "*" || found_obj == object ) {
                value=$0
                gsub(/^([^ \t]+)[ \t]+([^ \t]+)[ \t]+/, "", value)
                sub(/\*/, found_obj, value);
                printf("%s", value);
                found=1
                exit 0
            }
        }
        END { # TBD, not sure if it is needed as
              # we already call exit above
            if( !found)
                exit 1
        }
    ' $file
    r=$?
    return $r
}

triplet_get_all()
    ## triplet_get_all FILE OBJECT PROP_NAME
    ## 
    ## Get value of all OBJECT properties matching PROP_NAME from FILE
    ## Values are separated by new line (\n)
{
    local file="$1"
    local object="$2"
    local prop="$3"
    awk -v object="$object" '
        /^#/ {
            next;
        }
        /^([^ \t]+)[ \t]+'${prop}'[ \t]+/ {
            found_obj=$1
            if( found_obj == "*" || found_obj == object ) {
                value=$0
                gsub(/^([^ \t]+)[ \t]+([^ \t]+)[ \t]+/, "", value)
                sub(/\*/, found_obj, value);
                if( found )
                    printf("\n");
                printf("%s", value);
                found=1
            }
        }
        END {
            if( !found)
                exit 1
        }
    ' $file
    r=$?
    return $r
}


