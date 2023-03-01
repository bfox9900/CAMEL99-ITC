\ machine Forth macros  BFox Nov 2019

\ Example code
\ fastest Arrays using native 9900 indexed addressing
\ CREATE A1  1000 CELLS ALLOT
\ MACRO A1@ ( ndx -- n)   A1 ()@,  ;MACRO
\ MACRO A1! ( ndx -- n)   A1 ()!,  ;MACRO

: MACRO     CODE ;
: ;MACRO    NEXT, ENDCODE  ;

\ stack primitives
: DUP,  ( n -- n n) 0646 , C584 , ;  \ Also used as: TOS PUSH,
: DROP, ( n --)     C136 , ;  \ Also used as:  TOS POP,
: 2*,   ( n -- n')  A104 , ;  \  TOS TOS ADD,

\ Very FAST integer array words
: ()@,  ( addr -- ) 2*,  C124 , ( addr) , ;  \ addr(TOS) TOS MOV
: ()!,  ( addr -- ) 2*,  C936 , ( addr) ,  DROP, ; \ *SP+ ARRAY (TOS) MOV,

\ fast byte array words
: ()C@, ( addr -- )   D124 , ( addr) , 0984 , ;
: ()C!, ( c addr --)  06D6 , D916 , ( addr ) ,  05C6 , DROP, ;

: LIT,  ( n -- )  DUP, 0204 , ( n) ,  ;  \ TOS PUSH,  LI TOS ( n ) , ;

: @,    ( addr --)    DUP, C120 , ( addr) , ; \ TOS PUSH, addr @@ TOS MOV,
: !,    ( n addr -- ) DUP, C536 , DROP, ;

: C@,   ( addr --)   DUP, D114 , 0984 , ;
: C!,   ( n addr --) 06D6 , D516 , 05C6 , DROP, ;

\ NORMAL copies of words that are not normal in the Camel99 kernel
\ CODE @      C114 ,                  NEXT,  ENDCODE
\ CODE C@     D114 , 0984 ,           NEXT, ENDCODE
\ CODE DROP   C136 ,                  NEXT, ENDCODE
\ CODE LIT    0646 , C584 ,  C139 ,   NEXT, ENDCODE
