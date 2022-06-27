


: 2OVER   2 PICK 2 PICK ;

: D<   ( d d -- ?) ROT >  IF 2DROP -1  ELSE U<  THEN ;
: D>   ( d d -- ?) D< 0= ;

: READLONG ( addr len -- )
        S>D ROT S>D 2SWAP ( d d)
        2OVER D+ 2SWAP  ( 'end 'start )
        BEGIN
          2OVER 2OVER D>
        0= WHILE
          2DUP  0 0 AT-XY SWAP U. SWAP U.
          2 M+
          ?TERMINAL ABORT" STOP"
        REPEAT
;
