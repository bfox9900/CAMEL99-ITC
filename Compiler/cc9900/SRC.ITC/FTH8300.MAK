\ MAKE CAMEL99 ITC Forth                            Mar 2022 Brian Fox

\ **********************************************************************
\      compiler switches control HOW the system will be built
\ **********************************************************************
CROSS-COMPILING
TRUE  VALUE ITC          \ used to prevent directly compiling HILEVEL.HSF
FALSE VALUE SLOWER       \ TRUE saves 28 bytes, FALSE ->14% FASTER compile times
FALSE VALUE HASHING      \ Not working yet

TRUE  VALUE VDPI/O       \ select VDP chip console driver 
FALSE VALUE TTYI/O       \ select 9902 RS232 console driver 

\ ======================================================================
\ TIB and Stack locations

CROSS-COMPILING
HEX
        FFFC    EQU EMEM     \ EMEM = "end of memory"
        0050    EQU TIBSIZE
EMEM TIBSIZE -  EQU 'TIB    \ Terminal input buffer just below

      83FE      EQU 'SP0    \ FORTH DATA stack base address
      83D6  	EQU 'RP0    \ FORTH RETURN stack base address


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
 [cc] include cc9900\src.oct\9900codm.hsf   \ asm primitives. M version has move
 [cc] include cc9900\src.oct\ti99iox.hsf    \ vdp primitives & key

 [cc] include cc9900\src.oct\bootstrx.hsf   \ cross-compiler loops & branch

 [cc] include cc9900\src.oct\ticktock.hsf   \ 9901 hardware timer
 [cc] include cc9900\src.oct\OLD\KERNEL.HSF  \ core forth words

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

	T' WARM  BOOT T!

[CC]
\ ======================================================================
\ P A T C H   T A R G E T   I M A G E  F I L E   H E A D E R

 T' COLD >BODY BOOT-ADDRESS T!

CROSS-COMPILING HEX
  CODESEG A000 = [IF]  FILENAME: KERNEL [THEN]
  CODESEG 6000 = [IF]  FILENAME: KERNSC [THEN]
  CODESEG 2000 = [IF]  FILENAME: KERNLR [THEN]

    END.       ( report compile time and stats)

 \ ======================================================================
 \ S A V E   B I N A R Y  I M A G E   F I L E

  FILENAME$ $SAVE-EA5.     ( FILENAME$ was set by FILENAME: )

 \ ======================================================================
 \  C O P Y   T O   T I - 9 9   V I R T U A L   D I S K
 .( copying binary file to TI-99 Emulator DSK1.)

 \ build the copy command in host Forth PAD memory by appending strings
 S" COPY " PAD PLACE
 FILENAME$ COUNT PAD +PLACE
 S"  cc9900\CAMEL99.WIP\dsk1.itc\" PAD +PLACE

 CR PAD COUNT 2DUP TYPE SYSTEM  \ SYSTEM calls DOS, gives it the string

 CROSS-COMPILING

  CR ." === COMPILE ENDED PROPERLY ==="
 QUIT

 \ BYE  ( un-comment this line to return to DOS after compilation)
