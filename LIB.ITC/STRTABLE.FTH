\ string table Concept from Rosetta Code  Date format problem.
\ with some sytax sugar added

: []  ( n addr -- addr(n)) SWAP CELLS + ; \ my name for this array calculator


: STR-TABLE:
\ compile time action
      CREATE ( n -- ) 0 ?DO , LOOP          \ compile n addresses into memory

\ runtime action
      DOES>  ( n -- str len )
             []                             \ calc table(n),
             @                              \ fetch string,
             COUNT ;                        \ convert to stack string


\ table is created in reverse order
 HERE ," December"
 HERE ," November"
 HERE ," October"
 HERE ," September"
 HERE ," August"
 HERE ," July"
 HERE ," June"
 HERE ," May"
 HERE ," April"
 HERE ," March"
 HERE ," February"
 HERE ," January"
12 STR-TABLE MONTHS
