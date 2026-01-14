\ SAMS CARD support for FbForth   Oct 2020  B Fox
\ 64K segmented memory model for DATA

HERE
HEX
8300 0C 2 * + CONSTANT 'R12   \ Assumes workspace=>8300

\ *** SET DMEM TO YOUR RAM PAGE ***
\ Legal values: 2000,3000,A000,B000,C000,D000,E000,F000

D000 CONSTANT DMEM    \ CPU RAM memory block location
0020 CONSTANT #REGS   \ # sams Registers, ie: size of card >20 is 1Mbyte
   0 VARIABLE SEG     \ holds current 64K segment
   0 VARIABLE BANK#   \ current mapped bank

\ using machine code so we don't need the Assembler
HEX
\ *set the CRU address in 'R12 before using these words*
  ASM: 0SBO ( -- ) 1D00 ,  ;ASM
  ASM: 0SBZ ( -- ) 1E00 ,  ;ASM
  ASM: 1SBO ( -- ) 1D01 ,  ;ASM
  ASM: 1SBZ ( -- ) 1E01 ,  ;ASM

: SAMSCARD  ( -- ) 1E00 'R12 ! ;    \ select sams card


: SAMS-ON   ( -- ) 'R12 @ >R SAMSCARD 1SBO  R> 'R12 ! ;  \ enable mapper
: SAMS-OFF  ( -- ) 'R12 @ >R SAMSCARD 1SBZ  R> 'R12 ! ;  \ disable mapper

ASM: 0LIMI    0300 , 0000 , ;ASM 
ASM: 2LIMI    0300,  0002 , ;ASM 

: TEST   BEGIN  0LIMI  ?TERMINAL UNTIL ;

HEX
4000 CONSTANT SAMSREGS

: CELLS  1 SLA ;
\ * SAMSINI sets card to "pass-through" condition
\   Tests the size of the SAMS card upto 1.4 Mbytes
DECIMAL
: SAMSINI ( -- )
  CR ." 1M SAMS card "
    'R12 @ >R  
    SAMSCARD  0SBO                   
    0                     \ register value 
    SAMSREGS  22 CELLS    \ registers base address, # SAMS regs
    OVER + SWAP ( -- >4030 >4000)
    DO
        DUP SWPB I !    \ swap bytes and write 16 bits to reg
        I C@  OVER <>  ABORT" failed"
        1+
    2 +LOOP
    DROP
    0SBZ
    R> 'R12 ! 
    ." initialized"
;

SAMSINI

