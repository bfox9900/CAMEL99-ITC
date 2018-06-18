\ factorial recursive code demo

\ NOTE: include TRACE.FTH first to see the recursion stack effects

: FACTORIAL ( n -- )
            DUP 1 > 
            IF 
               DUP 1- RECURSE *
            THEN ;
            
            