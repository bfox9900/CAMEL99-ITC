\ MAKE CAMEL99 DTC Forth                            Jan 2022 B Fox

CROSS-COMPILING
\ **********************************************************************
\ compiler switches control HOW the system will be built
\ **********************************************************************
TRUE  VALUE ITC          \ used to prevent directly compiling HILEVEL.HSF
FALSE VALUE SLOWER       \ TRUE saves 28 bytes
FALSE VALUE HASHING      \ Not working yet

TRUE      \ true= standard kernel ;  false=non-standard kernel
[IF]
      A000 VALUE KERNORG
      2000 VALUE HEAPORG
[ELSE]
		  2000 VALUE KERNORG  \ the specific alternate load address to use
			0000 VALUE HEAPORG  \ initial HEAP address when kernel boots
[THEN]


\ *******************************************************************
\ thread mechanism control

 INCLUDE CC9900\SRC.DTC\DTCTYPES.HSF   \ CROSS-Compiler Extensions


\ *******************************************************************
\ Make Forth kernel
 INCLUDE CC9900\SRC.DTC\9900DTBL.HSF  \ ASM primitives for TMS9900
 INCLUDE CC9900\SRC.DTC\BSTRAPDT.HSF  \ cross-compiler looping & branching
 INCLUDE CC9900\SRC.ITC\TI99IOX.HSF   \ VDP primitives & KEY
 INCLUDE CC9900\SRC.DTC\HILEVEL.HSF   \ CORE Forth words
