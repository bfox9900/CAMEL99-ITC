\ BLOCK  as a method to manage SAMS pages    Jan 15 2021 Brian Fox
\ 
\ Jun 2022  Added 32 bit FAR address memory operators
\ The concept: Keep two 4K "windows" in LOW RAM.
\ BLOCK returns the window that has requested address.
\ If SAMS page is not preset, it will be loaded into the last used window.
\ ******************************************************
\ **  This means you can copy data from SAMS to SAMS  **
\ **        without a separate RAM buffer             **
\ ******************************************************

\ NEEDS .S   FROM DSK1.TOOLS
\ NEEDS MOV, FROM DSK1.ASM9900
NEEDS SAMSINI  FROM DSK1.SAMSINI

HERE
\ ==========================================
\ BLOCK is the entire SAMS manager
HEX
VARIABLE USE
CREATE BLK#S       0 ,    0 ,      \ SAMS page in the buffer
CREATE WINDOWS  2000 , 3000 ,      \ windows in Low CPU RAM

CODE BLOCK ( bank -- buffer)
 0200 , BLK#S ,
 8110 ,
 1603 ,
    0204 , 2000 ,
    045A ,
 05C0 ,
 8110 ,
 1603 ,
     0204 , 3000 ,
     045A ,
 0208 , 0001 , 
 2A20 , USE ,
 C808 , USE ,
 A208 ,
 CA04 , BLK#S ,
 C068 , WINDOWS ,
 09B1 ,
 0221 , 4000 ,
 020C , 1E00 ,
 1D00 ,
 06C4 ,
 C444 ,
 1E00 ,
 C128 , WINDOWS ,
 NEXT,
 ENDCODE

 VARIABLE SEG
\ safely set the 64K segment that you want to use
: SEGMENT ( 1..F -- ) \ don't allow segment 0
         DUP 01 10 WITHIN 0= ABORT" SAMS segment err"
         SEG ! ;
 1 SEGMENT

 HEX
\ This could be code a faster computation
: >REAL  ( addr seg -- virtual-address) 1000 UM/MOD BLOCK + ;
: PAGED  ( virtual-addr -- real-addr) SEG @ >REAL ;

\ True "FAR" memory access words operate on 32 bit address
: !L    ( n Daddr --)  >REAL ! ;   \ store int
: C!L   ( c Daddr --)  >REAL C! ;  \ store char
: 2!L   ( d Daddr --)  >REAL 2@ ;  \ store double

: @L    ( Daddr -- n)  >REAL @ ;
: C@L   ( Daddr -- c)  >REAL C@ ;
: 2@L   ( Daddr -- d)  >REAL 2@ ;

HERE SWAP - DECIMAL  CR .  .( bytes)
