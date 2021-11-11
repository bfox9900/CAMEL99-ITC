
CR .( graphics shapes and utilities)
 \ TI-99 specific outer-space characters
 HEX
 CREATE ACOLONY 7884 , 3040 , 4030 , 8478 ,
 CREATE OPLANET 0030 , 4884 , 8484 , 4830 ,
 CREATE EPLANET 0070 , 8850 , 2050 , 8870 ,
 CREATE ASTAR   1044 , 38BA , 3844 , 1000 ,
 CREATE PFLEET  40F8 , 503C , 1040 , F840 ,
 CREATE EFLEET  20C0 , 2438 , 0410 , E010 ,
 CREATE BLKHOLE 7884 , 3078 , 7830 , 8478 ,

 \ -------------  box chars ---------------
 CREATE VBARS  2828 , 2828 , 2828 , 2828 ,
 CREATE HBARS  0000 , 00FF , 00FF , 0000 ,
 CREATE ULEFT  0000 , 003F , 202F , 2828 ,
 CREATE URIGHT 0000 , 00F8 , 08E8 , 2828 ,
 CREATE LLEFT  2828 , 282F , 203F , 0000 ,
 CREATE LRIGHT 2828 , 28E8 , 08F8 , 0000 ,

 : ]PDT ( n -- ) 8* 800 + ; \ TI-99 TMS9918 pattern descriptor table
DECIMAL
 : CHARDEF ( data[] ascii -- ) ]PDT 32 VWRITE ;

\ re-define shape of characters used in the matrix map
\ This allows us to write the map directly to the screen
: DEF-CHARS
  ASTAR     2 CHARDEF
  ACOLONY 132 CHARDEF
  OPLANET   4 CHARDEF
  EPLANET   5 CHARDEF
  BLKHOLE   8 CHARDEF
  PFLEET   16 CHARDEF
  EFLEET   17 CHARDEF

  VBARS   133 CHARDEF
  HBARS   134 CHARDEF
  ULEFT   135 CHARDEF
  URIGHT  136 CHARDEF
  LLEFT   137 CHARDEF
  LRIGHT  138 CHARDEF
;

DEF-CHARS

: VLINE ( len --) 0 DO  133 VPUT  VROW 1+!  LOOP ;
: HLINE ( len --) 0 DO  134 EMIT LOOP ;
: TOPLINE ( len --) 135 EMIT  HLINE  136 EMIT ;
: BOTLINE ( len --) 137 EMIT  HLINE  138 EMIT ;

: 2OVER   ( a b c d -- a b c d a b) 3 PICK  3 PICK ;
: BOXWIDTH  ( x1 y1  X2  Y2  -- n)  OVER  4 PICK - ;
: BOXHEIGHT ( x1 y1  X2  Y2  -- n)  3 PICK - ;
