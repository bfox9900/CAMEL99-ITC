\ simple locals for camel99 forth bjf 2018

\ The 8K space in low memory is a HEAP memory in CAMEL99
\ We can create a very simple set of locals by using pre-named values
\ Add a few simple words to allocate and un-allocate memory and it's done.

NEEDS VALUE FROM DSK1.VALUES

0 VALUE L1
0 VALUE L2
0 VALUE L3
0 VALUE L4

VARIABLE LOCALMEM   \ holds how much memory we allocated

: LOCAL ( n -- addr ) DUP LOCALMEM +! MALLOC ;


: RELEASE   LOCALMEM @ MFREE ;