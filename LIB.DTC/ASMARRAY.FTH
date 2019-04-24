\ Machine Code macros to build the the fastest arrays in Forth

\ The fastest access to indexed memory on the TMS9900 is by using the 
\ indexed addressing instructions.  We can code this in Assembler like this:
\
\ CODE ]ARRAY@  ( i -- array[i]@)
\        TOS  1 SLA,            \ shift R1 1 bit left (mult. By 2)
\        ARRAY (TOS) TOS MOV,   \ fetch contents of ARRAY(TOS) to TOS
\        NEXT,
\ ENDCODE

\ CODE ]ARRAY!  ( n ndx --)
\       TOS  1 SLA,            \ shift TOS 1 bit left (mult. By 2)
\      *SP+ ARRAY (TOS) MOV,   \ POP 2nd stack item into address ARRAY(TOS)
\       TOS POP,               \ refill TOS register
\       NEXT,
\ ENDCODE

\ The following machine Forth macros allow us to do the same thing
\ without loading the assembler, and they are easy to understand

\ machine Forth macros make it easy to create fast arrays
: 2*,     ( n -- 2(n)
          0A14 , ;  \ TOS  1 SLA, shift R1 1 bit left (mult. By 2)

: ()@,   ( addr -- )
          C124 , ( addr) ,   \ addr(TOS) TOS MOV
;

: ()!,   ( addr -- )
          C936 , ( addr) ,  \ *SP+ ARRAY (TOS) MOV,
          C136 ,            \ TOS pop
;
INCLUDE DSK1.ASM9900.F

CODE ()C!, ( addr -- )
         D136 , \  *SP+ TOS MOVB,
         TOS POP,
         NEXT,
         ENDCODE


\ demonstration code
INCLUDE DSK1.TOOLS.F
INCLUDE DSK1.ELAPSE.F
INCLUDE DSK1.SEE.F
\ Textbook method to make arrays in Forth
: ARRAY ( n -- )
         CREATE  CELLS ALLOT
         DOES> ( n -- a ) SWAP CELLS + ;

1000 CONSTANT SIZE  \ 4K bytes

SIZE ARRAY ]X

: DOESFILL     SIZE 0 DO   I I ]X !      LOOP ;   \ 2.08

\ indexed addressing arrays are the fastest
CREATE Q    SIZE CELLS ALLOT
\ alternate method: create an indexing operator
: []  ( ndx addr -- addr[ndx])  SWAP CELLS + ;

\ method3: embedded array address in the word
: ]Q2!     CELLS Q + ! ;
: FORTHFILL    SIZE 0 DO   I I Q [] !   LOOP ; \ 2.10
: FASTERFILL    SIZE 0 DO  I I ]Q2!     LOOP ; \ 1.88

\ use our macros to make a fast code word
CODE ]Q@ ( ndx -- n)     2*, Q ()@,  NEXT, ENDCODE
CODE ]Q! ( n ndx -- n)   2*, Q ()!,  NEXT, ENDCODE

: MACROFILL    SIZE 0 DO  I I ]Q!    LOOP ;  \ 1.06

: SEEIT       SIZE 0 DO     I ]Q@ .  LOOP ;
