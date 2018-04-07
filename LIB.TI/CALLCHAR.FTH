\ CALLCHAR   training wheels for new Forth users

\ requires GRAFIX.F , STRINGS.F

MARKER REMOVE

\ Usage:  " F0F0F0F0F0F0F0F0" 65 CALLCHAR
: ?HEX    ( char -- ) DIGIT? 0= ABORT" Bad digit" ;

: /DIGIT  ( addr len -- n) OVER C@ ?HEX >R 1 /STRING R>  ;

: /BYTE    ( addr len -- n)
           /DIGIT 4 LSHIFT  >R
           /DIGIT
            R> OR ;

: TEST   
         BEGIN
            DUP 
         WHILE
           /BYTE 


: CALLCHAR ( add len  ascii -- )
           BASE @ >R
           HEX
           ]PDT
           -ROT  ( -  pdt adr len)  .S
           0
           ?DO   ( -- pdt adr) .S
              DUP I +  C@ ?HEX 4 LSHIFT
              DUP I 1+ C@ ?HEX OR .
\              2 PICK I +  VC!
           2 +LOOP
           2DROP 
           R> BASE ! ;