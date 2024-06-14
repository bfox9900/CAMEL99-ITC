\ screen thing for FbForth 

\ demonstrates some Forth ideas
\ 1. Using named constants for ascii character
\ 2. Breaking programs up into small words
\    Test each word at the console before going on
\ 3. How to make a BREAK key
\ 4. Using your words to built a final program 
\ 5. How to make stack diagrams to document inputs/outputs
\ 6. You don't need HCHAR to write to the screen <wink>

NEEDS COLOR  FROM DSK1.GRAFIX 

DECIMAL
CHAR *  CONSTANT '*'
CHAR !  CONSTANT '!'
768 1-  CONSTANT N  \ chars per screen - 1

: GRAPHICS-STUFF ( -- )
    GRAPHICS
    1 SCREEN 
\   colorset FG BG      
    '*' SET# 13  1 COLOR
    '!' SET# 7   1 COLOR
;

\ thething uses VC! ( vdp character store)
\ to write a character to the screen
\ The stack diagram for VC! is ( char VDPaddr --)
: THE-THING ( -- )
    PAGE
    N 0   \ loop from 0 to screen size - 1 
    DO    \ I becomes the VDP screen address 
       '!'  I     VC!      \ write directly to VDP screen memory 
       '*'  N I - VC!      \ write to bottom of screen
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
;

CR ." **Type RUN to start"
CR  ." FNCT 4 to stop "
