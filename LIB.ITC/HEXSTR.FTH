\ create BASIC style CHARPAT strings

INCLUDE DSK1.STRINGS
INCLUDE DSK1.GRAFIX

: HEX$     ( n -- top$) HEX  0  <# # # # # #> SPUSH ;

: CHARPAT$  ( char -- addr )
            CHARPAT >R >R >R  \ push 3 #s onto rstack
            HEX$              \ convert 1st #
            R> HEX$ &         \ convert 2nd # , concatenate
            R> HEX$ &         \ convert 3rd # , concatenate
            R> HEX$ &         \ convert 4th # , concatenate
            PAD TUCK PUT ;    \ store in temp buffer, return buffer
