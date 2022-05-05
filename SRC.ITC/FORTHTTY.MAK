\ MAKE CAMEL99 ITC Forth                            Mar 2022 B Fox

CROSS-COMPILING
\ **********************************************************************
\ compiler switches control HOW the system will be built
\ **********************************************************************
TRUE  VALUE ITC          \ used to prevent directly compiling HILEVEL.HSF
FALSE VALUE SLOWER       \ TRUE saves 28 bytes
FALSE VALUE HASHING      \ Not working yet

TRUE \ true= standard kernel ;  false=non-standard kernel
[IF]
    A000 VALUE KERNORG
    2000 VALUE HEAPORG
[ELSE]
		6000 VALUE KERNORG  \ the specific alternate load address to use
		2000 VALUE HEAPORG  \ initial HEAP address when kernel boots
[THEN]

\ *******************************************************************
\ Cross-compiler extensions, load threading mechanism words

 [CC] INCLUDE CC9900\SRC.ITC\ITCTYPES.HSF   \ CROSS-Compiler Extensions


\ *******************************************************************
\ Make Forth kernel
 [CC] INCLUDE CC9900\SRC.ITC\9900CODE.HSF  \ ASM primitives for TMS9900

 [CC] INCLUDE CC9900\SRC.ITC\BOOTSTRX.HSF  \ cross-compiler looping & branching

 [CC] INCLUDE CC9900\SRC.ITC\TI99IOSM.HSF   \ VDP primitives & KEY
 [CC] INCLUDE CC9900\SRC.TTY\9902SHAK.HSF   \ TI99 RS232 I/O  lib

 [CC] INCLUDE CC9900\SRC.ITC\HILVLTTY.HSF   \ CORE Forth words

 \ ======================================================================
 \  P A T C H   T H E   T A R G E T  S Y S T E M   V A R I A B L E S
 [CC]

 XLATEST @ DUP LATEST T! ORGLAST T! ( align TARGET dictionary to compiler)

 T' WARM  BOOT T!  ( set the boot word to run )

 KERNORG A000 <>
  [IF]
    THERE DP T!
    HEX A000 ORGDP T!   ( SUPERCART must start dictionary in HI RAM )
  [ELSE]
     THERE 2+ DUP DP T!  ORGDP T!
  [THEN]

 \ ======================================================================
 \ P A T C H   T A R G E T   I M A G E  F I L E   H E A D E R

 T' COLD >BODY BOOT-ADDRESS T!

 [CC] KERNORG A000 <>
 [IF]
      FILENAME: CMLTTYSC
 [ELSE]
      FILENAME: CAMELTTY
 [THEN]
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

 \ BYE  ( un-comment this to return to DOS)
