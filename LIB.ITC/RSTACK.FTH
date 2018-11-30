\ 'R  'R1+!  'R--  'R+!  non-standard access to Return stack

\ The return stack is in memory but standard Forth gives us no direct access
\ to the memory cells. This means that maintaining a loop index on the
\ return stack is very inefficient.
\ Example: increment cell on top of return stack
\ Forth    :   R> 1+ >R  (very slow)
\ Assembler:  *RP INC,   (very fast)

INCLUDE DSK1.TOOLS.F
INCLUDE DSK1.ASM9900.F
INCLUDE DSK1.ELAPSE.F

\ return address of top of return stack
CODE 'R     ( -- addr) 
            TOS PUSH,  
            RP TOS MOV, 
            NEXT, 
            ENDCODE

\ increment/decrement value op top of Rstack is one instruction!
CODE 'R1+!   ( -- )  *RP INC,   NEXT, ENDCODE
CODE 'R1-!   ( -- )  *RP DEC,   NEXT, ENDCODE

CODE 'R2+!   ( -- )  *RP INCT,  NEXT, ENDCODE
CODE 'R2-!   ( -- )  *RP DECT,  NEXT, ENDCODE

CODE 'R+!    ( n --)  \ increment 'R by n
             TOS *RP A,
             TOS POP,
             NEXT, ENDCODE

CODE R@0=    ( -- ?)  \ compare 'R to 0
             TOS PUSH,
            *RP TOS MOV,
             EQ IF, TOS SETO,
             ELSE,  TOS CLR,
             ENDIF,
             NEXT,
             ENDCODE

CODE 'R=    ( n -- ?) \ compare 'R to TOS
            *RP TOS CMP,
             EQ IF, TOS SETO,
             ELSE,  TOS CLR,
             ENDIF,
             NEXT,
             ENDCODE

CODE R@=0  ( -- ?)  \ dec. 'R and compare to 0
             TOS PUSH,
             TOS CLR,
            *RP DEC,
             EQ IF,
                TOS SETO,
             ENDIF,
             NEXT,
             ENDCODE

\ for positive values only
CODE R@<0  ( -- ?)  \ dec. 'R, test <0
             TOS PUSH,
             TOS CLR,
            *RP DEC,
             OC IF,
                TOS SETO,
             ENDIF,
             NEXT,
             ENDCODE
CODE R-@  ( -- n)
             TOS PUSH,
            *RP DEC,
            *RP TOS MOV,
             NEXT,
             ENDCODE

\ test results
\ Standard Forth
: ATEST     FFFF >R  BEGIN   R> 1- DUP >R 0= UNTIL R> DROP ;  \ 18sec

\ 'R , R@0=
: BTEST     FFFF >R  BEGIN  -1 'R +!    R@0= UNTIL R> DROP ;  \ 18sec

\ conventional dec. with R@0=
: CTEST     FFFF >R  BEGIN   R> 1- >R   R@0= UNTIL R> DROP ;  \ 16.4sec

\ fast R decrement
: DTEST     FFFF >R  BEGIN  'R1-!       R@0= UNTIL R> DROP ;  \ 9.7sec

\ R dec. and compare to zero in one word
: ETEST     FFFF >R  BEGIN              R@=0 UNTIL R> DROP ;  \ 7.35sec

\ fast while loop with R dec. & fetch
: FTEST     FFFF >R  BEGIN  R-@ WHILE       REPEAT R> DROP ;  \ 9.2sec

\ ascending loop using fast incr. and 'R= to test loop
: GTEST        0 >R  BEGIN  'R1+!   FFFF 'R= UNTIL R> DROP ;  \ 11.85sec

: HTEST     7FFF >R  BEGIN              R@<0 UNTIL R> DROP ;  \
