\ ANS Dynamic Memory test

NEEDS VALUE FROM DSK1.VALUES
NEEDS ALLOCATE FROM DSK1. ALLOCATE

DECIMAL


128 ALLOCATE  VALUE A$
256 ALLOCATE  VALUE B$
  2 ALLOCATE  VALUE X  ( allocate an integer in HEAP )

S" This string is called A$" A$ PLACE
S" This is a much bigger string that has a different name." B$ PLACE

HEX 99A4 X !


\ DEMO CODE
HEX 2000 H !   \ reset heap pointer to the where you want the heap

DECIMAL
0 VALUE A$  ( create a null pointer )
0 VALUE B$

 80 ALLOCATE -> A$
 40 ALLOCATE -> B$
 A$ SIZE .
 B$ SIZE .

 S" This is string A$" A$ PLACE
 S" B$ is my name" B$ PLACE
 CR A$ COUNT TYPE
 CR B$ COUNT TYPE
