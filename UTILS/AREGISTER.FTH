\ Address register 'A'  as used in F21 CPU  by Chuck Moore
\ http://www.ultratechnology.com/f21cpu.html

\ A     copy A to TOP of stack
\ @A+   place memory contents pointed to by register A in TOP, increment A
\ @A    place memory contents pointed to by register A in TOP of stack
\ !A+   store TOP of stack into memory pointed to by A, increment A
\ A!    move TOP of stack to A
\ !A    store TOP of stack into memory pointed to by A

\ Conclusion:  Not worth the dictionary space. custom code words would work better. 

NEEDS DUMP  FROM DSK1.TOOLS
NEEDS MOV,  FROM DSK1.ASM9900
NEEDS ELAPSE FROM DSK1.ELAPSE 

R15 CONSTANT AR  

CODE A            TOS PUSH,    AR TOS MOV,  NEXT, ENDCODE
CODE A!       TOS AR  MOV,        TOS POP,  NEXT, ENDCODE
\ useful additions
CODE A+!     TOS AR ADD,   TOS POP, NEXT, ENDCODE
CODE A@1+    TOS PUSH,     AR TOS MOV,   AR INC,  NEXT, ENDCODE 
CODE A@2+    TOS PUSH,     AR TOS MOV,   AR INCT, NEXT, ENDCODE 

\ indirect addressing fetch and store
CODE @A          TOS PUSH,    AR ** TOS MOV,  NEXT, ENDCODE
CODE !A    TOS AR ** MOV,           TOS POP,  NEXT, ENDCODE

\ indirect auto-increment
CODE @A+          TOS PUSH,    AR *+ TOS MOV,  NEXT, ENDCODE
CODE !A+   TOS  AR *+ MOV,           TOS POP,  NEXT, ENDCODE

\ these are smarter 
CODE DUP!A+    TOS  AR *+ MOV,  NEXT, ENDCODE 
CODE OVER!A+   *SP  AR *+ MOV,  NEXT, ENDCODE 

\ If you need to use A many times in a word
CODE A>R    AR RPUSH,  NEXT, ENDCODE 
CODE R>A    AR RPOP,   NEXT, ENDCODE 

CODE C@A    TOS PUSH,    AR ** TOS MOVB,  TOS 8 SLA, NEXT, ENDCODE 
CODE C@A+   TOS PUSH,    AR *+ TOS MOVB,  TOS 8 SLA, NEXT, ENDCODE 

\ examples
HEX 
: TEST    ( n -- )       0 DO  I A!  A . LOOP ; \ store/fetch A register 
: TEST1+  ( n -- )  0 A! 0 DO   A@1+ . LOOP ;


: FORTHFILLW   \ 2000 2000 BEEF AFILLW  1.0 SECS
    -ROT 
    BOUNDS 
    DO 
       DUP I !
    2 +LOOP 
    DROP ;

HEX 
: AFILLW    ( addr len u --) \ 2000 2000 BEEF AFILLW  .83 SECS
       ROT A!
       SWAP 
       0 DO 
           DUP !A+ 
       2 +LOOP 
       DROP 
;

\ BF versions 
HEX 
: AFILLW2    ( addr len u --) \ 2000 2000 BEEF AFILLW  .63 SECS
       ROT A!
       SWAP 
       0 DO 
           DUP!A+ 
       2 +LOOP 
       DROP 
;

CODE C@A    TOS PUSH,    AR ** TOS MOVB,  TOS 8 SRL, NEXT, ENDCODE 
CODE C@A+   TOS PUSH,    AR *+ TOS MOVB,  TOS 8 SRL, NEXT, ENDCODE 

: ATYPE   ( addr len ) SWAP A! 0 DO  C@A+ (EMIT)  LOOP ;
: FTYPE                0 DO  COUNT (EMIT) LOOP  DROP ;

: BIG$ 
 S" The rain in spain falls mainly on the plain but not here in Canada." ;

DECIMAL 
: TESTF    100 0 DO  BIG$ FTYPE  LOOP ; \ 10.26
: TESTA    100 0 DO  BIG$ ATYPE  LOOP ; \ 10.21  :-) 

