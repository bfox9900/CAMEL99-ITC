\ BACKSPLIT.FTH from Neil Baud's (RIP) String Handling words

\ SCAN                ( str len char -- str+i len-i )
\ Look for a particular character in the specified string.

\ SKIP                ( str len char -- str+i len-i )
\ Advance past leading characters in the specified string.

\ BACK                ( str len char -- str len-i )
\ Look for a particular character in the string from the back toward the front.

\ /SPLIT              ( a m a+i m-i -- a+i m-i a i )
\ Split string a m at a+i m-i.

\ Already in CAMEL99 Kernel as CODE words
\ : SCAN           ( str len char -- str+i len-i )
\     >R  BEGIN  DUP WHILE  OVER C@ R@ -
\         WHILE  1 /STRING  REPEAT THEN
\     R> DROP ;

\  : SKIP           ( str len char -- str+i len-i )
\     >R  BEGIN  DUP WHILE  OVER C@ R@ =
\          WHILE  1 /STRING  REPEAT THEN
\      R> DROP ;

: BACK           ( str len char -- str len-i )
    >R
    BEGIN  DUP
    WHILE 1-  2DUP + C@  R@ =
    UNTIL
    1+
    THEN
    R> DROP ;

: /SPLIT  ( a m b n -- b n a m-n )  DUP >R  2SWAP  R> - ;
