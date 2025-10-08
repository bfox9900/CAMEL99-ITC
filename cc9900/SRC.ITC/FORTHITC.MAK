\ MAKE CAMEL99 ITC Forth                            Mar 2022 Brian Fox
\ *** NOT A "MAKE" FILE  This is just more Forth

\ **********************************************************************
\      compiler switches to control the system build
\ **********************************************************************
CROSS-COMPILING
TRUE  VALUE ITC          \ used to prevent directly compiling HILEVEL.HSF
FALSE VALUE SLOWER       \ TRUE saves 64 bytes, FALSE -> 14% FASTER compile times
FALSE VALUE FAST_TYPE    \ 22% faster SCREEN I/O
FALSE VALUE HASHING      \ Not working yet

\ ======================================================================
\              *** CONSOLE I/O SELECTION ***

TRUE       VALUE VDPI/O        \ select VDP chip console driver
 VDPI/O 0= VALUE TTYI/O        \ selects 9902 RS232 console driver


\ ======================================================================
\            ***   TIB AND STACK LOCATIONS ***
CROSS-COMPILING
HEX
        FFFC    EQU EMEM     \ EMEM = "end of memory"
        0050    EQU TIBSIZE  \ 80 bytes is the longest file string
EMEM TIBSIZE -  EQU 'TIB     \ Terminal input buffer just below

     'TIB  2 -  EQU 'SP0     \ FORTH DATA stack base address
     'SP0 6E -  EQU 'RP0     \ FORTH RETURN stack base address

\ big stack version
\     3FFE       EQU 'SP0    \ FORTH DATA stack base address
\     FE80       EQU 'RP0    \ FORTH RETURN stack base address

\ ======================================================================
-1    \ true= standard kernel ;  false=non-standard kernel
[IF]
    A000 VALUE CODESEG
    2000 VALUE HEAPSEG
  \  FALSE TO FAST_TYPE   \ save 52 bytes
[ELSE]
		6000 VALUE CODESEG   \ 6000 is the supercart RAM
		2000 VALUE HEAPSEG   \ initial HEAP address when kernel boots
 \   TRUE TO FAST_TYPE   \ we have space in Supercart but it is not reliable
[THEN]

\ *******************************************************************
\ Cross-compiler extensions and threading mechanism words

 [cc] include cc9900\src.itc\itctypes.hsf
 [cc] include cc9900\src.itc\metadefs.hsf

\ *******************************************************************
\ Make Forth kernel

 [cc] include cc9900\src.itc\9900CODN.HSF  \ asm primitives. M version has move

 TTYI/O
 [IF]   [cc] include cc9900\src.itc\VDPCHIP.HSF \ small VDP lib for file i/o
 [ELSE] [cc] include cc9900\src.itc\ti99ioY.hsf \ ALL vdp primitives & key
 [THEN]

 [cc] include cc9900\src.itc\bootstrx.hsf  \ cross-compiler loops & branch
 [cc] include cc9900\src.itc\ticktock.hsf  \ 9901 hardware timer

 [cc] include cc9900\src.itc\hilevel.hsf   \ core forth words

\ ======================================================================
\  P A T C H   T H E   T A R G E T  S Y S T E M   V A R I A B L E S

\
\                             *IMPORTANT*
\ Use [CC] and [TC] to explicately select compiler or target variables
\

[CC] XLATEST @ DUP   [TC] LATEST T!  ORGLAST T!

[CC] CODESEG A000 <>
[IF]    [CC] HEX A004 DUP
[ELSE]  [CC] THERE 2+ DUP
[THEN] 	[TC] DP T!  ORGDP T!


[CC]
\ === set the first Forth word that runs in BOOT variable ===
	T' LOADSYS  BOOT T!

\ =============================================================
\ P A T C H   T A R G E T   I M A G E  F I L E   H E A D E R

\ COLD create the Forth VM and loads R10 with NEXT
 T' COLD >BODY BOOT-ADDRESS T!

CROSS-COMPILING HEX
VDPI/O
[IF]
  CODESEG A000 = [IF]  FILENAME: CAMEL99 [THEN]
  CODESEG 6000 = [IF]  FILENAME: CAML99SC [THEN]
  CODESEG 2000 = [IF]  FILENAME: CAML99LR [THEN]
[THEN]

CROSS-COMPILING HEX
TTYI/O
[IF]
  CODESEG A000 = [IF]  FILENAME: CAMELTTY [THEN]
  CODESEG 6000 = [IF]  FILENAME: CMLTTYSC [THEN]
  CODESEG 2000 = [IF]  FILENAME: CMLTTYLR [THEN]
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

 \ BYE  ( un-comment this line to return to DOS after compilation)
