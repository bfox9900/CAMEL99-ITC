\ Prefix Assembler Extensions  July 2026

\ load postfix Assembler and use to make prefix version

NEEDS ORDER FROM DSK1.WORDLISTS

ONLY FORTH DEFINITIONS

NEEDS MEM@  FROM DSK1.TOOLS

\ split a string char. Return 2 strings
: SPLIT ( addr len char -- str2 len2 str1 len1)
   >R  2DUP  R> SCAN  2SWAP  2 PICK  - ;

HERE
DECIMAL

VOCABULARY ASSEMBLER
ONLY FORTH ALSO ASSEMBLER DEFINITIONS

NEEDS MOV,     FROM DSK1.ASM9900
NEEDS RESOLVER FROM DSK1.ASMLABELS
HEX

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

\ characters as constants
CHAR ,  CONSTANT ','
CHAR $  CONSTANT '$'
CHAR >  CONSTANT '>'
CHAR @  CONSTANT '@'

\ labels return a memory address
: L:  ( -- addr) CREATE HERE , DOES> @ ;

: MATCH  ( addr len char -- ?) 2 PICK C@ = ;

: $># ( addr len -- n)
   '>'  MATCH
   IF HEX  1 /STRING THEN NUMBER? ABORT" Bad number" ;


: LASTLABEL! ( n -- )  LATEST @ NFA>CFA >BODY ! ;
\ EQU must be used with the label definer  'L:'
\ L: MYLABEL EQU >BEEF  \ uses '>' prefix to convert to HEX


: BASE{  S" BASE @ >R" EVALUATE ; IMMEDIATE
: }BASE  S" R> BASE !" EVALUATE ; IMMEDIATE

\ equ overwrites the contents of the label with a number.
: EQU   PARSE-NAME  $># LASTLABEL! DECIMAL   ;

: $POS  ( addr len char -- n) SCAN NIP ;

\ ************************************************************
\  ARGUMENT TESTERS
: ?COMMA  ( addr len -- addr len )
   2DUP ',' $POS 0= ABORT" Comma expected" ;

: ?LABEL  ( addr len -- addr len )
   2DUP '$' $POS 0= ABORT" '$' expected" ;

: ?1ARG   ( addr len -- addr len)
   2DUP ',' $POS ABORT" One arg expected" ;

: ?REG     ( n -- n ?) DUP 0F 0 WITHIN ABORT" Bad address mode" ;

\ 0 .. 3F covers all registers and addressing modes
: ?REG*+  ( n -- n ?) DUP 3F 0 WITHIN ABORT" Register required" ;

: ?HEXADDR   '>' MATCH IF HEX  1 /STRING THEN ;

: ?ADDR|REG ( addr len -- addr|reg)
   '@' MATCH
   IF    1 /STRING         \ Process as address
         ?HEXADDR EVALUATE
         @@                \ symbolic addressing operator

   ELSE  EVALUATE ?REG*+   \ evaluate as register
   THEN  DECIMAL           \ restore default radix
;


\ ************************************************************
\ *               ARGUMENT PARSING WORDS

: <LABEL>  1 PARSE ?LABEL EVALUATE ;

\ split string at comma & remove comma from $2
: <ARG,ARG> ( addr len -- addr1 len1 addr2 len2)
  ?COMMA          \ test comma present
  ',' SPLIT       \ split strings at comma
   BL SKIP        \ arg1 remove leading spaces
   2SWAP
   1 /STRING      \ arg2 cut leading comma
;

: <REG>    ( -- n) PARSE-NAME EVALUATE  ?REG ;

: <*REG+>  ( -- u u ) 1 PARSE  EVALUATE  ?REG*+ ;

: <#ARG>   ( -- u)    BL PARSE  $>#  ;

: <REG,#>  ( -- )
   1 PARSE <ARG,ARG>
   2>R  EVALUATE \ ?REG
   2R> $># ;

: <1ARG>  ( <text> -- n) 1 PARSE  BL SKIP  ?ADDR|REG ;

: <2ARGS>  ( <arg1>,<arg2> -- u u )
   1 PARSE <ARG,ARG>
   2>R ?ADDR|REG  \ process arg1
   2R> ?ADDR|REG  \ process arg2
;

: <JMPTOKEN> ( <text> -- n)
   <1ARG>  DUP 1 13 WITHIN 0= ABORT" Jump token expected" ;

\ ************************************************************
\ Prefix instructions with 1 arg

: B     <1ARG>  B, ;
: BL    <1ARG>  BL, ;
: BLWP  <1ARG>  BLWP, ;

: CLR   <1ARG>  CLR, ;
: SETO  <1ARG>  SETO, ;
: INV   <1ARG>  INV, ;
: NEG   <1ARG>  NEG, ;
: ABS   <1ARG>  ABS, ;
: SWPB  <1ARG>  SWPB, ;
: INC   <1ARG>  INC,  ;
: INCT  <1ARG>  INCT, ;
: DEC   <1ARG>  DEC, ;
: DECT  <1ARG>  DECT, ;
: X     <1ARG>  X, ;

\ 2 ARG instructions
: COC   <2ARGS> COC, ;
: CZC   <2ARGS> CZC, ;
: XOR   <2ARGS> XOR, ;
: MPY   <2ARGS> MPY, ;
: DIV   <2ARGS> DIV, ;
: XOP   <2ARGS> XOP, ;

: ADD   <2ARGS> ADD, ;
: ADDB  <2ARGS> ADDB, ;
: CMP   <2ARGS> CMP, ;
: CMPB  <2ARGS> CMPB, ;
: SUB   <2ARGS> SUB,  ;
: SUBB  <2ARGS> SUBB, ;
: SOC   <2ARGS> SOC, ;
: SOCB  <2ARGS> SOCB, ;
: SZC   <2ARGS> SZC,  ;
: SZCB  <2ARGS> SZCB, ;
: MOV   <2ARGS> MOV, ;
: MOVB  <2ARGS> MOVB, ;

\ NO arg instructions
: RTWP   RTWP, ;

: STST   <#ARG>  STST, ;
: STWP   <#ARG>  STWP, ;

: LWPI   <#ARG> LWPI, ;
: LIMI   <#ARG> LIMI, ;

: AI     <REG,#> AI, ;
: ANDI   <REG,#> ANDI, ;
: CI     <REG,#> CI, ;
: LI     <REG,#> LI, ;
: ORI    <REG,#> ORI, ;


: SLA    <REG,#> SLA, ;
: SRA    <REG,#> SRA, ;
: SRC    <REG,#> SRC, ;
: SRL    <REG,#> SRL, ;


: JMP   <LABEL> JMP, ;
: JLT   <LABEL> JLT, ;
: JLE   <LABEL> JLE, ;
: JEQ   <LABEL> JEQ, ;
: JHE   <LABEL> JHE, ;
: JGT   <LABEL> JGT, ;
: JNE   <LABEL> JNE, ;
: JNC   <LABEL> JNC, ;
: JOC   <LABEL> JOC, ;
: JNO   <LABEL> JNO, ;
: JL    <LABEL> JL, ;
: JH    <LABEL> JH, ;
: JOP   <LABEL> JOP, ;

CR .( Pseudo instructions...)
: RT      RT, ;
: NOP     NOP, ;
: RET/NEXT ( -- )  R10 **  B, ;

\ Just because we can
: OR  SOC ;
 : ORB SOCB ;

\ PUSH & POP macros for DATA stack
: PUSH  <REG> PUSH, ;
: POP   <REG> POP, ;

\ PUSH & POP macros for RETURN stack
: RPUSH  <REG> RPUSH, ;
: RPOP   <REG> RPOP, ;

: IF      ( addr token -- 'jmp') <JMPTOKEN> IF,  ;
: ENDIF   ( 'jmp addr --) ENDIF,  ;
: ELSE    ( -- addr ) ELSE, ;

: BEGIN   ( -- addr)  HERE ;
: WHILE  ( token -- *while *begin) IF  SWAP ;
: AGAIN  ( *begin --) AGAIN, ;
: UNTIL   ( *begin token --)  <JMPTOKEN> UNTIL, ;
: REPEAT ( *while *begin -- ) AGAIN, ENDIF, ;

\ end directive can have a label following to indicate the label to start
: END       RESOLVER ;  \ resolve all jmp labels

: CODE      ALSO ASSEMBLER  CODE ;
: ENDCODE   RESOLVER ?CSP  PREVIOUS ;

\ ------------------------------------------------
: (CODE) ALSO ASSEMBLER CREATE  ;

\ a LEAF: is the simplest 9900 native sub-routine.
\ Call with BL
\ Exit with RT
: LEAF:   (CODE)  !CSP  ;
: ;LEAF  ?CSP PREVIOUS ;

 \ a "sub:" is a nestable sub-routine.
 \ Call with BL
 \ Exit using RET
: SUB:   (CODE)   R11 PUSH,  !CSP  ;
: ;SUB   ;LEAF ;
: RET    R11 POP,  RT,  ;     \ Return from sub-routine

\ A "prog:" Takes a workspace argument and creates a vector
\ to the code follwing the declaration.
\ Call with BLWP
\ Exit with RTWP
\ Exit a PROG: using the RTWP instrucion
: PROG: ( wksp -- ) (CODE)   ,  HERE CELL+ , !CSP    ;
: ;PROG  ( -- ) ;LEAF ;

ONLY FORTH DEFINITIONS ALSO ASSEMBLER
\ override these words in the kernel with the new versions
: CODE      CODE ;
: ENDCODE  ENDCODE ;

ONLY FORTH ALSO ASSEMBLER ALSO FORTH
HERE SWAP - DECIMAL CR .  .( bytes)
