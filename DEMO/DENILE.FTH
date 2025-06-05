\ LITERAL TRANSLATION OF DENILE.BAS using variables and strings
\ Orignal program by RETROSPECT, Atariage.com

NEEDS CLEAR   FROM DSK1.GRAFIX
NEEDS DIM     FROM DSK1.STRINGS
NEEDS CHARSET FROM DSK1.CHARSET

\ 60 DATA 010207091F247F92,8040E090F824FE49,FF92FF24FF92FF49,
\         AA55448920024801,000217357CFC44AA,0008081C2A081414

\ *different than BASIC* Named character DATA patterns
HEX
CREATE RSLOPE     0102 , 0709 , 1F24 , 7F92 ,
CREATE LSLOPE     8040 , E090 , F824 , FE49 ,
CREATE STONE      FF92 , FF24 , FF92 , FF49 ,
CREATE SAND       AA55 , 4489 , 2002 , 4801 ,
CREATE Camel      0002 , 1735 , 7CFC , 44AA ,
CREATE LittleMan  0008 , 081C , 2A08 , 1414 ,


DECIMAL
: CHANGE-CHARS ( -- )
\ CHARDEF takes a defined pattern and the ascii number
                             \ 20 FOR L=65 TO 70
      ( not needed )         \ 30 READ Q$
       RSLOPE     65 CHARDEF \ 40 CALL CHAR(L,Q$)
       LSLOPE     66 CHARDEF \ ...
       STONE      67 CHARDEF \ ...
       SAND       68 CHARDEF \ ...
       Camel      69 CHARDEF \ ...
       LittleMan  70 CHARDEF \ ....
                             \ 50 NEXT L

S" 0083C7AEFBEFBDF7" 104 CALLCHAR  \ 70 CALL CHAR(104,"0083C7AEFBEFBDF7")
S" 00078F5DF7DF7BEF" 105 CALLCHAR  \ 80 CALL CHAR(105,"00078F5DF7DF7BEF")
S" 000E1FBAEFBFF6DF" 106 CALLCHAR  \ 90 CALL CHAR(106,"000E1FBAEFBFF6DF")
S" 000E1FBAEFBFF6DF" 107 CALLCHAR  \ 100 CALL CHAR(107,"000E1FBAEFBFF6DF")
S" 00387CEABFFEDB7F" 108 CALLCHAR  \ 110 CALL CHAR(108,"00387CEABFFEDB7F")
S" 0070F8D57FFDB7FE" 109 CALLCHAR  \ 120 CALL CHAR(109,"0070F8D57FFDB7FE")
S" 0070F8D57FFDB7FE" 110 CALLCHAR  \ 130 CALL CHAR(110,"0070F8D57FFDB7FE")
S" 00C1E357FDF7DEFB" 111 CALLCHAR  \ 140 CALL CHAR(111,"00C1E357FDF7DEFB")
;

\ ALL variables must be defined first
VARIABLE X
VARIABLE C
VARIABLE T
VARIABLE Y

32 DIM A$    \ Not standard Forth. Language extension
32 DIM B$    \ BTW Strings can have any name. Imagine that...
32 DIM C$

: TAB ( n -- ) 0 ?DO SPACE LOOP ; \ we don't have a TAB word so make one

: PYRAMID
   A$ =""  B$ =""  C$ =""      \ clear these strings
  14 X !                       \ 160 X=13
   1 C !                       \ 170 C=1
   CR X @ 1+ TAB ." AB"        \ 180 PRINT TAB(X+1);"AB"
 BEGIN                         \ " needs a space, '&' is RPN :)
      C$ " CC" &       C$ PUT  \ 190 C$=C$&"CC"
     " A" C$ &  " B" & B$ PUT  \ 200 B$="A"&C$&"B"
      CR   X @ TAB  B$ PRINT$  \ 210 PRINT TAB(X);B$
      COLLAPSE
      1 C +!                   \ 220 C=C+1
     -1 X +!                   \ 230 X=X-1
      C @ 14 =                 \ 240 IF C=13 THEN 250 ELSE 190
 UNTIL
    0 23 68 32 HCHAR           \ 250 CALL HCHAR(24,1,68,32)
    0 22 69 1  HCHAR           \ 260 CALL HCHAR(23,1,69)
    1 22 70 1  HCHAR           \ 270 CALL HCHAR(23,2,70)
    CR                         \ 280 PRINT
    CR                         \ 290 PRINT
    CR                         \ 295 PRINT
    0 23 68 32 HCHAR           \ 296 CALL HCHAR(24,1,68,32)
;

: RIVER    \ flow the river loop
    104 T !                    \ 300 T=104
    106 Y !                    \ 310 Y=106
 BEGIN
    1 T +!                     \ 320 T=T+1
    T @ 111 >                  \ 330 IF T>111
    IF                         \ THEN 340 ELSE 350
        104 T !                \ 340 T=104
    THEN 2 Y +!                \ 350 Y=Y+2
    Y @ 111 >                  \ 360 IF Y>111 THEN 370 ELSE 380
    IF  104 Y ! THEN           \ 370 Y=104
    0 21 T @ 32 HCHAR          \ 380 CALL HCHAR(22,1,T,32)
    0 22 Y @ 32 HCHAR          \ 390 CALL HCHAR(23,1,Y,32)
    100 MS
    ?TERMINAL                  \ check for BREAK key
 UNTIL                         \ 400 GOTO 320
;

: RUN   \ Forth doesn't have RUN so we make one
   CLEAR                  \ 10 CALL CLEAR
   4 SCREEN               \ BASIC does when running.
   CHANGE-CHARS           \ line 20 to 140
   13 6 5 COLOR           \ 150 CALL COLOR[10,6,5]
                          \ Forth has different character sets numbers

   PYRAMID                \ 500 GOSUB PYRAMID
   RIVER                  \ 600 GOSUB RIVER

   8 SCREEN               \ BASIC does this automatically
   CHARSET                \ Forth must be told.
;

CR .( Type RUN to start. FCTN BREAK to stop)
