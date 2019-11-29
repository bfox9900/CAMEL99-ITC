\ Machine Code macros to build the the fastest arrays in Forth

NEEDS .S  FROM DSK1.TOOLS
NEEDS ELAPSE FROM DSK1.ELAPSE
NEEDS SEE FROM DSK1.SEE

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
NEEDS TOS  FROM DSK1.ASM9900

CODE ()C!, ( addr -- )
         D136 , \  *SP+ TOS MOVB,
         C136 , \  TOS POP,
         NEXT,

         ENDCODE
1000 CONSTANT SIZE  \ 4K bytes

\ demonstration code

\ ******************************************************
\ Textbook method to make arrays in Forth
\ : ARRAY ( n -- )
\         CREATE  CELLS ALLOT
\         DOES> ( n -- a ) SWAP CELLS + ;
\
\   SIZE ARRAY ]X
\
\ : FILLIT    SIZE 0 DO  I I ]X !  LOOP ;   \ 2.03
\ ******************************************************

\ indexed addressing arrays are the fastest
CREATE Q    SIZE CELLS ALLOT

\ alternate method: create an indexing operator
: []  ( ndx addr -- addr[ndx])  SWAP CELLS + ;

\ asm indexing operator is faster still
CODE  []ASM ( ndx addr -- addr')
       *SP *SP ADD,       \ x2 for cells
       *SP+ TOS ADD,      \ add to address
       NEXT,
       ENDCODE

\ method3: embedded array address in the word
: ]Q2!     CELLS Q + ! ;
: FORTHFILL    SIZE 0 DO   I I Q [] !   LOOP ;  \ 2.10
: FASTERFILL    SIZE 0 DO  I I ]Q2!     LOOP ;  \ 1.88
: ASMFILL    SIZE 0 DO   I I Q []ASM !   LOOP ; \ 1.41

\ use our macros to make a fast code word
CODE ]Q! ( n ndx -- n)   2*, Q ()!,  NEXT, ENDCODE

: INDEXFILL    SIZE 0 DO  I I ]Q!    LOOP ;  \ 1.06

CODE ]Q@ ( ndx -- n)     2*, Q ()@,  NEXT, ENDCODE
: SEEIT       SIZE 0 DO     I ]Q@ .  LOOP ;

\ Test procedure 
ELAPSE FORTHFILL
ELAPSE FASTERFILL
ELAPSE ASMFILL
ELAPSE INDEXFILL

