( COSMIC CONQUEST TARGET SPECIFIC WORDS for TI-99 )

\ Camel99 Forth Library requirements
INCLUDE DSK1.CASE
INCLUDE DSK1.UDOTR

\ FIG FORTH isms
\ HELPFUL RESOURCE: https://dwheeler.com/6502/fig-forth-glossary.txt
\ Helpful book: Forth Fundamentals Vol. 2, C. Kevin McCabe,
\ dilithium Press 1983, ISBN 0-88056-092-4
: ENDIF      POSTPONE THEN ; IMMEDIATE
: VARIABLE   CREATE ,  ;  \ FIG VARIABLE takes an intial parameter
: MINUS      NEGATE ( FFv2 page 97) ;
: -DUP       ?DUP ( FFv2 page 39) ;

\ GFORTH isms  16bit fetch store is default in Camel99 Forth
: W@    @ ;
: W!    ! ;

\ Forth words for HIRES-mode graphics
\ given these dialect-specific words an "adaptor shim" could be made for
\ any other Forth
: HCOLOUR ( colour ---) DROP ;  ( select current colour for HIRES drawing mode)
: HLINE ( x y --- ) DROP DROP ; ( draw HIRES mode line to position)
: HPOSN ( x y --- ) DROP DROP ; ( moves HIRES mode pixel cursor)
: SCALE ( scale --- ) DROP ;    ( sets shape table scaling value)

\ implement home, hclr and vhtab using ANSI commands
\ SEE: https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797

: HOME ( --- )  0 0 AT-XY ; ( set cursor to home position)

\ real HCLR would clear HIRES1
\ : HCLR ( --- )  0 C/SCR @ BL VFILL ; \ Erase VDP memory. Don't touch cursor.
\ : VHTAB ( y x --- )  SWAP AT-XY ;
: H1 ( --- ) ; ( selects HIRES mode 1, without clearing screen)
\ : TEXT ( --- ) ( selects TEXT screen leaving HIRES1 unchanged) ;

: DRAW ( addr delim --- )
( draw shape table, presumably first value is address and second is delimiter)
   DROP DROP ; ( discard values from stack)

HEX
: ?LOWER  ( c -- ?)  [CHAR] a  [CHAR] z 1+  WITHIN ;
: TOUPPER ( c -- c') DUP ?LOWER IF 5F AND  THEN ;
: INKEY   ( -- c)    KEY 7F AND  TOUPPER ;  \ uppercase Alpha, 7 bit output

DECIMAL
\ : INKEY ( --- key)
\   KEY DUP DUP
\   [CHAR] ` >
\      IF ( ASCII value 'a' or higher)
\         [CHAR] { <
\            IF ( ASCII value 'z' or lower)
\                223 AND ( mask off upper/lower case bit)
\            ENDIF
\     ENDIF
\     127 AND   \ 7 bit output
\ ;
