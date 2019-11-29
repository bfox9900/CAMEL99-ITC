\ machine Forth macros to create fast arrays

\ stack primitives
: DUP,   ( n -- n n) 0646 , C584 , ;  \ Also used as: TOS PUSH,
: DROP,  ( n --)     C136 , ;  \ Also used as:  TOS POP,
: 2*,    ( n -- n')  0A14 , ;  \ TOS  1 SLA,

\ Very FAST integer array words
: ()@,   ( addr -- ) 2*,  C124 , ( addr) , ;  \ addr(TOS) TOS MOV
: ()!,   ( addr -- ) 2*,  C936 , ( addr) ,  DROP, ;
          \ *SP+ ARRAY (TOS) MOV,
          \ TOS pop

\ fast byte array words
\ : ()C@,  ( addr -- )  D124 , ( addr) , 0984 , ;
\ : ()C!,  ( c addr --)   ????? ;

: LIT, ( n -- )    DUP,  0204 , ( n) ,  ;  \ TOS PUSH,  LI TOS ( n ) , ;

: @,   ( addr --)  DUP,  C120 , ( addr) ,  ;  \ TOS PUSH, *SP+ *TOS MOV,
: !,   ( n addr -- ) DUP, C536 , DROP, ;

: C@,  ( addr --)   DUP, D114 , 0984 , ;
: C!,  ( n addr --) 06D6 , D516 , 05C6 , DROP, ;


: ;MACRO    NEXT, ENDCODE  ;
: MACRO    CODE ;

\ CODE ]QC! ( n -- ) TOS SWPB,   *SP+  Q (TOS) MOVB,    TOS POP,  NEXT, ENDCODE

