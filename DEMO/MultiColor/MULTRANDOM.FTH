\ multicolor random test suite 

NEEDS DUMP   FROM DSK1.TOOLS 
NEEDS MOV,   FROM DSK1.ASM9900 
NEEDS HLINE  FROM DSK1.MULTIMODE 
NEEDS RDN    FROM DSK1.RANDOM 
NEEDS DEFER  FROM DSK1.DEFER 

DEFER RND# 

: USECAMEL   ['] RND IS RND# ; 

\ ============================================================
\ TI FORTH PRNG   
HEX 
 CODE RNDW    ( -- n)
    0646 ,        \ TOS PUSH,
    C584 ,
    C0E0 , 83C0 , \ SEED @@ R3 MOV,
    0202 , 6FE5 , \ R2 6FE5  LI,
    38C2 ,        \ R2  R3   MPY,
    0224 , 7AB9 , \ TOS 7AB9 AI,
    0B54 ,        \ TOS 5 SRC,
    C804 , 83C0 , \ TOS SEED @@ MOV,
    NEXT,
ENDCODE   \ 24 bytes
             
: TIRND     ( n -- n') RNDW ABS SWAP MOD ;

: USETI      ['] TIRND    IS RND# ;

1235 CONSTANT $1235   \ initial seed value 

\ =============================================================
\ XB COMPILER PRNG
HEX 
CODE XBRND ( limit -- n) \ limit is in R4 in Camel99 Forth 

  83C0 @@ R1 MOV,   \ fetch the random number seed
    R2   6FE5 LI, 
    R1     R2 MPY, 
    R3   7AB9 AI,        \  and now a new random number is in R3
   R3 83C0 @@ MOV,    \  move the new random number back to the random number seed
    R4     R5 MOV,      \  put the limit in R4 (Forth TOS) in R5
           R2 CLR,      \
           R3 SWPB,     \
    R5     R2 DIV,      \ 
    R3     R4 MOV,     \ Send the remainder back to Forth top of stack cache R4 
    NEXT,
ENDCODE    

: USEXB  ['] XBRND  IS RND# ;

\ =============================================================
\ TURSI'S PRNG 
HEX 
CODE RNDW  ( -- n)
      R1 B400 LI,
      TOS PUSH, 
      SEED @@ TOS MOV,
      TOS 1 SRL,
      OC IF,
           R1 TOS XOR,
      ENDIF,
      TOS SEED @@ MOV,
      NEXT,
ENDCODE

: TURSIRND  ( n -- 0..n-1 ) RNDW UM* NIP ;
: USETURSI  ['] TURSIRND  IS RND# ;


\ ----------------Test Program ----------------
DECIMAL 
: RNDX  64 RND# ;
: RNDY  48 RND# ;
: RNDCOLOR  15 RND# 1+ ;

: WAIT-KEY    BEGIN KEY? UNTIL ;

HEX 2000 CONSTANT HEAP 

\ make 2D byte matrix in low ram to mirror the screen 
DECIMAL 
64 48 * CONSTANT 64x48  \ returns size of matrix 

: ]M ( x y -- addr) 48 * +  HEAP + ;

: CLEAR-M   HEAP 64x48  0 FILL ;

: EMPTIES ( -- n)
    0   \ accumulator 
    HEAP 64x48  
    BOUNDS 
    DO
       I C@ 0= IF 1+ THEN
    LOOP 
;

: %EMPTY  (  -- n) EMPTIES 100 64x48 */  (.) TYPE  ." %" ;

: RNDTEST  
    CLEAR-M 
    $1235 SEED ! 
    MULTICOLOR 
    64x48 0 
    DO 
       15  RNDX RNDY 2DUP 2>R MCHAR \ save x,y on rstack  
       1 2R> ]M C!                 \ set corresponding byte in matrix   
    LOOP    
    WAIT-KEY 
    TEXT  
    CR ." Percent empty = " %EMPTY 
;

USECAMEL
