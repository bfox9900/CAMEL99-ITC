\ M I S C E L L A N E O U S
[cc] HEX [tc]

: RECURSE     ( -- ) LATEST @ NFA>CFA COMPILE,  ; XIMMEDIATE
: DECIMAL     ( -- ) 0A BASE ! ;
: HEX         ( -- ) 10 BASE ! ;
