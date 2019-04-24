\ GROM access without assembler     July 2017 B Fox
HEX
\ not needed. saves space to use literal no.s
\ 9800 CONSTANT GREAD-DATA     ( GROM base)
\ 9802 CONSTANT GREAD-ADDR
\ 9C00 CONSTANT GWRITE-DATA
\ 9C02 CONSTANT GWRITE-ADDR

: GROM   ( addr -- ) \ set grom address
         SPLIT  9C02 C!  9C02 C! ;

: GC@+  ( -- c)  9800 C@ ;  \ GROM char fetch, w/auto-incr


: GTYPE  ( adr cnt -- )
         GROM
         0 DO
              GC@+ DUP  BL 1-  [CHAR] ~ WITHIN 0=  \ check for printable char (from SPACE to ASCII '~'
              IF DROP  [CHAR] .                    \ replace unprintable chars with '.'
              ELSE EMIT
              THEN
         LOOP ;
