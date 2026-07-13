\ TI-99 Prefix Assembler for Camel99 Forth  July 2026

\ based TI-FORTH ASSEMBLER

\ *NOTES:
\     Compare instruction has been changed to CMP,
\     Changed  A, and S, to ADD, SUB,

NEEDS DUMP   FROM DSK1.TOOLS
NEEDS CASE   FROM DSK1.CASE

NEEDS WORDLIST FROM DSK1.WORDLISTS


CR .( CAMEL99 Prefix Assembler V0.1 2026)

HERE  \ for measuring size of code

\ Macro.fth   BY WIL BADEN  r.i.p
\ Usage:  MACRO RDROP  " R> DROP"
: SLITERAL ( ca u --) POSTPONE (S")  S,  ; IMMEDIATE
: MACRO
  :  CHAR PARSE  POSTPONE SLITERAL  POSTPONE EVALUATE POSTPONE ; IMMEDIATE
;


VOCABULARY ASSEMBLER
ONLY FORTH ALSO ASSEMBLER DEFINITIONS

HEX
\ Addressing mode controls
: @@        020    ;  \ symbolic addressing
: **        010 +  ;  \ indirect addressing
: *+        030 +  ;  \ indirect addressing, auto-increment
: ()        20  +  ;  \ indexed addressing


\ characters as constants
CHAR ,  CONSTANT ','
CHAR $  CONSTANT '$'
CHAR >  CONSTANT '>'
CHAR @  CONSTANT '@'

\ labels return a memory address
: L:  ( -- addr) CREATE HERE , DOES> @ ;


: MATCH  ( addr len char -- ?) 2 PICK C@ = ;

\ <cnt> is taken from the editor Assembler Manual. ie: Numeric arg
: <cnt> ( addr len -- n)
   '>'  MATCH
   IF HEX  1 /STRING THEN NUMBER? ABORT" Bad number" ;


: LASTLABEL! ( n -- )  LATEST @ NFA>CFA >BODY ! ;
\ EQU must be used with the label definer  'L:'
: EQU   PARSE-NAME  <cnt> LASTLABEL! DECIMAL   ;


\ ************************************************************
\  ARGUMENT TESTERS
: $POS    ( addr len char -- n) SCAN NIP ;
: ?COMMA  ( addr len -- addr len )
   2DUP ',' $POS 0= ABORT" Comma expected" ;

: ?LABEL  ( addr len -- addr len )
   2DUP '$' $POS 0= ABORT" '$' expected" ;

: ?1ARG   ( addr len -- addr len)
   2DUP ',' $POS ABORT" One arg expected" ;

HEX
: ?REG     ( n -- n ?)
    DUP 0F 0 WITHIN ABORT" Bad address mode" ;

\ 0 .. 3F covers all registers and addressing modes
: ?REG*+  ( n -- n ?)
    DUP 3F 0 WITHIN ABORT" Register required" ;

: ?HEXADDR   '>' MATCH IF HEX  1 /STRING THEN ;

\ accept address or register
: <gas> ( addr len -- addr|reg)
   '@' MATCH
   IF    1 /STRING         \ Process as address
         ?HEXADDR EVALUATE
         @@                \ symbolic addressing operator

   ELSE  EVALUATE ?REG*+   \ evaluate as register

   THEN  DECIMAL           \ restore default radix
;


DECIMAL
\ ************************************************************
\ *               ARGUMENT PARSING WORDS

: PARSE-LINE ( -- addr len ) 1 PARSE ;

: <LABEL>  PARSE-LINE ?LABEL EVALUATE ;

: <REG>    ( -- n)  PARSE-NAME EVALUATE  ?REG ;
: <*REG+>  ( -- u u ) PARSE-LINE  EVALUATE  ?REG*+ ;
: <#ARG>   ( -- u)    BL PARSE  <cnt>  ;

\ split string at comma & remove comma from $2
: ARG,ARG ( addr len -- addr1 len1 addr2 len2)
  ?COMMA          \ test comma present
  ',' SPLIT       \ split strings at comma
   BL SKIP        \ arg1 remove leading spaces
   2SWAP
   1 /STRING      \ arg2 cut leading comma
;

: <REG,#>  ( -- )
   PARSE-LINE ARG,ARG
   2>R  EVALUATE \ ?REG
   2R> <cnt> ;

: <1ARG>  ( <text> -- n) PARSE-NAME  <gas> ;

: <gas>,<gad> ( <arg1>,<arg2> -- u u )
   PARSE-LINE ARG,ARG
   2>R <gas>  \ process arg1
   2R> <gas>  \ process arg2
;

: <gas>,<cnt>
   PARSE-LINE ARG,ARG
   2>R <gas>
   2R> <cnt>
;

: <jmptoken> ( <text> -- n)
   PARSE-NAME <cnt> DUP 1 13 WITHIN 0= ABORT" Jump token expected" ;

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

\ INDIRECT addressing register names
: *R0    R0 ** ;
: *R1    R1 ** ;    : *R2    R2 ** ;   : *R3    R3 ** ;
: *R4    R4 ** ;    : *R5    R5 ** ;   : *R6    R6 ** ;
: *R7    R7 ** ;    : *R8    R8 ** ;   : *R9    R9 ** ;
: *R10   R10 ** ;   : *R11  R11 ** ;   : *R12  R12 ** ;
: *R13   R13 ** ;   : *R14  R14 ** ;   : *R15  R15 ** ;

\ INDIRECT addressing, auto-increment register names
: *R0+    R0 *+ ;
: *R1+    R1 *+ ;    : *R2+    R2 *+ ;   : *R3+    R3 *+ ;
: *R4+    R4 *+ ;    : *R5+    R5 *+ ;   : *R6+    R6 *+ ;
: *R7+    R7 *+ ;    : *R8+    R8 *+ ;   : *R9+    R9 *+ ;
: *R10+   R10 *+ ;   : *R11+  R11 *+ ;   : *R12+  R12 *+ ;
: *R13+   R13 *+ ;   : *R14+  R14 *+ ;   : *R15+  R15 *+ ;

\ indexed addressing register names
: (R0)    TRUE ABORT" R0 cannot be indexed" ;
: (R1)    R1 () ;   : (R2)    R2 () ;   : (R3)    R3 () ;
: (R4)    R4 () ;   : (R5)    R5 () ;   : (R6)    R6 () ;
: (R7)    R7 () ;   : (R8)    R8 () ;   : (R9)    R9 () ;
: (R10)  R10 () ;   : (R11)  R11 () ;   : (R12)  R12 () ;
: (R13)  R13 () ;   : (R14)  R14 () ;   : (R15)  R15 () ;

HEX
: ADR? ( n -- ? ) DUP 1F > SWAP 30 < AND ;  \ address or register?

: GOP'
 ( arg instr --)
    OVER ADR?
    IF   + , ,                    \ compile instruction & address
    ELSE + ,                      \ compile register
    THEN ;

: GOP ( instr --) CREATE ,  DOES> @ >R  <1ARG>  R> GOP' ;
0440 GOP B      0680 GOP BL     0400 GOP BLWP
04C0 GOP CLR    0700 GOP SETO   0540 GOP INV
0500 GOP NEG    0740 GOP ABS    06C0 GOP SWPB
0580 GOP INC    05C0 GOP INCT   0600 GOP DEC
0640 GOP DECT   0480 GOP X

: GROP     CREATE , DOES> @ >R  <gas>,<gad>  R> SWAP 40 * + GOP' ;
2000 GROP COC  2400 GROP CZC  2800 GROP XOR
3800 GROP MPY  3C00 GROP DIV  2C00 GROP XOP

: GGOP     CREATE ,    \ Format I
           DOES> @ >R
                <gas>,<gad>
                R> SWAP DUP ADR?
                IF   40 * + SWAP >R GOP' R> ,
                ELSE 40 * + GOP'  THEN ;
HEX
A000 GGOP ADD   B000 GGOP ADDB  8000 GGOP CMP
9000 GGOP CMPB  6000 GGOP SUB   7000 GGOP SUBB
E000 GGOP SOC   F000 GGOP SOCB  4000 GGOP SZC
5000 GGOP SZCB  C000 GGOP MOV   D000 GGOP MOVB

\ : 0OP     CREATE ,  DOES> @ , ;
\ 0340 0OP IDLE,    \ "should not be used in TI99"
\ 0360 0OP RSET,
\ 03C0 0OP CKOF,
\ 03A0 0OP CKON,
\ 03E0 0OP LREX,
: RTWP     0380 , ;

: ROP     CREATE   , DOES> @ >R  <#ARG>  R> + , ;
02C0 ROP STST
02A0 ROP STWP

: IOP     CREATE , DOES> @ , <#ARG> , ;
02E0 IOP LWPI
0300 IOP LIMI

: RIOP    CREATE , DOES> @ <R  <REG,#>  R> ROT + , , ;
0220 RIOP AI
0240 RIOP ANDI
0280 RIOP CI
0200 RIOP LI
0260 RIOP ORI

: RCOP    CREATE , DOES> @ >R  <REG,#>  R> SWAP 10 * + + , ;
0A00 RCOP SLA
0800 RCOP SRA
0B00 RCOP SRC
0900 RCOP SRL

CR .( jump instructions)
: DOP     CREATE , DOES> @ >R  <LABEL>  R> SWAP 00FF AND OR , ;
 1000 DOP JMP  1100 DOP JLT  1200 DOP JLE  1300 DOP JEQ
 1400 DOP JHE  1500 DOP JGT  1600 DOP JNE  1700 DOP JNC
 1800 DOP JOC  1900 DOP JNO  1A00 DOP JL   1B00 DOP JH
 1C00 DOP JOP

 \ cru bit instructions
 1D00 DOP SBO
 1E00 DOP SBZ
 1F00 DOP TB

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

: GCOP  CREATE ,
        DOES> @ >R
              <gas>,<cnt>
              R> SWAP 000F AND 40 * + GOP' ;

3000 GCOP LDCR
3400 GCOP STCR

CR .( Simplified branching and looping)
: AJUMP,  ( token --) >< 1000 + , ;   \ >1000+token makes a jump instruction
: RESOLVE ( 'jmp offset --)  2- 2/ SWAP 1+ C! ; \ compile offset into 'jmp'
: <BACK   ( addr addr' -- ) TUCK -  RESOLVE ;

: IF      ( addr token -- 'jmp') <jumptoken>  HERE SWAP AJUMP, ;
: ENDIF   ( 'jmp addr --)  HERE OVER -  RESOLVE ;
: ELSE    ( -- addr ) HERE 0 JMP, SWAP ENDIF, ;

: BEGIN   ( -- addr)  HERE ;
: WHILE   ( token -- *while *begin) IF SWAP ;
: AGAIN   ( *begin --) HERE  0 JMP, <BACK ;
: UNTIL   ( *begin token --) <jumptoken> HERE SWAP AJUMP, <BACK ;
: REPEAT ( *while *begin -- ) AGAIN ENDIF ;

: ;CODE
       POSTPONE (;CODE)   \ compiles (;CODE) into definition
       ?CSP POSTPONE [    \ turns off the Forth compiler
       REVEAL             \ (just like ";" does)
; IMMEDIATE

HERE SWAP - DECIMAL CR .

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
HEX
: RT      ( -- )  S" B *R11" EVALUATE ;
: NOP,    ( -- )  0 AJUMP, ;
: NEXT,   ( -- )  045A ,  ;  \ CAMEL99 NEXT: B *R10

\ PUSH & POP for both stacks
MACRO PUSH  " SP DECT,  <REG> *SP  MOV,"   \ 10+18 = 28  cycles
MACRO POP   " MOV <REG> *SP+   SWAP MOV,"  \ 22 cycles

: RPUSH,  ( src -- ) RP DECT,  *RP   MOV, ;
: RPOP,   ( dst -- ) *RP+      SWAP  MOV, ;


\ a LEAF: is the simplest 9900 native sub-routine.
\ Call with BL
\ Exit with RT
: LEAF:  CREATE   !CSP  ;
: ;LEAF  ?CSP ;

 \ a "sub:" is a nestable sub-routine.
 \ Call with BL
 \ Exit using RET
: SUB:   CREATE   S" PUSH R11" EVALUATE !CSP  ;
: ;SUB   ?CSP ;
: RET    S" POP R11  RT" EVALUATE ;

\ A "prog:" Takes a workspace argument and creates a vector
\ to the code follwing the declaration.
\ Call with BLWP
\ Exit with RTWP
\ Exit a PROG: using the RTWP instrucion
: PROG: ( wksp -- ) CREATE    ,  HERE CELL+ , !CSP    ;
: ;PROG  ( -- ) ?CSP  ;



CR CR .( Assembler loaded)
CR HERE SWAP - DECIMAL .  .( BYTES used)
HEX
