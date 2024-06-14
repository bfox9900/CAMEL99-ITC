\ screen thing for FbForth 

\ demonstrates some Forth ideas
\ 1. Using named constants for ascii character
\ 2. Breaking programs up into small words
\    Test each word at the console before going on
\ 3. How to make a BREAK key
\ 4. Using your words to built a final program 
\ 5. How to make stack diagrams to document inputs/outputs
\ 6. You don't need HCHAR to write to the screen <wink>

DECIMAL
ASCII * CONSTANT '*'
ASCII ! CONSTANT '!'
768 1-  CONSTANT N  \ chars per screen - 1

\ compute the correct color set number for any ASCII char 
: SET#  ( ascii -- color_set) 8 / ; 

\ cause a delay in milliseconds (or so)
: MS    ( msdelay -- ) 0 DO  9 0 DO LOOP LOOP ;

: GRAPHICS-STUFF ( -- )
    GRAPHICS
\   FG BG  colorset    
    13  1  '*' SET# COLOR
    7   1  '!' SET# COLOR
;

\ thething uses VDP SINGLE BYTE WRITE (VSBW)
\ to write a character to the screen
\ The stack diagram for VSBW is ( char VDPaddr --)
: THE-THING ( -- )
    PAGE
    N 0   \ loop from 0 to screen size - 1 
    DO    \ I becomes the VDP screen address 
       '!'  I     VSBW      \ write directly to VDP screen memory 
       '*'  N I - VSBW      \ write to bottom of screen
        25 MS
        ?TERMINAL ABORT" *BREAK*" 
    LOOP
    DROP
;

: RUN ( -- )
    GRAPHICS-STUFF 
    BEGIN 
      THE-THING 
    AGAIN 
    TEXT 
;

CR ." **Type RUN to start"
CR  ." FNCT 4 to stop "
