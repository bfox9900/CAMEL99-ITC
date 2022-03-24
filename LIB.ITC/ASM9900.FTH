\ ORIGINAL TI-FORTH ASSEMBLER modified by Mark Wills, Turboforth
\  Dec 23,2020
\    Huge simplification with ANS style branching & looping. Brian Fox

\ *NOTES:
\     Compare instruction has been changed to CMP,
\     Changed  A, and S, to ADD, SUB,

CR .( CAMEL99 Assembler V2.2 Dec 2020)

HERE   \ save the dictionary pointer for size calc. at end

HEX
CR .( Loading Assembler @ ) HERE U.
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
: ADR? ( n -- ? ) DUP 1F > SWAP 30 < AND ;  \ address or register?
: GOP' ( arg instr --)
       OVER ADR?
       IF   + , ,                    \ compile instruction & address
       ELSE + ,                      \ compile register
       THEN ;

: GOP ( instr --) CREATE , DOES> @ GOP' ;

0440 GOP B,    0680 GOP BL,   0400 GOP BLWP,
04C0 GOP CLR,  0700 GOP SETO, 0540 GOP INV,
0500 GOP NEG,  0740 GOP ABS,  06C0 GOP SWPB,
0580 GOP INC,  05C0 GOP INCT, 0600 GOP DEC,
0640 GOP DECT, 0480 GOP X,

: GROP     CREATE , DOES> @ SWAP 40 * + GOP' ;

2000 GROP COC,  2400 GROP CZC,  2800 GROP XOR,
3800 GROP MPY,  3C00 GROP DIV,  2C00 GROP XOP,

: GGOP     CREATE ,
           DOES> @ SWAP DUP ADR?
                 IF   40 * + SWAP >R GOP' R> ,
                 ELSE 40 * + GOP'  THEN ;
HEX
A000 GGOP ADD,  B000 GGOP ADDB, 8000 GGOP CMP, 9000 GGOP CMPB,
6000 GGOP SUB,  7000 GGOP SUBB, E000 GGOP SOC, F000 GGOP SOCB,
4000 GGOP SZC,  5000 GGOP SZCB, C000 GGOP MOV, D000 GGOP MOVB,

\ : 0OP     CREATE ,  DOES> @ , ;
\ 0340 0OP IDLE,    \ "should not be used in TI99"
\ 0360 0OP RSET,
\ 03C0 0OP CKOF,
\ 03A0 0OP CKON,
\ 03E0 0OP LREX,
: RTWP,  0380 , ;

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
 1000 DOP JMP,  1100 DOP JLT,  1200 DOP JLE,  1300 DOP JEQ,
 1400 DOP JHE,  1500 DOP JGT,  1600 DOP JNE,  1700 DOP JNC,
 1800 DOP JOC,  1900 DOP JNO,  1A00 DOP JL,   1B00 DOP JH,
 1C00 DOP JOP,

 \ cru bit instructions
 1D00 DOP SBO,
 1E00 DOP SBZ,
 1F00 DOP TB,

CR .( Jump tokens)
HEX                  \ Action if TRUE
 01 CONSTANT GTE     \ JLT to ENDIF, *signed
 02 CONSTANT HI      \ JLE to ENDIF,
 03 CONSTANT NE      \ JEQ to ENDIF,
 04 CONSTANT LO      \ JHE to ENDIF,
 05 CONSTANT LTE     \ JGT to ENDIF, *signed
 06 CONSTANT EQ      \ JNE to ENDIF,
 07 CONSTANT OC      \ JNC to ENDIF,
 08 CONSTANT NC      \ JOC to ENDIF,
 09 CONSTANT OO      \ JNO to ENDIF,
 0A CONSTANT HE      \ JLO to ENDIF,
 0B CONSTANT LE      \ JH  to ENDIF,
 0C CONSTANT NP      \ JOP to ENDIF,

: GCOP    CREATE , DOES> @ SWAP 000F AND 40 * + GOP' ;
3000 GCOP LDCR,
3400 GCOP STCR,

HEX
\ Wycove assembler register syntax:
: @@        020    ;  \ symbolic addressing
: **        010 +  ;  \ indirect addressing
: *+        030 +  ;  \ indirect addressing, auto-increment
: ()        20  +  ;  \ indexed addressing

CR .( Simplified branching and looping)
: AJUMP,  ( token --) >< 1000 + , ;   \ >1000+token makes a jump instruction
: RESOLVE ( 'jmp offset --)  2- 2/ SWAP 1+ C! ; \ compile offset into 'jmp'
: <BACK   ( addr addr' -- ) TUCK -  RESOLVE ;

: IF,     ( addr token -- 'jmp') HERE SWAP AJUMP, ;
: ENDIF,  ( 'jmp addr --)  HERE OVER -  RESOLVE ;
: ELSE,   ( -- addr ) HERE 0 JMP, SWAP ENDIF, ;

: BEGIN,  ( -- addr)  HERE ;
: WHILE,  ( token -- *while *begin) IF, SWAP ;
: AGAIN,  ( *begin --) HERE  0 JMP, <BACK ;
: UNTIL,  ( *begin token --) HERE SWAP AJUMP, <BACK ;
: REPEAT, ( *while *begin -- ) AGAIN, ENDIF, ;

: ;CODE
            POSTPONE (;CODE)   \ compiles (;CODE) into definition
            ?CSP POSTPONE [    \ turns off the Forth compiler
            REVEAL             \ (just like ";" does)
           ; IMMEDIATE         \ this is an IMMEDIATE word

\ ============================================================
CR .( CAMEL99 Forth customization)
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
: PUSH,   ( src -- )  SP DECT,  *SP  MOV, ;  \ 10+18 = 28  cycles
: POP,    ( dst -- ) *SP+       SWAP MOV, ;  \ 22 cycles

: RPUSH,  ( src -- ) RP DECT,  *RP   MOV, ;
: RPOP,   ( dst -- ) *RP+      SWAP  MOV, ;


CR CR .( Assembler loaded)
CR HERE SWAP - DECIMAL .  .( BYTES used)
HEX
