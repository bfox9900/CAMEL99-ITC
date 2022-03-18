\ SAM 1M memory card COMMON CODE              Feb 2 2022 Brian Fox
\ This file gives us the basics to test the card and turn it on/off
DECIMAL
  24 USER 'R12  \ address of R12 in any Forth workspace
HEX
: SAMSCARD  ( -- ) 1E00 'R12 ! ;   \ select sams card
\ using machine code so we don't need the CRU library
HEX
\ *set the CRU address in 'R12 before using these words*
  CODE 0SBO  ( -- ) 1D00 ,  NEXT, ENDCODE
  CODE 0SBZ  ( -- ) 1E00 ,  NEXT, ENDCODE
  CODE 1SBO  ( -- ) 1D01 ,  NEXT, ENDCODE
  CODE 1SBZ  ( -- ) 1E01 ,  NEXT, ENDCODE

: SAMS-ON   ( -- ) SAMSCARD 1SBO ;  \ enable mapper
: SAMS-OFF  ( -- ) SAMSCARD 1SBZ ;  \ disable mapper

\ * SAMSINI sets 1Mbyte card to "pass-through" condition
: SAMSINI ( -- n)
       SAMSCARD          \ select SAMS card
       0SBO              \ turn card on, enable registers
       0                 \ register value stays on stack
       4000 20           \ register address, # SAMS regs
       BOUNDS ( -- 4100 4000)
       DO
           DUP >< I !    \ swap bytes and write 16 bits to reg
           I C@  OVER <> ABORT" SAMSINI failed"
           01 +          \ next passthru value
       2 +LOOP
       DROP
       0SBZ              \ turn off card, disable registers
;
SAMS-OFF CR .( Init 1M card) SAMSINI
SAMS-ON  CR .( Mapper enabled )
