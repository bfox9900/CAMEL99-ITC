\ create BASIC style CHARPAT strings

\ INCLUDE STRINGS.FTH

: HEX$     ( n -- top$) HEX  0  <# # # # # #> SPUSH ;

: CHARPAT$  ( char -- )
            CHARPAT >R >R >R  \ push 3 #s onto rstack
            HEX$              \ convert 1st #
            R> HEX$ &         \ convert 2nd # , concatenate
            R> HEX$ &         \ convert 3rd # , concatenate
            R> HEX$ &         \ convert 4th # , concatenate
            PAD PUT ;         \ store in temp buffer
