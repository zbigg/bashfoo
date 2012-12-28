#
#
# example:
#   set_flag XXX a
#   set_flag YYY b
# then check
#
# if check_flag XXX a ...
#
set_flag()
{
    local name="$1"
    local value="$2"
    
    flag_old_val=$(eval echo "\$""$name")
    eval "$name='$flag_old_val $value'"
}

check_flag()
{
    local name="$1"
    local tested_value="$2"
    flag_val=$(eval echo "\$""$name")
    echo "$flag_val" | tr ' ' '\n' | egrep -q "^$tested_value\$"
    local rv=$?
    return $rv
}

