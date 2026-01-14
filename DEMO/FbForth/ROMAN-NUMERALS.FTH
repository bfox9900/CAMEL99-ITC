\ Roman Numerals in Fig-Forth with early escape from IF 

: >=   ( n1 n2 -- 0/1 ) < 0= ;
: END    COMPILE ;S  [COMPILE] ENDIF ;  IMMEDIATE

: M1000
  BEGIN DUP 1000 >= WHILE ." M" 1000 - REPEAT
  DUP 900 >= IF ." CM" 900 -  END
  DUP 500 >= IF ." D"  500 -  END
  DUP 400 >= IF ." CD" 400 -  END ;

: C100
  BEGIN DUP 100 >= WHILE ." C" 100 - REPEAT
  DUP 90 >= IF ." XC" 90 - END
  DUP 50 >= IF ." L" 50 -  END
  DUP 40 >= IF ." XL" 40 - END ;

: X10
  BEGIN DUP 10 >= WHILE ." X" 10 - REPEAT
  DUP 9 = IF ." IX" 9 -  END
  DUP 5 >= IF ." V" 5 -  END
  DUP 4 = IF ." IV" 4 -  END ;

: I1
  BEGIN DUP 1 >= WHILE ." I" 1 - REPEAT DROP ;

: RN   ( n -- )   CR M1000 C100 X10 I1  CR ;
