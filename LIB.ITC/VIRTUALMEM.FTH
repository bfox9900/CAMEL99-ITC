\ SAMS arrays using 2 window BLOCK manager  Jun 2022

NEEDS DUMP FROM DSK1.TOOLS
NEEDS BLOCK  FROM DSK1.SBLOCKS

VARIABLE SEG     \ holds current 64K segment
1000 CONSTANT 4K
\ SAMS static Forth style memory allocation
VARIABLE SDP  \ sams dictionary pointer for 1 64K segment

: SALLOT ( n -- )  SDP +! ;   \ move dictionary pointer ( pos or neg)

: >REAL  ( addr seg -- addr )  4K UM/MOD BLOCK + ;
: PAGED  ( virtual-addr -- real-addr) SEG @ >REAL ;

: SHERE  ( -- addr) SDP @ >REAL ;  \ return end of SAMS dictionary

: ?SEGMENT ( n -- ) 255 1 WITHIN ABORT" Bad segment" ;

\ create arrays in a specifc segment
\ The return virtual addresses so are used with !L  @L  C!l C@l
: FAR-ARRAY ( cells segment -- <name>)
     DUP ?SEGMENT
     CREATE     ,  ,   \ compile SEGMENT and base address
             SALLOT    \ allocate memory in the SAMS space

     DOES> 2@  >R SWAP CELLS + R>  >REAL ;

: FAR-CARRAY ( bytes segment -- <name<)
     DUP ?SEGMENT
     CREATE     ,  ,   \ compile SEGMENT and base address
             SALLOT    \ allocate memory in the SAMS space

     DOES> 2@ >R + R>  >REAL ;

\ EXAMPLE: 40K byte array of integers in SAMS.
INCLUDE DSK1.ELAPSE
INCLUDE DSK1.BREAK

20000 1 FAR-ARRAY ]BIG

: BIGERASE  20000 0 DO   I BLOCK 4K 0 FILL  4K +LOOP ; \ < 0.5 seconds
: BIGFILL   20000 0 DO  I I ]BIG !    LOOP  ;  \ 18.5 seconds
: BIGSEE    20000 0 DO    I ]BIG @ . ?BREAK  LOOP ;


\ True "FAR" memory access words operate on 32 bit address
: !L    ( n Daddr --)  >REAL ! ;   \ store int
: C!L   ( c Daddr --)  >REAL C! ;  \ store char
: 2!L   ( d Daddr --)  >REAL 2@ ;  \ store double

: @L    ( Daddr -- n)  >REAL @ ;
: C@L   ( Daddr -- c)  >REAL C@ ;
: 2@L   ( Daddr -- d)  >REAL 2@ ;

: ,L   ( n --) SHERE SEG @ !L  2 SALLOT ;
: C,L  ( c --) SHERE SEG @ C!L 1 SALLOT ;


\ ======================================================
\ build some hi-level data structures with the new tools

\ create a variable in the current segment
: VAR ( <name> -- addr)      \ use !L and @L  with VAR
        CREATE  SHERE  0 ,L  \  put a zero into SAMS HERE
                SEG @ ,  ,   \ compile SEGMENT and address
        DOES> 2@ SWAP SEG !  ;  \ runtime: fetch the virtual memory pointer
