\ CAMEL99 FORTH constants, user vars and variables

TARGET-COMPILING

   VARIABLE STATE

   STATE [CC] TO XSTATE

[CC] HEX
cr .( Constants and VARIABLEs...)

TARGET-COMPILING
\ ASM/Equate       Forth Name
\ -----------      ------------
 'TIB     CONSTANT TIB
 SP0      CONSTANT SP0
 RP0      CONSTANT RP0
 \ TIBSIZE  CONSTANT TIB#

\ Utility constants
        0 CONSTANT FALSE
       -1 CONSTANT TRUE
        0 CONSTANT 0
        1 CONSTANT 1
\        2 CONSTANT 2
       20 CONSTANT BL

\ ======================================================================
\ U S E R   V A R I A B L E S
\ CAMEL99 uses space after workspace for user vars.
[CC] HEX [TC]
\ *G User VARIABLEs begin at >8320 for the primary Forth task
\ ** User VARIABLE 0 .. 1F are workspace registers.

      20 USER TFLAG
      22 USER JOB
      24 USER DP
      26 USER HP
      28 USER CSP
      2A USER BASE
      2C USER >IN
      2E USER C/L
      30 USER OUT
      32 USER VROW
      34 USER VCOL
      36 USER 'KEY     \ for vectored char input
      38 USER 'EMIT    \ for vectored char output
      3A USER LP
      3C USER SOURCE-ID
      3E USER 'SOURCE
\      40 USER -------   \ used by 'SOURCE

      46 USER TPAD
\     7E USER VPG        \ declared in TI99 VDP driver code

\ TI-99 system memory locations
\  8374 CONSTANT KUNIT#  \ byte
\  837C CONSTANT GPLSTAT \ byte

\ initial vocabulary with 4 threads
HASHING [IF]

  4 CONSTANT #THREADS
  VARIABLE LATEST  [CC] 4 CELLS TALLOT  [TC]

[ELSE]
  VARIABLE LATEST

[THEN]

\ *G These system VARIABLEs control cold starting the system
VARIABLE ORGDP
VARIABLE ORGLAST
VARIABLE BOOT

[CC] DECIMAL [TC]
   0024 CONSTANT L/SCR

[CC] HEX [TC]
VARIABLE VMODE
VARIABLE L0  [CC] 4 CELLS TALLOT  [TC]
VARIABLE ^PAB
VARIABLE LINES
VARIABLE C/SCR
VARIABLE 'IV    \ *G interpretor vector. Hold address of <INTERPRET>
VARIABLE H
VARIABLE VP
VARIABLE CURS     [CC] 205F CURS T! [TC]  \ BLANK and '_' in one VARIABLE
VARIABLE VTOP
\ VARIABLE WID-LINK
