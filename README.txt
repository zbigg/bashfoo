bashfoo - bash helper library

This is next attempt to create reusabble shell script function helper.

Currently it targets only bash, bash-3.x.

In future it shall support also generic POSIX shell.

1. General usage.

1.2 Initialize bashfoo in script.

  In system-based deployments:

    eval `bashfoo --eval-out`

  In local deployments:
  
    bashfoo_source_path=$lib_dir/bashfoo
    source $lib_dir/bashfoo/bashfoo.sh
  
1.3 Use modules:

   In script:
   
     bashfoo_require MODULE_NAME
     
   imports module.
 
2. Modules

2.1 log

    Log a message prefixed with script name to stderr.
    
    script synopsis:
    
        bashfoo_require log        
        log_info "removing user $user from LDAP"
        
    CLI synopsis
        
        $ SCRIPT -d|--debug  -- enable debug mode
        $ SCRIPT -q|--quiet  -- enable quiet mode
        
    Functions:
    
        log_process_options -- process, -d|--debug, -q|--quiet
        log_debug           -- only if debug mode is on
        log_info            -- when not in quiet mode
        log_error           -- always logged
        
   
2.2 introspection
    
     Allows execution of internal bash functions (for debugging)
        
     Script synopsis:
     
         bashfoo_require introspection
         maybe_invoke_introspection "$@"
            
     CLI synopsis
         $ SCRIPT --int-call FUN ARGS
         $ SCRIPT --int-list
         
     First form, calls FUN with ARGS or lists available functions when bad
     FUN name specified.
     Second form just lists names of available functions to be called by 
     introspection.
    
2.3 run
    
    Run commands in specific environment (quiet, verbose or changed folder).
    
    Script synopsis:
    
        bashfoo_require run
        
        run_in SOME_FOLDER log_run quiet git pull  
            # run git pull with stdout/err discarded
            # in changed folder        
            # logs: $SCRIPT ! quiet git pull
            
        if quiet diff A B ; then ...
            #     more or less equal to if diff -q A B but useful for command that 
            #     doesn't suppor -q

        quiet_if_success git pull
            #     cached stdout/err till command end and discard output
            #     if command succeeds
            #     in case of exit_code != log message and whole output is printed
            
2.4 memoize

    Memoized call.
    
    Call a COMMAND with caching it's results. Results are cached for execution
    time of this script.
    
    All cached files are removed using cleanup module.
    
    Script usage:
        bashfoo_require memoize
        
        check_if_tag_exists() {
            memoized git ls-remotes URL | grep -q "tags/$TAG"
        }
    
        
2.5 cleanup
 
    Register cleanup actions.
    
    Sctipt usage
        bashfoo_require cleanup
        
        cleanup_cmd add CMD
        cleanup_file FILE
        cleanup_folder 
        
        cleanup_process_options
        
    CLI usage:
        --no-cleanup    -- don't execute cleanup options, so intermediate
                           files/state is left for debugging
        
    It adds "script" global list of cleanup actions irrelevant of "subprocess" 
    level.
    All cleanup actions are executed upon EXIT trap in reverse order to declaration.
    

