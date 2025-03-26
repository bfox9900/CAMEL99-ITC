\ Translate a BASIC program to FORTH  Feb 2024 Fox 

\ 1 ! TILTED BOXES ILLUSION 
\ 100 call clear
\ 102 call screen(6)
\ 103 call char(33,"30C0030C30C0030C0C03C0300C03C03")
\ 110 call box(4,9,29,11,33)
\ 111 call box(10,13,23,18,34)
\ 112 goto 112
\ 1120 sub box(x1,y1,x2,y2,c)
\ 1130     for y=y1 to y2
\ 1140         call hchar(y,x1,c,x2-x1+1)
\ 1150     next y
\ 1160 subend

NEEDS DUMP       FROM DSK1.TOOLS
NEEDS GRAPHICS   FROM DSK1.GRAFIX

DECIMAL
\ this string re-defines the shape of character 126 and 127 
S" 30C0030C30C0030C0C03C0300C03C030" 126 CALLCHAR

\ X BASIC's sub functions provides local variables. We have to do  
\ a lot more work to make BOX without local variable support. 
\ We can use PICK to reach into the stack to get arguments 
\ and the return stack for temporary storage.  

\ convert x,y coordinates to VDP address, height and length 
: HEIGHT   ( x1 y1 x2 y2 -- x1 y1 x2 y2 n) DUP  3 PICK - 1+ ;
: LENGTH   ( x1 y1 x2 y2 -- x1 y1 x2 y2 n) OVER 4 PICK -  ;
: VADDR   ( x1 y1 x2 y2 --  Vaddr) 2DROP >VPOS ;

\ resorted to 1 temp variable :-(
VARIABLE CHR 

: BOX   ( x1 y1 x2 y2 char -- ) 
      CHR !
      HEIGHT >R  LENGTH >R
      VADDR  R> R>  ( -- Vaddr len hgt)
      0 DO  
          2DUP CHR @ VFILL 
          SWAP C/L @ + SWAP 
      LOOP 
      2DROP
;  

: RUN
    PAGE ." * Tilted Boxes Illusion *"
    6 SCREEN
\       x  y    x  y   char      
        6  3   16  7   127 BOX
        4 10   20 15   126 BOX
    BEGIN  ?TERMINAL  UNTIL     \ goto 112 :-)
;
