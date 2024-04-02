\ Address register 'A'  as used in F21 CPU  by Chuck Moore
\ http://www.ultratechnology.com/f21cpu.html

\ A     copy A to TOP of stack
\ @A+   place memory contents pointed to by register A in TOP, increment A
\ @A    place memory contents pointed to by register A in TOP of stack
\ !A+   store TOP of stack into memory pointed to by A, increment A
\ A!    move TOP of stack to A
\ !A    store TOP of stack into memory pointed to by A

NEEDS DUMP  FROM DSK1.TOOLS
NEEDS MOV,  FROM DSK1.ASM9900

CODE A            TOS PUSH,    R0 TOS MOV,  NEXT, ENDCODE
CODE A!       TOS R0  MOV,        TOS POP,  NEXT, ENDCODE

\ indirect addressing fetch and store
CODE @A          TOS PUSH,    R0 ** TOS MOV,  NEXT, ENDCODE
CODE !A    TOS R0 ** MOV,           TOS POP,  NEXT, ENDCODE

\ indirect auto-increment
CODE @A+          TOS PUSH,    R0 *+ TOS MOV,  NEXT, ENDCODE
CODE !A+   TOS  R0 *+ MOV,           TOS POP,  NEXT, ENDCODE

\ useful additions
CODE A+!    TOS R0 ADD,  TOS POP, NEXT, ENDCODE
CODE A>R    R0 RPUSH,  NEXT, ENDCODE 
CODE R>A    R0 RPOP,   NEXT, ENDCODE 

\ examples
HEX 
: TEST           FFFF 0 DO  I A!  A DROP LOOP ; \ store/fetch A register 
: @AUTOINC  0 A!  FFFF 0 DO  @A+ DROP LOOP ;

: AFILL  ( char addr len -- )  \ different order for using A register 
    OVER A!  
    BOUNDS
    BEGIN 
          

