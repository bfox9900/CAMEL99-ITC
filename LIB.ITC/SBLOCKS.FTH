\ BLOCK  as a method to manage SAMS pages    Jan 15 2021 Brian Fox

\ NEEDS .S   FROM DSK1.TOOLS
\ NEEDS MOV, FROM DSK1.ASM9900

NEEDS SAMSINI FROM DSK1.SAMSINI
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
 : PAGED  ( virtual-addr -- real-addr)
         SEG @ 1000 UM/MOD ( -- offset bank#) BLOCK + ;

HERE SWAP - DECIMAL  CR .  .( bytes)
