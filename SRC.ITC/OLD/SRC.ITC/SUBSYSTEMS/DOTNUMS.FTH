\ DOTNUMS  print numbers

TARGET-COMPILING

0 [IF]
   : >DIGIT   DUP 9 > IF 7 + THEN T[CHAR] 0 + ;  \ 20 BYTES :)

[ELSE]
CODE >DIGIT  ( n -- c) \ ASM is 9 bytes, 4X faster
            TOS 9 CMPI,
            HI IF,              \ if n>9
               TOS 7 ADDI,      \ number is not base 10, add 7
            ENDIF,
            TOS  TCHAR 0 ADDI,  \ add ASCII 0 to TOS create char value
            NEXT,
            ENDCODE
[THEN]

: <#     ( --)   PAD HP ! ;

SLOWER [if]
   : HOLD   ( char -- )  HP DUP 1-! @ C! ;

[else]  \ this took a while to get right :)
 CODE HOLD  ( char -- )
 \ *G HOLD is CODE. 4 bytes bigger, 4..9% faster number output than Forth version.
           R1 STWP,        \ get workspace pointer
           26 (R1) DEC,    \ DEC address in HP user variable
           26 (R1) R1 MOV, \ put the address into R1
           TOS SWPB,
           TOS *R1 MOVB,   \ store char in address in R1
           TOS POP,
           NEXT,
           ENDCODE
[then]

: #      ( u -- ud2 ) 0 BASE@ UM/MOD >R  BASE@ UM/MOD SWAP >DIGIT HOLD R> ;
: #S     ( ud1 -- ud2)  BEGIN  # 2DUP OR  WHILE REPEAT ;
: #>     ( ud1 -- c-addr u) 2DROP HP @ PAD OVER - ;
: SIGN   ( n -- ) 0< IF  T[CHAR] -  HOLD  THEN ;
: UD.    ( d -- ) <#  #S  #> TYPE SPACE ;
: U.     ( u -- ) 0 UD. ;
: .      ( n -- ) DUP ABS 0 <#  #S ROT SIGN  #> TYPE SPACE ;
