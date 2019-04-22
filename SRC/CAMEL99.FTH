\ CAMEL99 Forth for the TI-99  un-optimized  version  11Apr2019
\ Copyright (c) 2018 Brian Fox
\ KILWORTH Ontario Canada
\ brian.fox@brianfox.ca

\ compiles with XFCC99.EXE cross-compiler

\ This program is free software; you can redistribute it and/or modify
\ it under the terms of the GNU General Public License as published by
\ the Free Software Foundation; either version 3 of the License, or
\ (at your option) any later version.
\ You should have received a copy of the GNU General Public License
\ along with this program.  If not, see <http://www.gnu.org/licenses/>.
\
\ The work derived from CAMEL Forth under the GNU General Public License.
\ CamelForth (c) 2009 Bradford J. Rodriguez.
\ Commercial inquiries for Camel Forth should be directed to:
\ 115 First St., #105, Collingwood, Ontario L9Y 4W3 Canada
\ or via email to bj@camelforth.com

\ History
\ Apr 11 2019 removed unnecessary comments for clarity
\             removed conditional compilation switches

\ ========================================================================
\ M E M O R Y   U S A G E   D E F I N I T I O N S
CROSS-COMPILING
HEX
       0FFF0   EQU EMEM    \ EMEM = "end of memory"
   EMEM 0080 - EQU 'TIB    \ ADDRESS OF Terminal Input Buffer
   EMEM 'TIB - EQU TIBSIZE \ 128 bytes

\  FORTH stacks at upper end of TI-99 memory
HEX
     'TIB 2-   EQU SP0    \ FORTH parameter stack base address.
      SP0 80 - EQU RP0    \ FORTH return stack base address

\ ========================================================================
\ configure cross-compiler header and threading mechanism
CROSS-COMPILING

 INCLUDE CC9900\compiler\ITCTYPES.HSF   \ indirect threaded versions
\ ========================================================================
\ C O D E   P R I M I T I V E S
\ [CC] is short form for CROSS-COMPILING

[CC] cr .( Compile Forth Assembler primitives ...)

 INCLUDE CC9900\9900FAS2.HSF
 INCLUDE CC9900\TI99PRIM.HSF

\ ========================================================================
\ RESOLVE CODE WORD FORWARD REFERENCES FOR CROSS-COMPILER

[CC]
 T' EXIT   RESOLVES 'EXIT
    ENTR   RESOLVES 'DOCOL
 T' DOVAR  RESOLVES 'DOVAR
 T' LIT    RESOLVES 'LIT
 T' DOCON  RESOLVES 'DOCON
 T' DOUSER RESOLVES 'DOUSER
 T' DODOES RESOLVES 'DODOES

\ ========================================================================
\ T A R G E T   D E - C O M P I L E R
\ debugging tool

CROSS-COMPILING
FALSE [IF]   INCLUDE CC9900\CCLIB\TSEE.HSF   [THEN]

\ ========================================================================
\ T A R G E T  S T A T E  C O N T R O L

TARGET-COMPILING

   VARIABLE: STATE

   STATE [CC] TO XSTATE

\ ========================================================================
\ C R O S S   C O M P I L E R   B O O T - S T R A P P I N G
\ add loop and branch words to the cross-compiler (not the TARGET)

CROSS-COMPILING
INCLUDE CC9900\cclib\BOOTSTRP.HSF

\ ========================================================================
\ S Y S T E M   C O N S T A N T S

[CC] HEX
cr .( Constants and Variables...)

TARGET-COMPILING
\ ASM/Equate       Forth Name
\ -----------      ------------
 'TIB     constant: TIB
 SP0      constant: SP0
 RP0      constant: RP0
 TIBSIZE  constant: TIB#

\ Utility constants
        0 constant: FALSE
       -1 constant: TRUE
        0 constant: 0
        1 constant: 1
        2 constant: 2
        3 constant: 3
       20 constant: BL

\ ========================================================================
\ U S E R   V A R I A B L E S
\ CAMEL99 uses space after workspace for user vars.
\ User variables begin at >8320 for the primary Forth task
[CC] HEX [TC]

      20 USER: TFLAG
      22 USER: JOB
      24 USER: DP
      26 USER: HP
      28 USER: CSP
      2A USER: BASE
      2C USER: >IN
      2E USER: C/L
      30 USER: OUT
      32 USER: VROW
      34 USER: VCOL
\      36 USER: CURRENT
\      38 USER: CONTEXT
      3A USER: LP
      3C USER: SOURCE-ID
      3E USER: 'SOURCE
\      40 USER: -------          \ used by 'SOURCE

      46 USER: TPAD

\ memory locations used by Forth ie: "variables"
 _CURSR constant: CURS
 _floor constant: FLOOR

 \ TI-99 system memory locations
   83C6 constant: KUNIT#  \ byte
   837C constant: GPLSTAT \ byte

\ These system variables control cold starting the system
variable: LATEST
variable: ORGDP
variable: ORGLAST
variable: BOOT

[CC] DECIMAL [TC]
   0024 constant: L/SCR

[CC] HEX [TC]
variable: VMODE
variable: VTOP
variable: L0  [CC] 3 CELLS TALLOT  [TC]
variable: ^PAB
variable: LINES
variable: C/SCR
variable: 'INTERPRET
variable: H

?stk
\ ========================================================================
[CC] cr .( Hi-level FORTH Primitives...)

TARGET-COMPILING
: HERE      ( -- addr) DP @  ;
: ALLOT     ( n --) DP +! ;
: COMPILE,  ( n -- ) HERE !   2 ALLOT ;
: ,         ( n -- )  COMPILE,  ;
: C,        ( c --)  HERE C!  1 ALLOT ;
: ALIGN     ( -- )   HERE ALIGNED DP ! ;
: PAD       ( -- addr) HERE TPAD @ + ;
: COMPILE   ( -- )  R> DUP 2+ >R @ COMPILE, ;
: IMMEDIATE ( --)  01 LATEST @ 1-  C! ;
: LITERAL   ( n -- n|~) STATE @ IF  COMPILE LIT  COMPILE,  THEN ;  XIMMEDIATE
: ]         ( -- ) STATE ON  ;  XIMMEDIATE
: [         ( -- ) STATE OFF ;  XIMMEDIATE

\ ========================================================================
\ Minimalist heap memory manager ( see SCROLL for example)
: MALLOC     ( n -- addr ) H @  SWAP H +! ;
: MFREE      ( n -- ) NEGATE H +! ;

\ ========================================================================
\ PAB base address
: VDPTOP  ( -- n) 8370 @ 2- ;

\ ========================================================================
\ S T A C K   P R I M I T I V E S
[CC] cr .( Stack primitives ...)  [tc]

: TUCK  ( w1 w2 --  w2 w1 w2 ) SWAP OVER ;

 CODE: 2>R    ( d -- ) ( r-- n n)
              RP -4 ADDI,          \ 14
              TOS 2 (RP) MOV,      \ 22
             *SP+   *RP MOV,       \ 26
              TOS POP,             \ 22
              NEXT,              \ = 84
              END-CODE

 CODE: 2R>     ( -- d )
              TOS PUSH,            \ 28
              SP DECT,             \ 10
             *SP  RPOP,            \ 26
              TOS RPOP,            \ 22
              NEXT,              \ = 88
              END-CODE

\ NOT standard forth. Equivalent to INC and DEC in Assembler
: 1+!   ( addr -- )  1 SWAP +! ;
: 1-!   ( addr -- ) -1 SWAP +! ;


\ ========================================================================
\ C O M P A R I S O N   O P E R A T O R S

TARGET-COMPILING
: U>  ( n n -- ?)  SWAP U< ;
: 0>  ( n -- ?)    1- 0< INVERT ;
: <>  ( n n == ?)  =  INVERT ;
: UMIN ( u1 u2 -- u )  2DUP U> IF SWAP THEN DROP ;
: UMAX ( u1 u2 -- u )  2DUP U< IF SWAP THEN DROP ;
: WITHIN ( u lo hi -- t ) OVER - -ROT - U> ;

\ ========================================================================
\ M I X E D  (32BIT/16BIT)   M A T H   O P E R A T I O N S

: */MOD  ( n1 n2 n3 -- n4 n5)  >R UM* R> M/MOD ;
: S>D    ( n -- d)  DUP 0< ;
: /MOD   ( n1 n2 -- n3 n4) >R S>D R> M/MOD ;
: /      ( n n -- n)   /MOD NIP  ;
: MOD    ( n n -- n)   /MOD DROP ;
: */     ( n n n -- n) */MOD NIP ;

\ ========================================================================
\ S T R I N G   T H I N G S

TARGET-COMPILING
: MOVE    ( src dst n -- )
          >R  2DUP SWAP DUP R@ +
          WITHIN
          IF    R> CMOVE>
          ELSE  R> CMOVE
          THEN ;

\ CAMEL Forth calls this ">COUNTED"
: PLACE   ( src n dst -- ) 2DUP C! 1+ SWAP MOVE ;
: /STRING ( c-addr1 u1 n -- c-addr2 u2 ) ROT OVER + -ROT - ;
: S,         ( c-addr u -- ) HERE OVER 1+ ALLOT PLACE  ALIGN ;

\ ========================================================================
\ H E A D E R   N A V I G A T I O N

TARGET-COMPILING
: NFA>LFA       ( nfa -- lfa)  3 - ;
: NFA>CFA       ( nfa -- cfa ) COUNT  7F AND + ALIGNED ;

\ smudge bit control in the Camel Forth
: HIDE          ( -- )  LATEST @ ( nfa) DUP C@ 80 OR  SWAP C! ;
: REVEAL        ( -- )  LATEST @ ( nfa) DUP C@ 7F AND SWAP C! ;

\ ========================================================================
\ P A R S E   W O R D
[CC] cr .( Parsing...)
TARGET-COMPILING
: SOURCE  'SOURCE 2@ ;    \ Common factor, saves space

                    [CC] [PRIVATE] [TC]
: ADR>IN      ( c-addr' --  ) SOURCE  -ROT -  MIN  0 MAX >IN ! ;

                    [CC] [PUBLIC] [TC]
: PARSE       ( char -- c-addr n)
              SOURCE >IN @ /STRING
              OVER >R ROT SCAN
              OVER SWAP
              IF 1+ THEN
              ADR>IN
              R> TUCK - ;

: PARSE-WORD  ( char -- c-addr n)
              DUP SOURCE >IN @ /STRING
              ROT SKIP
              DROP ADR>IN PARSE ;

: WORD        ( char -- c-addr)
              PARSE-WORD HERE PLACE
              HERE BL OVER COUNT + C! ;

\ ========================================================================
\ S T R I N G  T O  N U M B E R   C O N V E R S I O N
[CC] CR .( CAMEL FORTH Number conversion)
 HEX

TARGET-COMPILING

: DIGIT?     ( char -- n -1)
\            (      -- x  0 )
              DUP 39 > 100 AND +
              DUP 140 > 107 AND -
              T[CHAR] 0 -
              DUP BASE @ U< ;

                       [PRIVATE]
: ?SIGN      ( adr n -- adr' n' ?)
             OVER C@
             2C - DUP ABS 1 = AND
             DUP IF 1+
                    >R 1 /STRING R>
             THEN ;

                       [PUBLIC]
: UD*        ( ud1 u2 -- ud3)
             DUP >R * SWAP R> UM* ROT + ;

: >NUMBER    ( ud adr u -- ud' adr' u' )
            BEGIN  DUP
            WHILE
              OVER C@ DIGIT?
              IF  >R 2SWAP BASE @ UD*
                  R> M+ 2SWAP 1 /STRING
              ELSE DROP EXIT
              THEN
            REPEAT ;

: ?NUMBER    ( c-addr -- n -1 )
\ ;Z                  -- c-addr 0         \ if convert error
             DUP  0 0 ROT COUNT
             ?SIGN >R
             >NUMBER
             IF    R> 2DROP 2DROP FALSE
             ELSE  2DROP NIP R>
                IF NEGATE THEN TRUE
             THEN ;

\ ========================================================================
\ S I M P L E   S O U N D  I N T E R F A C E

[CC] include cc9900\cclib\ticktock.hsf   \ hardware milli-second timer

TARGET-COMPILING

\ write a byte to address of TMS9919 chip
: SND!   ( c -- )  8400 C!  ;  \ 4 bytes, 277 uS

: BEEP     ( -- )
            80 SND! 5 SND!   \ precalulated values for OSC1 1328Hz
            91 SND!
            AA MS
            9F SND! ;

: HONK     ( -- )
            81 SND! 20 SND!  \ precalculated values for OSC1 218Hz
            90 SND!
            AA MS
            9F SND! ;

\ ========================================================================
\ V D P  S C R E E N   D R I V E R
[CC] cr .( Console output)

TARGET-COMPILING
\ pronounced "SEE-PER-ELL-STORE"
: C/L!       ( c/l -- )
             DUP C/L !           \ set chars per line
             L/SCR *  C/SCR ! ;  \ calc.chars per screen

[cc] HEX [tc]

\ : GETXY   ( -- col row ) VROW 2@  ;
: AT-XY   ( col row -- ) VROW 2! ;
: VPOS    ( -- vaddr)    VROW 2@ >VPOS ;
: CLRLN   ( col row -- ) AT-XY VPOS C/L@ BL VFILL ;

\ -----------------------------------------------------------------------
\ Scrolling has been implemented in Forth using VREAD & VWRITE
\ MALLOC creates a temporary buffer to hold 2 lines of screen text

                            [PRIVATE]
\ calc size of 2 lines,
: 2C/L ( -- n)  C/L@ 2* ;   ( need to calculate if we support 80 column mode)

                            [PUBLIC]
: SCROLL   ( -- )
           2C/L DUP MALLOC ( -- n heap)
           C/SCR @
           C/L@  VTOP @ +  ( -- n heap c/scr vaddr)
           DO
              PAUSE
              I  ( -- c/scr heap vaddr)
              OVER 2DUP     2C/L VREAD
              SWAP C/L@ -   2C/L VWRITE
          2C/L +LOOP
           0 17 CLRLN
           DROP
           MFREE ;

\ ========================================================================
\ V D P   T E X T   O U T P U T

[cc] HEX [tc]

: CR   ( -- )
          OUT OFF   VCOL OFF  VROW 1+!
          VROW @ L/SCR =  IF  SCROLL  THEN PAUSE ;

: VPUT   ( char -- ) VPOS VC! ;

: (EMIT) ( char -- )
          VPUT
          OUT  1+!
          VCOL 1+!
          C/L@ VCOL @ = IF  CR THEN ;

: PAGE   ( -- )
          VTOP @
          DUP C/SCR @ OVER -
          BL VFILL
          0 SWAP C/L@ / AT-XY ;

: BS  ( --)  VCOL DUP @ 1- 0 MAX  SWAP !
             OUT 1-! ;

[CC] HEX [TC]
: EMIT      ( char -- )  \ shows how to handle control characters
            DUP 0D = IF  DROP CR   EXIT THEN
            DUP 08 = IF  DROP BS   EXIT THEN
            (EMIT)  ;

: TYPE      ( adr cnt --) PAUSE BOUNDS ?DO  I C@ EMIT LOOP ;
: SPACE     ( -- )   BL EMIT ;
: SPACES    ( n -- ) PAUSE 0 MAX  0 ?DO SPACE LOOP ;

\ ========================================================================
\ S T R I N G   L I T E R A L S
[cc] HEX [tc]
\ run-time action of S"   (For ITC Forth only)
: (S")      ( -- c-addr u) R>  COUNT  2DUP + ALIGNED  >R ;

\ ========================================================================
\ Re-solve CROSS-COMPILER Forward reference for '(S") and 'TYPE
CROSS-COMPILING

T' (S")  RESOLVES '(S")
T' TYPE  RESOLVES 'TYPE

[cc] cr .( Character input)
\ ========================================================================
\ C H A R A C T E R   I N P U T

TARGET-COMPILING
: KEY       ( -- char)
            BEGIN
              CURS@ VPUT
              PAUSE         \ Multi-tasking while we wait
              KEY?          \ call ROM KSCAN
            UNTIL
            8375 C@ 7F AND  \ read KSCAN buffer, mask to 7 bits
            BL VPUT ;

\ High level: input/output          (c) 31mar95 bjr
: ACCEPT     ( c-addr +n -- +n')
             OVER + 1- OVER
             BEGIN  KEY DUP 0D <>
             WHILE
                DUP EMIT
                DUP 8 =
                IF   DROP 1-  >R OVER R> UMAX
                ELSE OVER C!  1+ OVER UMIN
                THEN
             REPEAT
             DROP NIP SWAP -  ;

[cc] cr .( Number printing)
\ ======================================================================
\ N U M B E R   T O   S T R I N G   C O N V E R S I O N

TARGET-COMPILING
: UD/MOD ( ud1 u2 -- u3 ud4) >R 0 R@ UM/MOD -ROT R> UM/MOD ROT ;
: HOLD   ( char -- )  HP DUP 1-! @ C! ;
: >DIGIT ( n -- c) DUP 9 > 7 AND + 30 + ;
: <#     ( --)          PAD HP ! ;
: #      ( ud1 -- ud2)  BASE @ UD/MOD ROT  >DIGIT  HOLD  ;
: #S     ( ud1 -- ud2)  BEGIN  #   2DUP OR  WHILE REPEAT ;
: #>     ( ud1 -- c-addr u) 2DROP HP @ PAD OVER - ;
: SIGN   ( n -- ) 0< IF T[CHAR] -  HOLD THEN ;
: DU.    ( d -- ) <#  #S  #>  TYPE SPACE ;
: U.     ( u -- ) 0 DU. ;
: .      ( n -- ) DUP ABS 0  <# #S ROT SIGN #> TYPE SPACE ;

\ ========================================================================
\ M I S C E L L A N E O U S
[cc] HEX [tc]

: RECURSE     ( -- ) LATEST @ NFA>CFA COMPILE,  ; XIMMEDIATE
: DECIMAL     ( -- ) 0A BASE ! ;
: HEX         ( -- ) 10 BASE ! ;

\ ========================================================================
\ I N T E R P R E T E R

: INTERPRET    ( addr len -- )  'INTERPRET @ EXECUTE ;

\ ========================================================================
\ Q U I T :  The  O U T E R   I N T E R P R E T E R

: QUIT         ( -- )
               L0 LP !
               RP0 RP!
               SOURCE-ID OFF
               VDPTOP ^PAB !   \ set base pab pointer
               t[COMPILE] [
               BEGIN
                  TIB DUP TIB# ACCEPT SPACE
                ( addr len) INTERPRET
                  STATE @ 0= IF  T."  ok" CR THEN
               AGAIN ;

: EVALUATE     ( c-addr u -- j*x)
               SOURCE-ID ON
               SOURCE 2>R
               >IN @ >R
               INTERPRET
               R> >IN !
               2R> 'SOURCE 2!
               SOURCE-ID OFF ;

\ ========================================================================
\ E R R O R   H A N D L I N G
\
: ABORT       ( -- )  SP0 SP!  CR QUIT ;

: ?ABORT  ( f c-addr u --)
           ROT IF  HONK
                   CR CR T." ? "  TYPE
                   SOURCE-ID @   ( if source is NOT console)
                   IF  T."  Line " LINES @ U.
                       CR CR SOURCE TYPE
                   THEN ABORT
           THEN 2DROP ;

: ?FIND       ( ? -- )       0=    HERE COUNT ?ABORT ;
: ?PAIRS      ( n1 n2 --)     -    TS" Unpaired"       ?ABORT ;
: ?COMP       ( -- ) STATE @ 0=    TS" Compile only"   ?ABORT ;
: ?EXEC       ( -- ) STATE @       TS" Interpret only" ?ABORT ;
: ?CSP        ( -- ) SP@ CSP @ -   TS" Unfinished"     ?ABORT ;
: ?STACK      ( -- ) SP0 2- SP@ U< TS" Empty stack"    ?ABORT ;
: !CSP        ( -- ) SP@ CSP ! ;

\ ========================================================================
\ S T R I N G   L I T E R A L
\ Non-standard: when interpreting S" puts the string in PAD

: S"          ( cccc" -- )
              T[CHAR] " PARSE
              STATE @
              IF  COMPILE (S")  S,
              ELSE PAD PLACE PAD COUNT
              THEN ; XIMMEDIATE

: ABORT"      ( i*x 0  -- i*x)    \ R: j*x -- j*x  x1=0
              ?COMP
             T[COMPILE] S"
              COMPILE ?ABORT ; XIMMEDIATE

[cc] cr .( FIND )
\ ========================================================================
\ D I C T I O N A R Y   S E A R C H

TARGET-COMPILING
: FIND  ( caddr --  caddr  0  if not found)
\                    xt  1  if immediate,
\                    xt -1  if "normal"
                    LATEST @  (FIND) ;

: '        ( -- xt) BL WORD FIND ?FIND ;

: [']      ( -- <name> ) ?COMP  '  T[COMPILE] LITERAL ; XIMMEDIATE

: POSTPONE ( <name> -- )      \ replaces COMPILE and [COMPILE]
          ?COMP
          BL WORD FIND DUP ?FIND
          0< IF   COMPILE COMPILE
             THEN  COMPILE, ; XIMMEDIATE

\ ========================================================================
\ T E X T   O U T P U T

: ."    (  ccc" -- )
        t[COMPILE] S"                ( -- str len)
        STATE @ IF   COMPILE TYPE
                ELSE TYPE
                THEN ; XIMMEDIATE

: .(     T[CHAR] ) PARSE TYPE ;

[CC] cr .( Interpreter/compiler loop)
\ ========================================================================
\ I N T E R P R E T E R  /  C O M P I L E R

TARGET-COMPILING
: <INTERPRET>  ( i*x c-addr u -- j*x )
               'SOURCE 2!  >IN OFF
               BEGIN
                  BL WORD DUP C@ ( -- addr len)
               WHILE
                  FIND
                  ?DUP IF ( it's a word)
                       1+ STATE @ 0= OR
                       IF   EXECUTE
                       ELSE COMPILE,
                       THEN

                  ELSE ( it's a number)
                       ?NUMBER
                       IF  t[COMPILE] LITERAL
                       ELSE TRUE SWAP COUNT ?ABORT
                       THEN
                  THEN
                  ?STACK
               REPEAT
               DROP ;

\ ======================================================================
\ T I - 9 9   T E X T   M O D E   C O N T R O L
TARGET-COMPILING

: TEXT      ( -- )
             F0 DUP 83D4 C!
       ( -- F0) 01 VWTR
             20  7 VWTR
             28 C/L!
             VTOP OFF
             VROW OFF
             VCOL OFF
             2 VMODE !
             PAGE ;

\ ========================================================================
\ D I C T I O N A R Y   C R E A T I O N

: HEADER, ( addr len --)
            ALIGN
            LATEST @ ,
            0 C,
            HERE LATEST !
            S, ;

: HEADER   BL PARSE-WORD HEADER, ;

\ ========================================================================
\ T A R G E T   S Y S T E M   D E F I N I N G   W O R D S

\                    text    runtime-action   parameter
\ -------------------------  --------------- -----------
: CONSTANT  ( n --)  HEADER  COMPILE DOCON     COMPILE, ;
: USER      ( n --)  HEADER  COMPILE DOUSER    COMPILE, ;
: CREATE    ( -- )   HEADER  COMPILE DOVAR              ;
: VARIABLE  ( -- )   CREATE                  0 COMPILE, ;

\ (:noname) came from studying gforth. It's a nice factor.
\ had to use the literal address of ENTR ($839E) to make this work.
: (:NONAME) ( -- )  839E COMPILE,  HIDE  ]  ;

\ =======================================================================
\ D O E S   S U P P O R T
: (;CODE)
         R>
        LATEST @ NFA>CFA
         !  ;

: DOES>  ( -- )
        COMPILE (;CODE)
        0460 , T['] DODOES ,  \ compile machine code:  B @DODOES
       ; XIMMEDIATE

\ =======================================================================
\ TI-99 F I L E   S Y S T E M   I N T E R F A C E

 [CC] include CC9900\cclib\dsrlinkA.hsf
 [CC] include CC9900\cclib\filesysX.hsf

\ =======================================================================
\ LOOPS AND BRANCH COMPILERS FOR THE TI-99 SYSTEM
 [CC] CR .( TARGET Forth BRANCHING and LOOPING ...)

 [CC]  include cc9900\cclib\targloop.hsf

\ =======================================================================
\ INIT: Set Workspace, copy code to scratch pad, set stacks, run BOOT

CROSS-ASSEMBLING

CODE: INIT
              WRKSP0 LWPI,
              R0 HSprims LI,   \ source
              R1 HSstart LI,   \ destination
              BEGIN,
               *R0+ *R1+ MOV,
                R1 HSend CMPI,
              EQ UNTIL,

              SP  SP0  LI,
              RP  RP0  LI,
              R10 NEXT2 LI,
              IP  BOOT  LI,
             *R10 B,
              END-CODE

[CC] HEX
\ ======================================================================
\ B O O T   U P   C O D E
TARGET-COMPILING
: COLD       ( -- )
              80 83C2 C!   \ ISR disable flags:
              ORGDP @ DP !
              ORGLAST @ LATEST !
              26 TPAD !
              2000 H !                       \ reset the heap
              TMR!                           \ 9901 timer runs continuously
              2 KUNIT# C!                    \ use BASIC keyboard
              T['] <INTERPRET> 'INTERPRET !  \ set the interpreter vector
              HEX                            \ default to hex
\ VDP start screen
              TEXT BEEP
              TS" CAMEL99 Forth" TYPE
              VDPTOP ^PAB !
              TS" DSK1.START" INCLUDED
              ABORT ;

\ ======================================================================
\ define target comment words
TARGET-COMPILING
: (         T[CHAR] ) PARSE 2DROP ; XIMMEDIATE
: \                 1 PARSE 2DROP ; XIMMEDIATE

[CC]
\ ======================================================================
\ TARGET Colon, :NONAME and Semi-colon  defintions
\ X: ;X are aliases for the cross-compiler : and ;

TARGET-COMPILING
 X: :         !CSP  HEADER (:NONAME)  ;X

 X: :NONAME   HERE  !CSP   (:NONAME)  ;X

 X: ;        [  REVEAL COMPILE EXIT ?CSP ;X  XIMMEDIATE

[CC]
\           F O R T H   S Y S T E M   C O D E   E N D S
\ /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
cr .( Forth Kernel compiled completely")
            END.   ( report compile time and stats)

\ ======================================================================
\  P A T C H   T H E   T A R G E T  S Y S T E M   V A R I A B L E S

[CC]   XLATEST @ DUP LATEST T!
                    ORGLAST T!
               THERE DUP DP T!
                      ORGDP T!

\ ======================================================================
\ P A T C H   T A R G E T   I M A G E  F I L E   H E A D E R

         FILENAME: CAMEL99
         T' INIT >BODY BOOT-ADDRESS T!

\ S E T   T H E   B O O T   W O R D   T O   R U N

         T' COLD       BOOT T!

\ ======================================================================
\ S A V E   B I N A R Y  I M A G E   F I L E

         FILENAME$ $SAVE-EA5.     \ FILENAME$ was set by FILENAME:

\ ======================================================================
\  C O P Y   T O   T I - 9 9   V I R T U A L   D I S K
.( copying binary file to TI-99 Emulator DSK1.)

( //  shells out to the DOS shell in HSF2012)

      // copy CAMEL99 cc9900\clssic99\dsk1\

CROSS-COMPILING

 CR ." === COMPILE ENDED PROPERLY ==="



 BYE  ( return to DOS)
