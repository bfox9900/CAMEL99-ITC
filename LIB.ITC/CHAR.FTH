
\ CHAR   converts ASCII char to a number (in DSK1.SYSTEM)

\ use for interpret mode
: CHAR    ( -- <c>) BL WORD CHAR+ C@ ;
\ use when compiling a colon definition
: [CHAR]  ( -- <c>) ?COMP CHAR POSTPONE LITERAL ; IMMEDIATE
