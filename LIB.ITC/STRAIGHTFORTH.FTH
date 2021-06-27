\ STRAIGHT in Forth. Rcv bytes into buffer, no echo. bjf Feb 2020
HERE
HEX
: TIMEKEY ( wait-time -- 0 | c )  \ waits for a key until counter hits zero
      BEGIN 1- DUP  WHILE CKEY? ?DUP IF  NIP   EXIT THEN    REPEAT ;

: STRAIGHT ( addr len -- n)
       0 -ROT             \ char counter under address
       OVER >R            \ save the 1st buffer location
       1 /STRING  BOUNDS  ( -- end start)
       R>                 ( -- end start addr)
       KEY SWAP  C!      \ wait for 1st key & store
       DO
          2000 TIMEKEY
          DUP 0=
          IF  DROP LEAVE
          THEN I C!
          1+
       LOOP
;
HERE SWAP - SPACE DECIMAL . .( bytes)
HEX

