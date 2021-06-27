\ wordlist.fth   for CAMEL99 FORTH    Oct 2020 Brian Fox
\ Code adapted from Web: https://forth-standard.org/standard/search
\ Dec 2020: Removed SET-CURRENT to save precious bytes
\ Jan 5, 2020: back migrated some enhancements from CODEX work
\ Jun 4, 2021: Changed order of patching to work with TTY version
\ 'wid' is a word-list ID.
\ In Camel Forth, wid is a pointer to a Name Field Address (NFA)
\ It is a counted string of the last word defined in the wordlist.

\ This implementation uses a pre-defined CONTEXT array to hold the
\ ROOT wordlist plus 8 user defined wordlists.

\ NEEDS .S   FROM DSK1.TOOLS ( Debugging)

HERE
DECIMAL
  VARIABLE WID-LINK   \ Pointer to the most recently defined wordlist
1 CREATE #ORDER  ,    \ No. of active wordlists starts at 1

: WORDLIST ( -- wid)
   HERE  0 ,                \ nfa of last word defined in wordlist
   WID-LINK @ , WID-LINK !  \ link to previous wordlist
   LATEST @ ,               \ compile NFA of the name of this wordlist
;

HEX
: .WID  ( wid -- ) [ 2 CELLS ] LITERAL + @ COUNT 1F AND TYPE SPACE ;

CREATE FORTH-WORDLIST  WORDLIST
CREATE ROOT   WORDLIST

\ : ]CONTEXT ( n -- addr) CELLS CONTEXT + ; \ context as array
HEX ( Machine code is same size but faster)
CODE ]CONTEXT ( n -- addr)
     A104 ,            \ TOS TOS ADD,
     0224 , CONTEXT ,  \ TOS CONTEXT AI,
     NEXT,
     ENDCODE
.( .)
: GET-ORDER ( -- widn ... wid1 n ) \ *reversed order on stack
     #ORDER @ 0 ?DO   #ORDER @ I - 1- ]CONTEXT @   LOOP   #ORDER @ ;

DECIMAL
: SET-ORDER ( wid1x ... wid1 n -- )  \ n cannot be 0
     DUP  9 1 WITHIN ABORT" #ORDER range[1..8]"
     DUP #ORDER !  0 ?DO  I ]CONTEXT !  LOOP
;

: ONLY ( -- ) ROOT DUP 2 SET-ORDER ;  \ set search order to ROOT ROOT

: SET-CONTEXT ( wid -- )    \ place 'wid' at beginning of search order
     DUP TRUE = IF DROP ONLY EXIT THEN  \ Forth 2012 requirement.
     >R GET-ORDER NIP       \ remove 1st wordlist
     R> SWAP SET-ORDER      \ put 'wid' first
;

\ User API
: ALSO ( -- ) GET-ORDER OVER SWAP 1+ SET-ORDER ;
: PREVIOUS    ( -- ) GET-ORDER NIP 1- SET-ORDER ;
: DEFINITIONS ( -- ) CONTEXT @ CURRENT ! ;
.( .)
\ non-standard but nice to have
: VOCABULARY  ( wid -- ) CREATE   WORDLIST    DOES> SET-CONTEXT ;

: ORDER ( -- )
   CR  GET-ORDER 0 DO   .WID   LOOP
   CR ." Current: " CURRENT @ .WID CR ;

: FORTH  ( -- ) FORTH-WORDLIST SET-CONTEXT ;

   CONTEXT @ @ FORTH-WORDLIST !  \ patch FORTH-WORDLIST to existing dictionary

   ROOT FORTH-WORDLIST 2 SET-ORDER


\ 6.1.1550 Extend FIND to search all active wordlists
:NONAME ( FIND12) ( c-addr -- c-addr 0 | xt 1 | xt -1 )
      FALSE             \ default flag
      CONTEXT #ORDER @ CELLS ( -- addr size)
      BOUNDS  \ compute end-address,start-address
      ?DO     \ I is the address for faster searches
          OVER I @ @ (FIND)
          ?DUP
          IF
              2SWAP 2DROP
              LEAVE
          THEN
          DROP
      2 +LOOP ;  'FIND !   \ patch FIND to become FIND12

\ "minimum search order shall include the words FORTH-WORDLIST & SET-ORDER
ROOT CURRENT !

: FORTH-WORDLIST  FORTH-WORDLIST ;
: SET-ORDER       SET-ORDER ;
: FORTH  FORTH ;
: ONLY   ONLY  ;
: ORDER  ORDER ;
\ Not in GForth ROOT. You might want/need them
\ : ALSO   ALSO  ;
\ : DEFINITIONS  DEFINITIONS ;
.( .)
ONLY FORTH DEFINITIONS

HERE SWAP - DECIMAL SPACE . .( bytes) CR
HEX
