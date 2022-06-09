\ CELLS ANS Forth Core wordset
\ implemented as aliases for speed

\ 1 cell alias. *FOR CODE WORDS ONLY*
: ALIAS ( <newname>  <oldword> ) CODE ' >BODY  HERE 2- ! ;

ALIAS CELLS  2*
ALIAS CELL+  2+
ALIAS CHAR+  1+

