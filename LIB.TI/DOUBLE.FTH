\ 8 The optional Double-Number word set

\    DABS
\    D.R
\    D=
\    DMAX
\    DMIN
\    D-
\    DNEGATE
\    D+
\    D2/
\    D2*
\    DU<
\    D0=
\    D0<
\    D.
\    D<
\    D>S
\    M+
\    M*/
\    2CONSTANT
\    2LITERAL
\    2ROT
\    2VALUE
\    2VARIABLE


: 2ROT   ( d d2 d3 - d2 d3 d) 2R> 2SWAP 2R> 2SWAP ;
