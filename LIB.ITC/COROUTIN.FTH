\
\ co.fs		Coroutines by continuations.
\
\ http://theforth.net/package/co/current-view/co.fs
\ by HumptyDumpty

\ * Circular Queue. Capacity is power of 2.
\
            VARIABLE HEAD
            VARIABLE TAIL
  128 CELLS CONSTANT CQ#

\ * align by queue capacity
HERE DUP CQ# 1- INVERT AND   CQ# +   SWAP - ALLOT

HERE CQ# ALLOT CONSTANT START
\
: ]LIT     ( n -- )  POSTPONE ]  POSTPONE LITERAL ; IMMEDIATE

: ADJUST   (  -- )   [ CQ# 1- ]LIT AND START + ;
: PUT      ( n-- )   TAIL @ TUCK ! CELL+ ADJUST TAIL ! ;
: TAKE 	   ( --n )   HEAD @ DUP @ SWAP CELL+ ADJUST HEAD ! ;
: 0CQ	   ( --  )   START DUP HEAD ! TAIL ! ; 

  0CQ ( initialize co-routine queue) 

: NOEMPTY? ( --f )   HEAD @ TAIL @ <> ;
: ;CO      ( --  )   TAKE >R ;
\
\ * COROUTINES LEXEME
\
: CO:  ( -- )   R>  PUT ;	  \ Register continuation as coroutine. Exit.
: CO   ( -- )   R>  PUT TAKE >R ; \ Co-route.
: GO   ( -- )   BEGIN NOEMPTY? WHILE ;CO REPEAT ; \ :-)

\
\ * CHANNELS LEXEME
\
: CHAN?  ( a--f )   2@ XOR ;

