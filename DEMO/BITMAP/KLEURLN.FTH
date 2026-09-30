\ Can we do what is done in the GEE language with Forth?

\ REM *********************************
\ REM * GEE : KLEURLN  (kleurlijn)    *
\ REM * Bron : MSX Computer Magazine  *
\ REM *        NR.28                  *
\ REM * Auteur : D. Teeuw             *
\ REM * Vertaald : Ronald van Kleunen *
\ REM *          Buys Ballotstraat 27 *
\ REM *          4462 AM Goes         *
\ REM *     >>> REGIO ZEELAND <<<     *
\ REM *********************************

\ this program draws multiples of different lengths and colour on the same diagonal
\ Camel99 Graphics2 system needs to add pixel specific colour function

\ :START
\    RND 1 Z
\    RND 13 A
\    A=A+2
\    RND 200 X COLOR A SET X
\    X TO X+X X+X
\ GOTO :START

\ Camel99 Forth equivalent
NEEDS PLOT   FROM DSK1.GRAPHICS2 \ slower Forth code version
NEEDS RDN    FROM DSK1.RANDOM
NEEDS VALUE  FROM DSK1.VALUES

0 VALUE Z
0 VALUE A
0 VALUE X

DECIMAL
: START                 \ :START
    GRAPHICS2
    5 0 COLOR
BEGIN
    1 RND  TO Z         \    RND 1 Z
    13 RND TO A         \    RND 13 A
    2 +TO A             \    A=A+2
    200 RND  X  \    RND 200 X COLOR A SET X


    ?TERMINAL
UNTIL
    TEXT
;