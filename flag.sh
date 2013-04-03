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
    ##   set_flag VARIABLE FLAG
    ##
    ##   enable FLAG in VARIABLE
    ##   logicaly equivalent to VARIABLE ||= FLAG
    ##
    ##   example
    ##      check_flag modules_loaded log --> failure
    ##      set_flag modules_loaded log
    ##      check_flag modules_loaded log --> success
    ##      check_flag modules_loaded foo --> success
    ##      set_flag modules_loaded foo
    ##      check_flag modules_loaded log --> success
    ##      check_flag modules_loaded foo --> success
{
    local name="$1"
    local value="$2"
    
    flag_old_val=$(eval echo "\$""$name")
    eval "$name='$flag_old_val $value'"
}

check_flag()
    ##   check_flag VARIABLE FLAG
    ##  
    ##   check if FLAG is set in VARIABLE
    ##   logicaly equivalent to set_contains($VARIABLE,FLAG)
    ##
    ##   example
    ##      check_flag modules_loaded log --> failure
    ##      set_flag modules_loaded log
    ##      check_flag modules_loaded log --> success
    ##      check_flag modules_loaded foo --> success
    ##      set_flag modules_loaded foo
    ##      check_flag modules_loaded log --> success
    ##      check_flag modules_loaded foo --> success
{
    local name="$1"
    local tested_value="$2"
    flag_val=$(eval echo "\$""$name")
    echo "$flag_val" | tr ' ' '\n' | egrep -q "^$tested_value\$"
    local rv=$?
    return $rv
}

