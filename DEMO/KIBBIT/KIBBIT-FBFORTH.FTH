


50 VARIABLE JOY      \ joystick y position
50 VARIABLE JRT      \ joystick x position
 0 VARIABLE SELECT   \ selection
HEX 
\ Set Sprite Descriptor Table to 3800h in VRAM <--CANNOT do in text modes!
\ 3800 SSDT       <--already done by GRAPHICS2 in fbForth
: INIT_TURTLE
   \ set bitmap mode before sprites
   GRAPHICS2         \ clears SDT
   \ initialize turtle sprite chars
   8050 2828 2828 1000 8A SPCHAR
   8040 2424 2424 1800 8B SPCHAR
   8040 201C 0808 0800 8C SPCHAR
   \ initialize turtle sprite
   22 22 5 8C 1 SPRITE ;
DECIMAL 
: KIBBIT
   INIT_TURTLE
   BEGIN
      1 JOYST CASE      \ y value
         04 OF -1 JOY +! ENDOF
         252 OF 1 JOY +! ENDOF
      ENDCASE
      CASE              \ x value
         04 OF 1 JRT +! ENDOF
         252 OF -1 JRT +! ENDOF
      ENDCASE
      18 = IF           \ fire button?
         1 SELECT +!    \ increment selection
      ENDIF
      SELECT @ CASE
         0 OF DRAW 138 1 SPRPAT ENDOF
         1 OF UNDRAW 139 1 SPRPAT ENDOF
         2 OF DTOG 140 1 SPRPAT ENDOF
         3 OF 0 SELECT ! ENDOF
      ENDCASE
      JRT @ JOY @ 1 SPRPUT    \ move turtle to current position
      JRT @ JOY @ DOT         \ draw/undraw/toggle a dot at current position
      ?KEY 13 = IF      \ CR?
         INIT_TURTLE    \ set bitmap mode/re-initialize turtle to clear screen
      ENDIF
      ?KEY 32 =         \ <space>?
   UNTIL
   TEXT ;               \ back to text mode
KIBBIT            \ start program
;S                \ stop scanning block