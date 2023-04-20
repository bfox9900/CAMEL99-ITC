\ M I X E D  (32BIT/16BIT)   M A T H   O P E R A T I O N S

: */MOD  ( n1 n2 n3 -- n4 n5) >R UM* R> M/MOD ;

SLOWER [IF]
 : S>D    ( n -- d)  DUP 0< ;

[ELSE]
CODE S>D ( n -- d)
         TOS PUSH,     \ DUP
         TOS TOS MOV,  \ compare TOS to zero this way is smallest
         TOS CLR,      \ CLR does not affect CPU flags
         LT IF,        \ so we can jump on the previous compare instruction
              TOS SETO,
         ENDIF,
         NEXT,
         ENDCODE
[THEN]
: M+     ( d n -- d) S>D  D+ ;    \ * change from V2.67

: /MOD   ( n1 n2 -- n3 n4) >R S>D R> M/MOD ;
: /      ( n n -- n)   /MOD NIP  ;
: MOD    ( n n -- n)   /MOD DROP ;
: */     ( n n n -- n) */MOD NIP ;
