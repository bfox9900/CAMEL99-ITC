\ IDE CARD support for CAMEL99 Forth   May 2020  B Fox
\
HERE
DECIMAL
  24 USER 'R12  \ address of R12 in any Forth workspace
HEX
: IDECARD  ( -- ) 1000 'R12 ! ; \ select ide card

HEX
\ *set the CRU address in 'R12 before using these words*
  CODE 0SBO  ( -- ) 1D00 ,  NEXT, ENDCODE
  CODE 0SBZ  ( -- ) 1E00 ,  NEXT, ENDCODE

  CODE 1SBO  ( -- ) 1D01 ,  NEXT, ENDCODE
  CODE 1SBZ  ( -- ) 1E01 ,  NEXT, ENDCODE

  CODE 2SBO  ( -- ) 1D02 ,  NEXT, ENDCODE
  CODE 2SBZ  ( -- ) 1E02 ,  NEXT, ENDCODE

  CODE 3SBO  ( -- ) 1D03 ,  NEXT, ENDCODE
  CODE 3SBZ  ( -- ) 1E03 ,  NEXT, ENDCODE

  CODE 4SBO  ( -- ) 1D04 ,  NEXT, ENDCODE
  CODE 4SBZ  ( -- ) 1E04 ,  NEXT, ENDCODE

  CODE 5SBO  ( -- ) 1D05 ,  NEXT, ENDCODE
  CODE 5SBZ  ( -- ) 1E05 ,  NEXT, ENDCODE

  CODE 6SBO  ( -- ) 1D06 ,  NEXT, ENDCODE
  CODE 6SBZ  ( -- ) 1E06 ,  NEXT, ENDCODE
