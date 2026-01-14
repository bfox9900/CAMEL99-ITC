\ SAMS CARD data support for FbForth   Oct 2020  B Fox
\ 64K segmented memory model
\ Update for FbForth V3.0  2025 


HEX
EFA0 S0&TIB! DROP     \ move stacks and TIB 

HERE
F000 CONSTANT PMEM    \ CPU paged memory location

\ pre-compute SAMS register based on PMEM address
PMEM 0B SRL 4000 + CONSTANT SREG

   0 VARIABLE SEG     \ holds current 64K segment
   0 VARIABLE BANK#   \ current mapped sams bank

\ safely set the 64K segment that you want to use
\ max = 15.  SEGMENT 0 reserved for normal RAM
: SEGMENT ( 1..F -- ) 
      DUP 01 11 WITHIN 0= ABORT" SAMS segment err"
      SEG ! ;

1 SEGMENT

HEX
: VIRT>REAL ( virtual-addr -- real-addr)
      SEG @ 1000 U/ ( -- offset bank#)
      DUP BANK# @ = IF  DROP PMEM + EXIT  ENDIF 
    \ sams NOT paged in     
      DUP BANK# ! 
      SWAP PMEM +   ( -- bank# addr)
      TUCK ( -- addr bank addr) >MAP 
;

\ SAMS DATA words ("LONG data")
: !L   ( n Virtaddr -- )  VIRT>REAL  ! ; 
: @L   ( Virtaddr -- n)   VIRT>REAL  @ ; 
: C!L  ( n Virtaddr -- )  VIRT>REAL C! ;  
: C@L  ( Virtaddr -- n)   VIRT>REAL C@ ; 

CR ." SAMS window = " PMEM HEX U.
CR ." Segment     = " SEG @  DECIMAL U.
CR
CR HERE SWAP - DECIMAL . ." bytes used"

