CR .( Developer Tools to SUPER CART @>6000 )
NEEDS MARKER FROM DSK1.MARKER

MARKER /SCTEST

HEX
: ?SUPERCART
    ['] EXIT A000 U< ABORT" SUPERCART in use!"
    BEEF 6000 !  6000 @ BEEF <> ABORT" SuperCart not found" ;

CR .( Testing for Supercart)
?SUPERCART
CR .( Removing test code)
/SCTEST

: TOOLS ;  \ forget this word to remove tools

\ SAVEDP holds the LINK field of the 1st new word we will create in HI RAM
VARIABLE SAVEDP
LATEST @ CONSTANT KEEP  \ remember latest name field address

  HERE SAVEDP !      \ save the hi-ram dictionary pointer.
  HEX 6000 DP !      \ Move DP to SUPER cart
CR .( Compiling to HEX 6000 ...)

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

DECIMAL
.FREE
CR .( Search Order:)
ORDER
