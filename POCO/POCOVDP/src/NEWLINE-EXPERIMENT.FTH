: NEWLINE ( -- )
    THELINE# LASTLINE =  \ WORKS in lastline position
    IF
        (DOWN) HOME
        ROW @ SCROLLDN
        VHERE THELINE# ]NODE !
        THELINE# PARTLIST
        1 #LINES 1+!
    RETURN;

    CURPOS @ 0=
    IF \ CR at column zero
        THELINE# WRITE-BACK
        CDOWN HOME
        FCTN-8
    ELSE \ CR at column>0
      \ insert text in middle of file
            THELINE# WRITE-BACK
            THELINE# INSERT-NODE
            (DOWN) HOME
            VHERE THELINE# ]NODE !
            LASTLINE FREE-NODE
            REDRAW \ THELINE# PARTLIST
    THEN ;
