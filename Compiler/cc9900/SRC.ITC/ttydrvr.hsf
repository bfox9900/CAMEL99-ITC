TTYDRVR.HSF  provides i/o via tI-99 rs232 card     Feb 2023 Brian Fox 


[CC] INCLUDE CC9900\SRC.OCT\9902SHAK.HSF   ( primitives with hardware handshake)

: C/L!     ( c/l -- )  \ pronounced "SEE-PER-ELL-STORE"
           DUP C/L !           \ set chars per line
           L/SCR *  C/SCR ! ;  \ calc. chars per screen

CR .( VT100 terminal control, [0,0] Home coordinates  May 2020 )
DECIMAL
\ type 'n' as a two digit number in base 10, with no space
: <##>   ( n -- )
         BASE @ >R                   \ save radix
         0 <#  DECIMAL # #  #> TYPE  \ convert to 2 digits & print
         R> BASE ! ;                 \ restore radix

\ markup language for terminal control codes
\ : <ESC>   ( -- )   27 EMIT ;
: <ESC>[  ( -- )   27 EMIT  91 EMIT  ;
: <UP>    ( n -- ) <ESC>[ <##> ." A" ;
: <DOWN>  ( n -- ) <ESC>[ <##> ." B" ;
: <RIGHT> ( n -- ) <ESC>[ <##> ." C" ;
: <BACK>  ( n -- ) <ESC>[ <##> ." D" ;
: <HOME>  ( -- )   <ESC>[ ." H"   0 0 VROW 2! ;

\ define Forth words using markup words
: PAGE    ( n -- ) <ESC>[ ." 2J"  <HOME> ;
: AT-XY   ( col row --)
          2DUP VROW 2!  \ store col,row
          <ESC>[ 1+ <##> ." ;" 1+ <##> ." f" ;

TARGET-COMPILING
: EMIT   ( c -- ) PAUSE CEMIT ; 

: CR   ( -- ?)   \ comm port carriage return
         0D EMIT 0A EMIT
         VCOL OFF
         VROW @ 1+  17 MIN VROW !  ; \ don't count past last line

\ : SPACE 
: BS     ( --)  08 EMIT SPACE 08 EMIT ; 
: TYPE   ( addr cnt --)  PAUSE  BOUNDS ?DO  I C@ CEMIT LOOP ;
: SPACE  ( -- )   BL EMIT ;
: SPACES  ( n -- ) 0 MAX  0 ?DO  SPACE  LOOP ;

TARGET-COMPILING
: KEY   ( -- char)
            BEGIN
              PAUSE        \ multi-tasking switch
              KEY?         \ test for key
              ?DUP         \ dup if not zero
            UNTIL          \ char is on stack if loop exits
;

: ?TERMINAL  ( -- ?) KEY? 3 = ;  \ ^C is our "break" key

\ High level: input/output             \ (c) 31mar95 bjr
: ACCEPT     ( c-addr +n -- +n')       \ get line from terminal
            OVER + 1- OVER
            BEGIN
              KEY DUP 0D <>              \ test for enter
            WHILE
              DUP EMIT
              DUP 8 =                     \ ^H
              IF   DROP 1-  3 PICK  UMAX  \ move the buffer pointer back
              ELSE OVER C!  1+ OVER UMIN
              THEN
            REPEAT
            DROP NIP SWAP -  ;

