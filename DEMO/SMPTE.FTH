\  SMPTE Style Color Bars TI-99 CAMEL Forth Brian Fox 

\ INCLUDE DSK1.TOOLS   ( for debugging only)
NEEDS HCHAR   FROM DSK1.GRAFIX
NEEDS CHARSET FROM DSK1.CHARSET

DECIMAL
: COLOR-BARS ( -- )
   18 0
   DO
      2 I   88  4 HCHAR
      6 I   96  4 HCHAR
     10 I  104  4 HCHAR
     14 I  112  4 HCHAR
     18 I  120  4 HCHAR
     22 I  128  4 HCHAR
     26 I  136  4 HCHAR
   LOOP
;

: WHITE-BOX ( -- )
   7 18 152 6 HCHAR
   7 19 152 6 HCHAR
   7 20 152 6 HCHAR   
   7 21 152 6 HCHAR
   7 22 152 6 HCHAR   
   7 23 152 6 HCHAR
;

: SMPTE-BOXES
    2 17 136 4 HCHAR
    6 17 144 4 HCHAR
   10 17 120 4 HCHAR  
   14 17 144 4 HCHAR
   18 17 104 4 HCHAR  
   22 17 144 4 HCHAR
   26 17  88 4 HCHAR
;

HEX
CREATE SQUARE  FFFF , FFFF , FFFF , FFFF ,

DECIMAL
: CHARACTERS ( pattern first last -- )
        1+ SWAP ?DO    DUP I CHARDEF  8 +LOOP DROP ;

: SET-COLORS ( -- )
    88 SET#  15 1 COLOR
    96 SET#  11 1 COLOR
   104 SET#   8 1 COLOR
   112 SET#  13 1 COLOR
   120 SET#  14 1 COLOR   
   128 SET#  10 1 COLOR
   136 SET#   5 1 COLOR
   144 SET#   2 1 COLOR
   152 SET#  16 1 COLOR
;

: WAIT-BREAK  BEGIN ?TERMINAL UNTIL ;

: BARS  
   CLEAR  2 SCREEN

   SET-COLORS
   SQUARE 88 152 CHARACTERS

   COLOR-BARS  WHITE-BOX  SMPTE-BOXES
   
   WAIT-BREAK
   8 SCREEN
   4 19 2 1 COLORS
   CLEAR
   CHARSET
;

CR .( Done. Type BARS to run)


