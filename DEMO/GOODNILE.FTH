\ FORTH STYLE TRANSLATION OF DENILE.BAS
\ Orignal program by RETROSPECT, Atariage.com
 
NEEDS HCHAR FROM DSK1.GRAFIX
NEEDS CHARSET FROM DSK1.CHARSET
\ DSK1.STRINGS \ We don't strings for this version.

\ CREATE  named character DATA patterns with numbers not strings
HEX
CREATE RSLOPE     0102 , 0709 , 1F24 , 7F92 ,
CREATE LSLOPE     8040 , E090 , F824 , FE49 ,
CREATE STONE      FF92 , FF24 , FF92 , FF49 ,
CREATE GRASS      AA55 , 4489 , 2002 , 4801 ,
CREATE Camel      0002 , 1735 , 7CFC , 44AA ,
CREATE LittleMan  0008 , 081C , 2A08 , 1414 ,
CREATE WAVES1     0083 , C7AE , FBEF , BDF7 ,
CREATE WAVES2     0007 , 8F5D , F7DF , 7BEF ,
CREATE WAVES3     000E , 1FBA , EFBF , F6DF ,
CREATE WAVES4     001C , 3E75 , DF7F , EDBF ,
CREATE WAVES5     0038 , 7CEA , BFFE , DB7F ,
CREATE WAVES6     0070 , F8D5 , 7FFD , B7FE ,
CREATE WAVES7     00E0 , F1AB , FEFB , 6FFD ,
CREATE WAVES8     00C1 , E357 , FDF7 , DEFB ,


DECIMAL
: CHANGE-CHARS ( -- )
\ CHARDEF takes a defined pattern and the ascii number
\ We didn't have to but we used the word [CHAR] to make the code read easier.
\ [CHAR] is used in compiling. It is an IMMEDIATE WORD
\ It PARSES a Character from the input and returns the
\ ASCII number of the character.
       RSLOPE    [CHAR] A CHARDEF
       LSLOPE    [CHAR] B CHARDEF
       STONE     [CHAR] D CHARDEF
       Camel     [CHAR] E CHARDEF
       LittleMan [CHAR] F CHARDEF
       WAVES1    [CHAR] h CHARDEF   \ CHAR 104
       WAVES2    [CHAR] i CHARDEF
       WAVES3    [CHAR] j CHARDEF
       WAVES4    [CHAR] k CHARDEF
       WAVES5    [CHAR] l CHARDEF
       WAVES6    [CHAR] m CHARDEF
       WAVES7    [CHAR] n CHARDEF
       WAVES8    [CHAR] o CHARDEF  \ CHAR 111
\ we will make the GRASS yellow and the sky blue.
:      GRASS     [CHAR] ~ CHARDEF ;

\ we don't have a TAB word so make one. 
\ Just move the VCOL variable ( VCOL is video column)
: TAB ( n -- ) VCOL +! ;

\ the original version of PYRAMID used string CONCATENATION
\ to combine the characters needed to draw each row of stones
\ with the correct slope on each end.
\ String concatentation is slow because it copies strings in memory.

\ In Forth we should make some new words to do the job for us.
: .LSLOPE ( -- ) [CHAR] A EMIT ;  \ print 1 left slope brick
: .RSLOPE ( -- ) [CHAR] B EMIT ;  \ print 1 right slope brick
: .BRICK  ( -- ) [CHAR] D EMIT ;  \ print 1 BRICK

\ print n*2 BRICKs. If n=0 ?DO will do nothing.
\ we mulitply n by 2 to create the pyramid rows
: BRICKS  ( n -- ) 2* 0 ?DO  .BRICK  LOOP  ;

: .GRASS  ( -- )  0 23 [CHAR] ~ 32 HCHAR ;

: PYRAMID ( -- )
          12 0                          \ The pyramid is 12 rows deep
          DO
            CR 15 I - TAB               \ newline & tab to centre of screen
              .LSLOPE I BRICKS .RSLOPE  \ print line of BRICKs
          LOOP
         CR .GRASS
         CR
         CR
         CR .GRASS ;

: .MAN   ( -- )  1 19 [CHAR] F 1  HCHAR ;
: .CAMEL ( -- )  0 19 [CHAR] E 1  HCHAR ;
\
\ This is an example of Forth Style.
\ Factor out the common LIMITER routine so you can use it twice.
\
: LIMITER   ( n -- n')
             DUP 111 >    \ is n greater than ascii 111
             IF           \ if true...
                DROP 104  \ drop the no. and replace with 104
             THEN ;       \ then continue. In this case do return

\ Forth Style:
\ Create custom variable incrementers, that limit themselves!
\
: 1+@   ( variable -- n ) \ INCR variable, limit to 104..111, return value
             DUP @ 1+ LIMITER DUP ROT !  ;

: 2+@   ( variable -- n ) \ INCR variable by 2, limit to 104..111
             DUP @ 2+ LIMITER DUP ROT !  ;

\ These variables keep track of the wave characters
\ We could do this on the stack but it would be harder to understand
VARIABLE T
VARIABLE Y

: INIT-WAVES ( -- )
           103  T !  104 Y !  ;

\ everytime this word runs the variables auto-increment from 104 to 111
: .WAVES   ( -- )
           0 21  T 1+@  32 HCHAR
           0 22  Y 2+@  32 HCHAR ;

\ Now the water flow loop is so simple
: FLOW     ( -- )
           INIT-WAVES
           BEGIN
             .WAVES
             100 MS                   \ slow things down a bit
             ?TERMINAL                \ check for BREAK key
           UNTIL ;                    \ GOTO BEGIN :)

: RUN     ( -- )
          CLEAR
          12 SCREEN
          CHANGE-CHARS
         [CHAR] h SET#  6 5 COLOR  \ the river is blue
         [CHAR] ~ SET# 13 4 COLOR  \ grass by the river is green
          PYRAMID .CAMEL .MAN
          FLOW
          8 SCREEN              \ this resets the screen like BASIC
          4 19 2 1 COLORS       \ reset printable character's colors
          CHARSET              \ reset character patterns
          TRUE ABORT" BREAK" ;

CR .( Type RUN to start. FCTN BREAK to stop)


