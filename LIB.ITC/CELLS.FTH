\ CELLS ANS Forth Core wordset

\ 1 cell alias. *FOR CODE WORDS ONLY*
: ALIAS ( <newname>  <oldword> ) CODE '  2+   HERE 2- ! ;

ALIAS CELLS  2*
ALIAS CELL+  2+
ALIAS CHAR+  1+
ALIAS >BODY  2+
