( ORIGINAL TI-FORTH ASSEMBLER modified by Mark Wills, Turboforth)
( and more changes for CAMEL99 Forth by Brian Fox     )
( *NOTE:                                              )
(        compare instruction has been changed to CMP, )
(        to remove name conflict with C,              )
(        change A, and S, to ADD, SUB,                )

NEEDS CASE  FROM DSK1.CASE

CR .( TI-99 Assembler V2 ...)

HERE   \ save the dictionary pointer on stack

HEX
CR .( Loading Assembler @) DP @ U.

( VOCABULARY ASSEMBLER )
( ASSEMBLER DEFINITIONS)

DECIMAL
 0 CONSTANT  R0    1 CONSTANT  R1
 2 CONSTANT  R2    3 CONSTANT  R3
 4 CONSTANT  R4    5 CONSTANT  R5
 6 CONSTANT  R6    7 CONSTANT  R7
 8 CONSTANT  R8    9 CONSTANT  R9
10 CONSTANT R10   11 CONSTANT R11
12 CONSTANT R12   13 CONSTANT R13
14 CONSTANT R14   15 CONSTANT R15

HEX
: GOP'     OVER DUP 1F > SWAP 30 < AND   \ address or register?
           IF   + , ,                    \ compile instruction & address
           ELSE + ,                      \ compile register
           THEN ;

: GOP      CREATE , DOES> @ GOP' ;

0440 GOP B,    0680 GOP BL,   0400 GOP BLWP,
04C0 GOP CLR,  0700 GOP SETO, 0540 GOP INV,
0500 GOP NEG,  0740 GOP ABS,  06C0 GOP SWPB,
0580 GOP INC,  05C0 GOP INCT, 0600 GOP DEC,
0640 GOP DECT, 0480 GOP X,

: GROP     CREATE , DOES> @ SWAP 40 * + GOP' ;

2000 GROP COC,  2400 GROP CZC,  2800 GROP XOR,
3800 GROP MPY,  3C00 GROP DIV,  2C00 GROP XOP,

: GGOP     CREATE ,
           DOES> @ SWAP DUP DUP 1F > SWAP 30 < AND
                 IF   40 * + SWAP >R GOP' R> ,
                 ELSE 40 * + GOP'  THEN ;
HEX
A000 GGOP ADD,  B000 GGOP ADDB, 8000 GGOP CMP, 9000 GGOP CMPB,
6000 GGOP SUB,  7000 GGOP SUBB, E000 GGOP SOC, F000 GGOP SOCB,
4000 GGOP SZC,  5000 GGOP SZCB, C000 GGOP MOV, D000 GGOP MOVB,

: 0OP     CREATE ,  DOES> @ , ;

0340 0OP IDLE,   0360 0OP RSET,  03C0 0OP CKOF,
03A0 0OP CKON,   03E0 0OP LREX,  0380 0OP RTWP,

: ROP     CREATE , DOES> @ + , ;
02C0 ROP STST,
02A0 ROP STWP,

: IOP     CREATE , DOES> @ , , ;
02E0 IOP LWPI,
0300 IOP LIMI,

: RIOP    CREATE , DOES> @ ROT + , , ;
0220 RIOP AI,
0240 RIOP ANDI,
0280 RIOP CI,
0200 RIOP LI,
0260 RIOP ORI,

: RCOP    CREATE , DOES> @ SWAP 10 * + + , ;
0A00 RCOP SLA,
0800 RCOP SRA,
0B00 RCOP SRC,
0900 RCOP SRL,

CR .( jump instructions)
: DOP     CREATE , DOES> @ SWAP 00FF AND OR , ;
1300 DOP JEQ,  1500 DOP JGT,  1B00 DOP JH,   1400 DOP JHE,
1A00 DOP JL,   1200 DOP JLE,  1100 DOP JLT,  1000 DOP JMP,
1700 DOP JNC,  1600 DOP JNE,  1900 DOP JNO,  1800 DOP JOC,
1C00 DOP JOP,  1D00 DOP SBO,  1E00 DOP SBZ,  1F00 DOP TB,

: GCOP    CREATE , DOES> @ SWAP 000F AND 40 * + GOP' ;

3000 GCOP LDCR,
3400 GCOP STCR,
HEX
\ Wycove assembler register syntax:
: @@        020    ;  \ symbolic addressing
: **        010 +  ;  \ indirect addressing
: *+        030 +  ;  \ indirect addressing, auto-increment
: ()        20  +  ;  \ indexed addressing

CR .( CAMEL99 special registers & modes)

4 CONSTANT TOS
: (TOS)     TOS () ;
: *TOS      TOS ** ;
: *TOS+     TOS *+ ;

6 CONSTANT SP
: (SP)      SP () ;
: *SP       SP ** ;
: *SP+      SP *+ ;

7 CONSTANT RP
: (RP)      RP () ;
: *RP       RP ** ;
: *RP+      RP *+ ;

8 CONSTANT W
: (W)       W ()  ;
: *W        W **  ;
: *W+       W *+  ;

9 CONSTANT IP
: (IP)      IP () ;
: *IP       IP ** ;
: *IP+      IP *+ ;

: *R10      R10 ** ;
: *R11      R11 ** ;

CR .( Pseudo instructions)
: RT,     ( -- )  R11 ** B, ;
: NOP,    ( -- )  0 JMP, ;
: NEXT,   ( -- )  045A ,  ;  \ CAMEL99 NEXT: B *R10

\ PUSH & POP for both stacks
: PUSH,         ( src -- )  SP DECT,  *SP  MOV, ;    \ 10+18 = 28  cycles
: POP,          ( dst -- )  *SP+      SWAP MOV, ;    \ 22 cycles

: RPUSH,        ( src -- ) RP DECT,  *RP   MOV, ;
: RPOP,         ( dst -- ) *RP+      SWAP  MOV, ;


CR .( Jump tokens) \ for use with CJMP
HEX
 1 CONSTANT GTE     \ GT OR EQUAL
 2 CONSTANT HI      \ JMP IF HI
 3 CONSTANT NE      \ NOT equal
 4 CONSTANT LO      \ jmp if low
 5 CONSTANT LTE     \ jmp if less than or equal
 6 CONSTANT EQ      \ jmp if equal
 7 CONSTANT OC      \ jmp on carry flag set
 8 CONSTANT NC      \ jmp if no carry flag set
 9 CONSTANT OO      \ jmp on overflow
 A CONSTANT HE      \ jmp high or equal
 B CONSTANT LE      \ jmp if low or equal
 C CONSTANT NP      \ jmp if no parity ?
 D CONSTANT LT      \ jmp if less than
 E CONSTANT GT      \ jmp if greater than
 F CONSTANT NO      \ jmp if no overflow
10 CONSTANT OP      \ jmp if ODD parity

: CJMP CASE
         LT OF 1101 , 0 ENDOF
         GT OF 1501 , 0 ENDOF
         NO OF 1901 , 0 ENDOF
         OP OF 1C01 , 0 ENDOF
         DUP 0< OVER 10 > ABORT" IF, BAD jump token"
       ENDCASE >< 1000 + , ;

CR .( Structured branching and looping )
\ *These words do compile time matching*
\ 42 the meaning of life the universe and everything
\ is use to check that if, else, endif, are used properly
\ each word leaves 42 or checks for it's presence as neeeded
\ using the word ?pairs to test for completeness

: IF,
        ?EXEC ( only useable in immediate mode)
         CJMP HERE  2-  42 ; IMMEDIATE

: ENDIF,
        ?EXEC
        42 ?PAIRS
        HERE OVER - 2- 2/ SWAP CHAR+ C! ; IMMEDIATE

: ELSE,
        ?EXEC
        42 ?PAIRS
        0  CJMP HERE 2- SWAP
        42 POSTPONE ENDIF,  42 ; IMMEDIATE

: BEGIN,
        ?EXEC
        HERE 41 ; IMMEDIATE

: UNTIL,
        ?EXEC
        SWAP 41 ?PAIRS
        CJMP HERE - 2/ 00FF AND
        HERE 1- C! ; IMMEDIATE

: AGAIN,
        ?EXEC
        0 POSTPONE UNTIL, ; IMMEDIATE

: REPEAT,
        ?EXEC
        >R >R    POSTPONE AGAIN,
        R> R> 2- POSTPONE ENDIF, ; IMMEDIATE

: WHILE,
        ?EXEC
        POSTPONE IF,  CELL+ ; IMMEDIATE


\ : CODE      ( -- )  HEADER  HERE >BODY , !CSP ;
\ : ENDCODE   ( -- )  ?CSP  ;

: ;CODE
            POSTPONE (;CODE)     \ compiles (;CODE) into definition
            ?CSP POSTPONE [      \ turns off the Forth compiler
            REVEAL               \ (just like ";" does)
\           ASSEMBLER            \ expose assembler wordlist
            ; IMMEDIATE          \ this is an IMMEDIATE word

CR CR .( Assembler loaded)
CR HERE SWAP - DECIMAL .  .( BYTES used)
HEX
