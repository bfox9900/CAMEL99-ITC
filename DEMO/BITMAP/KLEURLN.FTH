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
\ Camel99 Graphics2 system needs to add pixel specific colour funtion

\ :START
\    RND 1 Z
\    RND 13 A
\    A=A+2
\    RND 200 X COLOR A SET X
\    X TO X+X X+X
\ GOTO :START


NEEDS PLOT   FROM DSK1.GRAPHICS2 \ slower Forth code version
NEEDS RDN    FROM DSK1.RANDOM

: START
    GRAPHICS2
    5 0 COLOR
    1 RND  13 RND 2+



    TEXT
;