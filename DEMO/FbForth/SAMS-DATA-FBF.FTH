\ SAMS utilies and data strucures for FbForth  Fox 2025

\ REQUIRES  SAMSFBF.FTH 

: BOUNDS ( addr n -- addr addr' ) OVER + SWAP ;

\ 16 byte chunks 
DECIMAL 
: SAMS.ERASE ( addr n )
  BOUNDS DO  I VIRT>REAL 16 0 FILL   16 +LOOP ;

: SAMS.FILL  ( addr u char ) 
  -ROT BOUNDS DO  DUP I C!L  LOOP DROP ; 

\ cell wide fill                                              
: SAMS.FILLW ( addr u u ) 
  -ROT BOUNDS DO  DUP I !L  2 +LOOP DROP ; 

\ sams memory management 
0 VARIABLE SDP[]    \ dictionary pointer for 16 segments 
  0 , 0 , 0 , 0 ,   0 , 0 , 0 , 0 , 
  0 , 0 , 0 , 0 ,   0 , 0 , 0 , 

\ SDP is different depending on the active segment 
: SDP      SEG @ 2* SDP[] +  ;
: SHERE    SDP  @ ; 
: SALLOT   SDP +! ;
: SALIGN   SDP @ =CELLS SDP ! ; \ align SDP to even no.
: SW,    SHERE !L ;   \ compile integer 
: SC,    SHERE C!L ;  \ compile a char 

\ misc helpers
: CELLS  COMPILE 2* ; IMMEDIATE 
: 2! ( n1 n2 adr -- ) ROT OVER 2+ !  ! ;
: 2@ ( adr -- n1 n2 ) DUP 2+ @ SWAP @ ;


\ simple data structures 
HEX
\ these versions automatically change the SEGMENT 
: SAMS.VAR ( n -- ) \ FIG Forth style 
  <BUILDS SHERE SEG @ , ,   \ remember SAMS address
          SW,               \ compile n in SAMS memory
          2 SALLOT          \ allocate the space  
  DOES> 2@  SEG ! ;         \ return SAMS address, set SEG 

: SAMS.CONST 
  <BUILDS  SHERE SEG @ , ,  SHERE !L 2 SALLOT 
  DOES> 2@ SEG ! @L ;  

: SAMS.CARRAY ( n -- )  
      <BUILDS SHERE SEG @ , , SALLOT  
      DOES> 2@ SEG ! + ; 

: SAMS.ARRAY  ( n -- )  
      <BUILDS  SHERE SEG @ , ,  CELLS SALLOT  
      DOES> 2@ SEG ! SWAP CELLS + ;

\ allocate a named buffer in SAMS segment 
: SAMS.BUFFER: ( n -- ) 
      <BUILDS  SHERE SEG @ , , 
      DOES> 2@ SEG ! ;

\ Usage

2000 SAMS.ARRAY ]M 
2000 SAMS.CARRAY ]N 
\ fill the arrays with I 
: FILL[]N     2000 0 DO  I  I ]N C!L LOOP ;

\ bytes to cells transfer 
: n[]->m[]  2000 0 DO  I ]N C@L  I ]M !L  LOOP ;

1000 SAMS.BUFFER: X[]  \ 4K buffer 

\ Expose a buffer as byte array is simple
: ]X  ( n -- addr) X[] + ;

  0 ]X  100  ASCII @ SAMS.FILL 
100 ]X  100  ASCII * SAMS.FILL  
200 ]X  800  ASCII 8 SAMS.FILL   \ etc.
300 ]X  200  SAMS.ERASE

\ use another 64k segment 
2 SEGMENT 
: MATRIX: ( rows cols -- addr)
    <BUILDS SHERE SEG @ , ,  \ compile SAMS address & seg 
            2DUP  ,   ,       \ compile cols & rows
            * CELLS SALLOT    \ compute size & allocate  
    ( -- col rows )
    DOES> 2@ SEG !        \ get address set segment
          DUP >R              \ save base address          
          3 + @               \ get maxcol value
          *                   \ calc row address
          +                   \ add column coord.
          CELLS               \ convert to cells
          R> +                \ add the base address 
;

255 255 MATRIX: BIG[]          \ pretty big matrix 
