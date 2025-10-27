\ Conditional compilation for Camel99 Forth   May 26 2025 BJFOX
\ SOURCE: https://forth-standard.org/standard/tools/BracketELSE

CR .( [IF] [ELSE] [THEN])

NEEDS COMPARE FROM DSK1.COMPARE

: REFILL ( -- ?) \ ?=0 means no input was recieved
  TIB DUP        \ use the terminal input buffer
  SOURCE-ID @    \ 0=console, -1=evaluate, >= 1 is a file
  IF   2 FILEOP ?FILERR FGET ( -- tib len)
  ELSE 80 ACCEPT ( -- tib len)
  THEN
  DUP IF ( len > 0)
       'SOURCE 2!  >IN OFF
        TRUE  \ we got data, return true
        EXIT
  THEN NIP    \ return zero
;

: [ELSE] ( -- )
    1 BEGIN                                \ level
       BEGIN BL WORD COUNT DUP WHILE       \ level adr len
         2DUP S" [IF]" COMPARE 0= IF       \ level adr len
             2DROP 1+                      \ level'
          ELSE                             \ level adr len
            2DUP S" [ELSE]" COMPARE 0= IF  \ level adr len
                2DROP 1- DUP IF 1+ THEN    \ level'
            ELSE                           \ level adr len
                S" [THEN]" COMPARE 0= IF   \ level
                   1-                      \ level'
               THEN
             THEN
          THEN ?DUP 0= IF EXIT THEN        \ level'
       REPEAT 2DROP                        \ level
    REFILL 0= UNTIL                        \ level
    DROP
; IMMEDIATE

: [IF] ( flag -- )  0= IF POSTPONE [ELSE] THEN ; IMMEDIATE
: [THEN] ; IMMEDIATE

: [DEFINED]   BL WORD FIND NIP 0 <> ; IMMEDIATE
: [UNDEFINED] BL WORD FIND NIP 0= ; IMMEDIATE

\ * test code *
HEX
FALSE
[IF]   CR ." [IF] FAILED "
[ELSE] CR ." [ELSE] PASSED "
[THEN]

TRUE
[IF]   CR ." [IF] PASSED "
[ELSE] CR ." [ELSE] FAILED "
[THEN]
