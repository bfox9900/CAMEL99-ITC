\ simple ALLOCATE FREE SIZE
\ Limitation: Only the last allocation can accept FREE or RESIZE

MARKER /ALLOCATE

NEEDS .S  FROM DSK1.TOOLS
NEEDS TO  FROM DSK1.VALUES

HEX 2000 H !  \ init the heap to low RAM

   1 CELLS CONSTANT CELL   \ for 32/64 bit compatibility
     2000  CONSTANT SOH    \ start of heap
SOH 1D00 + CONSTANT EOH    \ end of heap (need space for scroll buffer)
           VARIABLE LASTPTR

: HEAP     ( -- addr) H @ ;
: HALLOT   ( n -- )   H +! ;
: HEAP,    ( n -- )   HEAP !  CELL HALLOT ;

: ALLOCATE ( n -- addr ior)
          DUP HEAP +  EOH >
          IF
              TRUE              \ error flag
          ELSE
              DUP HEAP,         \ record the size
              HEAP DUP LASTPTR !
              SWAP HALLOT
              FALSE             \ no error
          THEN ;

\ not ANS Forth but commonly found in systems
: SIZE    ( addr -- 'addr ) CELL - ;

: FREE    ( addr -- ior) \ We can only FREE the last allocation
          LASTPTR @ OVER <> IF  DROP TRUE  EXIT  THEN
          SIZE @ CELL + NEGATE  HALLOT
          FALSE ;     \ No error

: RESIZE  ( addr n -- addr ior)
          OVER LASTPTR @ <> IF  DROP  TRUE  EXIT THEN
          2DUP + EOH >
          IF   TRUE
          ELSE SIZE !   FALSE
          THEN ;

\ Some pointer syntax
: ?PTR  ( flag -- ) ABORT" invalid pointer" ;
: PTR:  ( addr flag -- ) ?PTR CONSTANT ;
: ->    ( addr flag -- ) ?PTR POSTPONE TO ;

100 ALLOCATE PTR: 'Q
100 ALLOCATE PTR: 'X

\ alternative
0 VALUE ^Y
0 VALUE ^Z

200 ALLOCATE -> ^Y
400 ALLOCATE -> ^Z
