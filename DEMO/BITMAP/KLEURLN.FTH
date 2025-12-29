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

\ :START
\    RND 1 Z
\    RND 13 A
\    A=A+2
\    RND 200 X
\   COLOR A SET X
\    X TO X+X X+X
\ GOTO :START



NEEDS HLINE  FROM DSK1.GRAPHICS2 \ slower Forth code version
NEEDS RDN    FROM DSK1.RANDOM
