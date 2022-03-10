\ wordlist.fth   for CAMEL99 FORTH    Oct 2020 Brian Fox
\ Code adapted from Web: https://forth-standard.org/standard/search
\ Dec 2020: Removed SET-CURRENT to save precious bytes
\ Jan 5, 2020: back migrated some enhancements from CODEX work
\ Jun 4, 2021: Changed order of patching to work with TTY version
\ Sep 25, 2021: Corrected SET-CONTEXT, Removed ROOT to save space.
\ Feb 23, 2022: Added INIT-WORDLISTS for binary program startup
\ --------
\ 'wid' is a word-list ID.
\ In Camel Forth, wid is a pointer to a Name Field Address (NFA)
\ ie: a counted string of the last word defined in the wordlist.

\ The kernel program has a pre-defined CONTEXT array to hold the
\ Forth wordlist plus 8 user defined wordlists.

\ NEEDS .S   FROM DSK1.TOOLS ( Debugging)

HERE
DECIMAL
CREATE #ORDER  1 ,  \ No. of active wordlists starts at 1
VARIABLE WID-LINK   \ Pointer to the most recently defined wordlist

: WORDLIST ( -- wid)
   HERE
   0 ,               \ init nfa of last word in wordlist
   WID-LINK @ ,      \ compile link to previous wordlist
   DUP WID-LINK !    \ link to previous wordlist
   0 ,               \ name of this wordlist. Must be patched
;

CREATE ROOT            WORDLIST   LATEST @ SWAP 4 + !
CREATE FORTH-WORDLIST  WORDLIST   LATEST @ SWAP 4 + !

HEX
: .WID  ( wid -- )
  [ 2 CELLS ] LITERAL + @
  ?DUP 0= IF EXIT THEN   \ name field is empty.
  COUNT 1F AND TYPE SPACE ;

\ : ]CONTEXT ( n -- addr) CELLS CONTEXT + ; \ context as array
HEX ( Machine code is same size but faster)
CODE ]CONTEXT ( n -- addr)
     A104 ,            \ TOS TOS ADD,
     0224 , CONTEXT ,  \ TOS CONTEXT AI,
     NEXT,
     ENDCODE

.( .)
: GET-ORDER ( -- widn ... wid1 n ) \ *reversed order on stack
     #ORDER @  0 DO   #ORDER @ I - 1- ]CONTEXT @   LOOP  #ORDER @  ;

DECIMAL
: SET-ORDER ( wid1x ... wid1 n -- )  \ n cannot be 0
     DUP 0< IF DROP  ROOT FORTH-WORDLIST 2  THEN
     DUP #ORDER !  0 ?DO  I ]CONTEXT !  LOOP
;

: ONLY ( -- ) TRUE SET-ORDER ;  \ set search order to FORTH FORTH

: SET-CONTEXT ( wid -- )    \ place 'wid' at beginning of search order
     >R GET-ORDER NIP       \ remove 1st wordlist
     R> SWAP SET-ORDER      \ put 'wid' first
;

\ User API
: ALSO ( -- ) GET-ORDER OVER SWAP 1+ SET-ORDER ;
: PREVIOUS    ( -- ) GET-ORDER NIP 1- SET-ORDER ;
: DEFINITIONS ( -- ) CONTEXT @ CURRENT ! ;
.( .)
\ non-standard but nice to have
: VOCABULARY  ( wid -- )
   CREATE
   WORDLIST   LATEST @ SWAP 4 + !  \ update wordlist name field
   DOES> SET-CONTEXT ;

: ORDER ( -- )
   CR  GET-ORDER 0 DO   .WID   LOOP
   CR ." Current: " CURRENT @ .WID CR ;

: FORTH  ( -- ) FORTH-WORDLIST SET-CONTEXT ;

\ patch FORTH-WORDLIST to existing dictionary
   CONTEXT @ @ FORTH-WORDLIST !

\ set the new search order and current vocabulary
ONLY FORTH DEFINITIONS

\ 6.1.1550 Extend FIND to search all active wordlists
\ Forth 2012 6.1.1550, Extend FIND to search all active wordlists
: FIND12 ( FIND12) ( c-addr -- c-addr 0 | xt 1 | xt -1 )
      FALSE   \ default flag
      CONTEXT #ORDER @ CELLS ( -- addr size)
      BOUNDS
      ?DO
          OVER I @ @ (FIND)
          ?DUP
          IF
              2SWAP 2DROP
              LEAVE
          THEN
          DROP
      2 +LOOP ;

' FIND12 'FIND !
ONLY FORTH DEFINITIONS

 ROOT CURRENT !  \ compile into ROOT-WORDLIST
\ " minimum search order shall include the words FORTH-WORDLIST & SET-ORDER"
: FORTH-WORDLIST  FORTH-WORDLIST ;
: SET-ORDER       SET-ORDER ;
: FORTH  FORTH ;
: ROOT   ROOT  ;
: ONLY   ONLY  ;
: ORDER  ORDER ;
\ : ALSO   ALSO  ;
\ : DEFINITIONS  DEFINITIONS ;

: INIT-WORDLISTS
    ['] FIND12 'FIND !
    CONTEXT @ @ FORTH-WORDLIST !
    ONLY FORTH DEFINITIONS
;

INIT-WORDLISTS

CR HERE SWAP - DECIMAL SPACE . .( bytes)
HEX
