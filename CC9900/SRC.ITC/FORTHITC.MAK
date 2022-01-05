\ MAKE CAMEL99 indirect threaded Forth               Jan 2022 B Fox

CROSS-COMPILING

\ compiler switches
TRUE  VALUE ITC          \ used to prevent directly compiling HILEVEL.HSF
FALSE VALUE SLOWER       \ TRUE saves 22 bytes
FALSE VALUE HASHING
TRUE VALUE SUPERCART

 INCLUDE CC9900\SRC.ITC\ITCTYPES.HSF   \ CROSS-Compiler Extensions

\ compile the Forth kernel
 INCLUDE CC9900\SRC.ITC\9900CODE.HSF   \ ASM primitives for TMS9900
 INCLUDE CC9900\SRC.ITC\TI99IOX.HSF    \ VDP driver & KEY code

 INCLUDE CC9900\SRC.ITC\BOOTSTRP.HSF   \ cross-compiler looping & branching

 INCLUDE CC9900\SRC.ITC\HILEVEL.HSF   \ CORE Forth words
