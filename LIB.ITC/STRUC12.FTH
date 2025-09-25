\ forth 2012 structures
\ A.15 The optional Facility word set

\ These words are part of the standard but are not required.
\ Due to the small memory in the TI-99 we took the smaller option
\ : BEGIN-STRUCTURE  \ -- addr 0 ; -- size
\   CREATE
\     HERE 0 0 ,        \ mark stack, lay dummy
\   DOES> @             \ -- rec-len
\ ;

\ : END-STRUCTURE  \ addr n --
\   SWAP ! ;          \ set len

\ NEEDS .S FROM DSK1.TOOLS

DECIMAL
: +FIELD  \ n <"name"> -- ; Exec: addr -- 'addr
   CREATE OVER , +
   DOES> @  + ;

\ using +field you can make your own field descriptors.
: FIELD:    ( n1 "name" -- n2 ; addr1 -- addr2 ) ALIGNED 1 CELLS +FIELD ;
: 2FIELD:   ( d1 "name" -- d2 ; addr1 -- addr2 ) ALIGNED 2 CELLS +FIELD ;
: CFIELD:   ( n1 "name" -- n2 ; addr1 -- addr2 )         1 CHARS +FIELD ;

\ additions by BF
: CELLS:    ( n -- )  CELLS +FIELD ;

\ we can add string size tests for a CHARS: field
: ?STRING   ( n -- n) DUP 1 256 WITHIN 0= ABORT" bad string length" ;
: CHARS:    ( n -- ) ?STRING CHARS +FIELD ;  ( CHARS is a NOOP on 9900)
