CR .( CROSS ASSEMBLER for Camel99 Forth   Brian Fox 2021 )
( *NOTE:                                              )
(        compare instruction has been changed to CMP, )
(        to remove name conflict with C,              )
(        change A, and S, to ADD, SUB,                )
( MAR 30 2021 Added enumerated labels                 )

NEEDS DUMP  FROM DSK1.TOOLS
NEEDS CASE  FROM DSK1.CASE
NEEDS DEFER FROM DSK1.DEFER
HERE

VARIABLE TDP     \ "target dictionary point"
VARIABLE ORIGIN  \ holds ORG address

HEX
\ set where the Cross-assembler puts its code
: ORG    ( addr --) DUP ORIGIN ! TDP ! ;
.( .)
\ Target versions of HERE and ALLOT
: THERE  ( -- addr)   TDP @ ;
: TALLOT ( n -- )     TDP +! ;
: TC!    ( n addr --) TDP @ + C! ;

\ integer and byte "Target" compilers
: T,     ( n -- )   THERE !  2 TALLOT ;
: TC,    ( c -- )   THERE C! 1 TALLOT ;

\ : ?PAIRS ( n1 n2 --) -  S" Not finished"  ?ABORT ;

\ ===================================================
CR .( TI-99 Cross Assembler V 0.1 ...)

CR .( Loading at) DP @ HEX U.

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
: ADDRESS? ( n -- ?) DUP 1F > SWAP 30 < AND ;

: GOP'     OVER ADDRESS?        \ address or register?
           IF   + T, T,         \ compile instruction & address
           ELSE + T,            \ compile register
           THEN ;

: GOP      CREATE , DOES> @ GOP' ;

0440 GOP B,     0680 GOP BL,    0400 GOP BLWP,
04C0 GOP CLR,   0700 GOP SETO,  0540 GOP INV,
0500 GOP NEG,   0740 GOP ABS,   06C0 GOP SWPB,
0580 GOP INC,   05C0 GOP INCT,  0600 GOP DEC,
0640 GOP DECT,  0480 GOP X,
.( .)
: GROP     CREATE , DOES> @ SWAP 40 * + GOP' ;

2000 GROP COC,  2400 GROP CZC,  2800 GROP XOR,
3800 GROP MPY,  3C00 GROP DIV,  2C00 GROP XOP,

: GGOP     CREATE ,
           DOES> @ SWAP DUP ADDRESS?
                 IF   40 * + SWAP >R GOP' R> T,
                 ELSE 40 * + GOP'  THEN ;
HEX
A000 GGOP ADD,  B000 GGOP ADDB, 8000 GGOP CMP, 9000 GGOP CMPB,
6000 GGOP SUB,  7000 GGOP SUBB, E000 GGOP SOC, F000 GGOP SOCB,
4000 GGOP SZC,  5000 GGOP SZCB, C000 GGOP MOV, D000 GGOP MOVB,

: 0OP     CREATE ,  DOES> @ T, ;

0340 0OP IDLE,   0360 0OP RSET,  03C0 0OP CKOF,
03A0 0OP CKON,   03E0 0OP LREX,  0380 0OP RTWP,

: ROP     CREATE , DOES> @ + T, ;
02C0 ROP STST,
02A0 ROP STWP,

: IOP     CREATE , DOES> @ T, T, ;
02E0 IOP LWPI,
0300 IOP LIMI,

: RIOP    CREATE , DOES> @ ROT + T, T, ;
0220 RIOP AI,
0240 RIOP ANDI,
0280 RIOP CI,
0200 RIOP LI,
0260 RIOP ORI,

: RCOP    CREATE , DOES> @ SWAP 10 * + + T, ;
0A00 RCOP SLA,
0800 RCOP SRA,
0B00 RCOP SRC,
0900 RCOP SRL,

CR .( jump instructions)
: DOP     CREATE ,   DOES> @ SWAP 00FF AND OR T, ;
1300 DOP JEQ,  1500 DOP JGT,  1B00 DOP JH,   1400 DOP JHE,
1A00 DOP JL,   1200 DOP JLE,  1100 DOP JLT,  1000 DOP JMP,
1700 DOP JNC,  1600 DOP JNE,  1900 DOP JNO,  1800 DOP JOC,
1C00 DOP JOP,

\ CRU bit operations
1D00 DOP SBO,  1E00 DOP SBZ,  1F00 DOP TB,

: GCOP    CREATE , DOES> @ SWAP 000F AND 40 * + GOP' ;

3000 GCOP LDCR,
3400 GCOP STCR,
HEX
\ Wycove assembler register syntax:
: @@        020    ;  \ symbolic addressing
: **        010 +  ;  \ indirect addressing
: *+        030 +  ;  \ indirect addressinin auto-increment
: ()        20  +  ;  \ indexed addressing

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

CR .( Simplified branching and looping)
: AJUMP,  ( token --) >< 1000 + T, ; \ hex 1000 is JMP 0 instruction
: RESOLVE ( addr offset --)  2- 2/ SWAP 1+ C! ;
: <BACK   ( addr addr' -- ) TUCK -  RESOLVE ;

: IF,     ( token -- addr) THERE SWAP AJUMP, ;
: ENDIF,  ( addr --)  THERE OVER -  RESOLVE ;
: ELSE,   ( -- addr ) THERE 0 JMP, SWAP ENDIF, ;

: BEGIN,  ( -- addr)  THERE ;
: WHILE,  ( token -- *while *begin) IF, SWAP ;
: AGAIN,  ( *begin --)  THERE  0 JMP, <BACK ;
: UNTIL,  ( *begin token --) THERE SWAP AJUMP, <BACK ;
: REPEAT, ( *while *begin -- ) AGAIN, ENDIF, ;

CR .( Pseudo instructions)
: RT,     ( -- )  R11 ** B, ;
: NOP,    ( -- )  0 JMP, ;
: NEXT,   ( -- )  R10 **  B, ;  \ CAMEL99 NEXT routine

CR .( CAMEL99 special registers & modes)
4 CONSTANT TOS
: (TOS)  TOS () ;     : *TOS   TOS ** ;     : *TOS+  TOS *+ ;

6 CONSTANT SP
: (SP)   SP () ;      : *SP    SP ** ;      : *SP+   SP *+ ;

7 CONSTANT RP
: (RP)   RP () ;      : *RP    RP ** ;      : *RP+   RP *+ ;

8 CONSTANT W
: (W)    W ()  ;      : *W     W **  ;      : *W+    W *+  ;

9 CONSTANT IP
: (IP)   IP () ;      : *IP    IP ** ;      : *IP+   IP *+ ;

: *R10      R10 ** ;
: *R11      R11 ** ;

\ PUSH & POP for both stacks
: PUSH,         ( src -- )  SP DECT,  *SP  MOV, ;    \ 10+18 = 28  cycles
: POP,          ( dst -- )  *SP+      SWAP MOV, ;    \ 22 cycles

: RPUSH,        ( src -- ) RP DECT,  *RP   MOV, ;
: RPOP,         ( dst -- ) *RP+      SWAP  MOV, ;

CR .( Enumerated labels)
DECIMAL
25 CONSTANT #FWD
20 CONSTANT #LABELS

\ Make a stack to handle jumps
CREATE FS0    #FWD CELLS ALLOT
FS0 CREATE FSP ,   \ fwd stack pointer, initialzed to FS0
: FSDEPTH ( -- n) FS0 FSP @ -  2/ ;
: >FS     ( addr --) 2 FSP +!   FSP @ ! ;
: FS>     ( -- addr)
          FSP @  DUP FS0 = ABORT" Label stack empty"
          @  -2 FSP +!  ;

CREATE LABELS   #LABELS CELLS ALLOT
: ]LBL  ( n -- addr) CELLS LABELS + ;  \ array of label addresses

: NEWLABELS  ( -- )
    LABELS  #LABELS CELLS 0 FILL  \ clear label array
    FS0 FSP !   \ reset fwd stack pointer to base address
;

: $:  ( n -- )  THERE SWAP ]LBL !   ;
: $   ( n -- 0) THERE >FS  >FS   0  ;  \ push address and index. Return zero

: ?LABEL  ( addr -- addr) DUP 0= ABORT" Un-resolved forward jump" ;

: RESOLVER ( -- )
       BEGIN
       FSDEPTH
       WHILE
           FS> ]LBL @ ?LABEL ( lbladdress )
           FS> TUCK - ( jmpaddr offset) RESOLVE
       REPEAT ;

: +CODE   ( <name> ) CODE ;       \ used to jump across CODE words
: CODE    ( <name> ) CODE NEWLABELS ;
: ENDCODE ( -- ) ?CSP RESOLVER  ;
: L:   ( <text> ) CONSTANT ;

CR CR .( Cross Assembler loaded)
CR HERE SWAP - DECIMAL . .( bytes)
HEX
