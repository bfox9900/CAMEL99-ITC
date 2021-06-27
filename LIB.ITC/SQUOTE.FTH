\ SQUOTE S" extension for Forth 2012

\ 11.3.4 Other transient regions
\ The system provides transient buffers for S" and S\" strings. These buffers
\ shall be no less than 80 characters in length, and there shall be at least
\ two buffers. The system should be able to store two strings defined by
\ sequential use of S" or S\". RAM-limited systems may have environmental
\ restrictions on the number of buffers and their lifetimes.

\ This implementation uses a circular buffer of 256 bytes.
\ It can handle 4 strings of 64 bytes each.
\  S" This is STRING1"  S" This is STRING2"  ( -- adr1 len1 adr2 len2)
\
\ *** LOAD THIS AT START OF PROGRAM IF YOU USE THE HEAP DYNAMICALLY
\ It needs the HEAP buffer forever once it is allocated
NEEDS MALLOC FROM DSK1.MALLOC

HEX
100 MALLOC CONSTANT SBUF            \ allocate a pool buffer
           VARIABLE P               \ string pool pointer

: POOL    ( -- addr) SBUF P @ + ;    \ current pool address
: P+!  ( n -- ) P @ +  FF AND P !  ; \ circular pointer

: S"           ( -- )
               [CHAR] " PARSE   ( -- adr len)
               STATE @
               IF
                  POSTPONE (S")  S, \ action when COMPILING
               ELSE
	                POOL PLACE  \ place string in Pool
                  POOL COUNT  \ return the address and length
                  40 P+!      \ update pool address
               THEN ; IMMEDIATE

POOL 100 0 FILL
