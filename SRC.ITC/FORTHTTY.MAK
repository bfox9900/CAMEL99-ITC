\ MAKE CAMEL99 ITC Forth                            Mar 2022 B Fox

\ **********************************************************************
\      compiler switches control HOW the system will be built
\ **********************************************************************
CROSS-COMPILING
TRUE  VALUE ITC          \ used to prevent directly compiling HILEVEL.HSF
FALSE VALUE SLOWER       \ TRUE saves 28 bytes, FALSE ->14% FASTER compile times
FALSE VALUE HASHING      \ Not working yet

FALSE  VALUE VDPI/O       \ select VDP chip console driver 
TRUE   VALUE TTYI/O       \ select 9902 RS232 console driver 

\ ======================================================================
\ TIB and Stack locations

CROSS-COMPILING
HEX
        FFFC    EQU EMEM     \ EMEM = "end of memory"
        0052    EQU TIBSIZE
EMEM TIBSIZE -  EQU 'TIB    \ Terminal input buffer just below

     'TIB  2 -  EQU 'SP0    \ FORTH DATA stack base address
     'SP0 6E -  EQU 'RP0    \ FORTH RETURN stack base address

\ ======================================================================
\ Target memory location

TRUE  \ true= standard kernel ;  false=non-standard kernel
[IF]
     A000 VALUE CODESEG
     2000 VALUE HEAPSEG
[ELSE]
	6000 VALUE CODESEG  \ the specific alternate load address to use
	2000 VALUE HEAPSEG  \ initial HEAP address when kernel boots
[THEN]

\ *******************************************************************
\ Cross-compiler extensions and threading mechanism words

 [cc] include cc9900\src.oct\itctypes.hsf
 [cc] include cc9900\src.oct\metadefs.hsf

\ *******************************************************************
\ Make Forth kernel
 [CC] INCLUDE CC9900\SRC.OCT\9900CODM.HSF  \ ASM primitives for TMS9900
 [CC] INCLUDE CC9900\SRC.OCT\BOOTSTRX.HSF  \ cross-compiler looping & branching
 
 [CC] INCLUDE CC9900\SRC.OCT\TTY\TI99IOSM.HSF   \ VDP primitives & KEY
 
 [cc] include cc9900\src.oct\ticktock.hsf   \ 9901 hardware timer
 [CC] INCLUDE CC9900\SRC.OCT\HILVLTTY.HSF   \ CORE Forth words

 [CC]
 \ ======================================================================
 \  P A T C H   T H E   T A R G E T  S Y S T E M   V A R I A B L E S

\
\                             *IMPORTANT*
\ Use [CC] and [TC] to explicately select compiler or target variables
\

[CC] XLATEST @ DUP   [TC] LATEST T! ORGLAST T!

[CC] CODESEG A000 <>
[IF]    [CC] HEX A000 DUP
[ELSE]  [CC] THERE 2+ DUP
[THEN] 	[TC] DP T!  ORGDP T!

	T' LOADSYS  BOOT T!

 [CC]
 \ ======================================================================
 \ P A T C H   T A R G E T   I M A G E  F I L E   H E A D E R

 T' COLD >BODY BOOT-ADDRESS T!

 [CC] CODESEG A000 <>
 [IF]   FILENAME: CMLTTYSC
 [ELSE] FILENAME: CAMELTTY
 [THEN]
      END.       ( report compile time and stats)

 \ ======================================================================
 \ S A V E   B I N A R Y  I M A G E   F I L E

  FILENAME$ $SAVE-EA5.     ( FILENAME$ was set by FILENAME: )

 \ ======================================================================
 \  C O P Y   T O   T I - 9 9   V I R T U A L   D I S K
 .( copying binary file to TI-99 Emulator DSK1.)

 \ build the copy command in host Forth PAD memory by appending strings
 S" COPY " PAD PLACE  FILENAME$ COUNT PAD +PLACE  
 S"  cc9900\CAMEL99.WIP\dsk1.itc\" PAD +PLACE

 CR PAD COUNT 2DUP TYPE SYSTEM  \ SYSTEM calls DOS, gives it the string

 CROSS-COMPILING

 CR ." === COMPILE ENDED PROPERLY ==="
 QUIT

 \ BYE  ( un-comment this to return to DOS)
