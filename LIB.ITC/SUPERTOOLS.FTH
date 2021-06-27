CR .( Developer Tools to SUPER CART @>6000 )

HEX
MARKER /SCTEST

: ?SUPERCART
    ['] EXIT A000 U< ABORT" SUPERCART in use!"
    BEEF 6000 !  6000 @ BEEF <> ABORT" SuperCart not found" ;

?SUPERCART

/SCTEST    \ remove test code

\ SAVEDP holds the LINK field of the 1st new word we will create in HI RAM
VARIABLE SAVEDP
LATEST @ CONSTANT KEEP  \ remember latest name field address

CR .( Set up low ram compiling ...)
  HERE SAVEDP !      \ save the dictionary pointer.
  6000 DP !          \ DP points to SUPER cart

HERE   ( to compute space used in SuperCart)
  INCLUDE DSK1.WORDLISTS

ONLY FORTH DEFINITIONS
  INCLUDE DSK1.ELAPSE
  INCLUDE DSK1.TOOLS

VOCABULARY ASSEMBLER
ALSO ASSEMBLER DEFINITIONS
  INCLUDE DSK1.ASM9900
  INCLUDE DSK1.ASMLABELS

HERE SWAP - DECIMAL CR  . .( bytes in super cart)
CR
CR .( Restore high ram compiling ...)
SAVEDP @ DP !     \ restore DP back to original address

FORTH DEFINITIONS
HEX
: REMOVE-TOOLS ( -- )
         KEEP SAVEDP @ !  \ relink the dictionary
         2000 H ! ;       \ init-the heap to low RAM

DECIMAL
.FREE
CR
CR ." Search Order:"
ORDER
