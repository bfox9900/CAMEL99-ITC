
\ CELLS ANS Forth Core wordset
\ implemented as macros to use the speed of ASM words when compiled
: CELLS ( n -- n') S" 2*" EVALUATE ; IMMEDIATE
: CELL+ ( n -- n') S" 2+" EVALUATE ; IMMEDIATE

: CHAR+ ( n -- n') S" 1+" EVALUATE ; IMMEDIATE

