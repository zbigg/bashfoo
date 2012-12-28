echo "output.sh not implemented yet"
exit 1

IDEAS
    testlib
    
    assert lib
    
    
    output lib
    
    
        output_define DATATYPE date user comment        
        output_set_formatter CSV
        
        output DATATYPE value11 value21 value31
        output DATATYPE value12 value22 value32
        
        ???
        outputs:
            date,user,comment
            value11,value21,"value31"
            value12,value22,"value32"
            
            not sure how can I represent multiple DATATYPEs in
            one output stream in CSV
            
            
        output_set_formatter RAW
        
            DATATYPE value11 value21 value31
            DATATYPE value12 value22 value32
            
        output_set_formatter DATATYPE printf "%s user %02s logged in (%s)"
        
            value11 user value21 logged in (value31)
        
        output_set_formatter XML parent_tag=foo
        
            <foo>
                <tag>
                    <date>value11</date>
                    <user>value21</user>
                    <comment>value31</comment>
                </tag>
                <tag>
                    <date>value12</date>
                    ...
             </foo>
        
         same for JSON :)
