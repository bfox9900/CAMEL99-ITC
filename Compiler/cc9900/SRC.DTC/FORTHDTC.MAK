CR .( MAKE CAMEL99 DTC Forth  May 1, 2022  Brian Fox)

CROSS-COMPILING
\ ======================================================================
\ compiler switches control HOW the system will be built
TRUE  VALUE DTC          \ used to prevent directly compiling HILEVEL.HSF
FALSE VALUE SLOWER       \ TRUE saves space
FALSE VALUE HASHING      \ Not working yet
FALSE VALUE NEXT-INLINE

\ ======================================================================
\ TIB and Stack locations

CROSS-COMPILING
HEX
        FFFC    EQU EMEM     \ EMEM = "end of memory"
        0050    EQU TIBSIZE
EMEM TIBSIZE -  EQU 'FIB    \ File Input Buffer
'FIB TIBSIZE -  EQU 'TIB    \ Terminal input buffer just below

     'TIB  4 -  EQU 'SP0    \ FORTH DATA stack base address
     'SP0 80 -  EQU 'RP0    \ FORTH RETURN stack base address

\ ======================================================================
\ Target memory location

0 \ true= standard kernel ;  false=non-standard kernel
[IF]
    A000 VALUE CODESEG
    2000 VALUE HEAPSEG
[ELSE]
		6000 VALUE CODESEG  \ the specific alternate load address to use
		2000 VALUE HEAPSEG  \ initial HEAP address when kernel boots
[THEN]

\ ======================================================================
\ Cross-compiler extensions, load threading mechanism words

 [cc] include cc9900\src.dtc\dtctypes.hsf
 [cc] include cc9900\src.oct\metadefs.hsf


 \ ======================================================================
\ Make Forth kernel

 [CC] INCLUDE CC9900\SRC.DTC\9900DTCx.HSF  \ Forth primitives
 [CC] INCLUDE CC9900\SRC.DTC\BOOTSTRX.HSF  \ cross-compiler looping & branching
 [CC] include cc9900\SRC.DTC\ticktock.hsf  \ 9901 hardware timer
 [CC] INCLUDE CC9900\SRC.DTC\TI99IOX.HSF   \ VDP primitives & KEY
 [CC] INCLUDE CC9900\SRC.DTC\HILVLDTC.HSF  \ CORE Forth words

 \ ======================================================================
 \ PATCH TARGET VARIABLE, Set output filename

\ ************************************************************
\ * YOU MUST SELECT TARGET VARIABLES WITH THE [TC] DIRECTIVE *
\ ************************************************************

 [CC]
 CODESEG 6000 =
 [IF]
       [CC] XLATEST @ DUP
			 [TC] LATEST T!  ORGLAST T!
       THERE  DP T!
			 A000 ORGDP T!
			 FILENAME: CAM99DSC

 [ELSE]
      [CC] XLATEST @ DUP
			[TC] LATEST T! ORGLAST T!
      [CC]  THERE 2+ DUP
			[TC] DP T!	ORGDP T!
			 FILENAME: CAM99DTC

 [THEN]

 [CC]

 \ ======================================================================
 \ Set boot address  and  BOOT word
T' COLD BOOT-ADDRESS T!
T' LOADSYS  BOOT T!

         END. ( updates file header,  report compile time and stats)

 \ ======================================================================
 \ S A V E   B I N A R Y  I M A G E   F I L E

  FILENAME$ $SAVE-EA5.     ( FILENAME$ was set by FILENAME: )

 \ ======================================================================
 \  C O P Y   T O   T I - 9 9   V I R T U A L   D I S K
 .( copying binary file to TI-99 Emulator DSK1.)

 \ build the copy command in host Forth PAD memory by appending strings
 S" COPY " PAD PLACE
 FILENAME$ COUNT PAD +PLACE
 S"  cc9900\CAMEL99.WIP\dsk1.dtc\" PAD +PLACE

CR PAD COUNT 2DUP TYPE SYSTEM  \ SYSTEM calls DOS, gives it the string

CROSS-COMPILING
 HEX
 [CC] CR  [TC] DP T@  [CC] U.
 [CC] CR  [TC] CONTEXT T@ [CC] U.  [TC] CURRENT T@ [CC] U.
 [CC] CR  [TC] CONTEXT T@ T@ [CC] U.
 [CC] CR  [TC] LATEST [CC] U.      [TC] LATEST T@ [CC] U.
 [CC] CR  [TC] ORGLAST T@ [CC] U.  [TC] ORGDP T@  [CC] U.
 CR
 CR
  CR ." === COMPILE ENDED PROPERLY ==="
 QUIT

 \ BYE  ( un-comment this to return to DOS)
