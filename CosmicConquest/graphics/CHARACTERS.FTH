\ re-discovering original Apple ][ shapes

 SPACEFIG                    ( load shape tables)
   12 $ 31 $ 41 $ 47 $ 63 $ 74 $ \ not sure what these decimal values do ?

HEX 800 CONSTANT PDT  \ pattern descriptor table

: ]PDT ( c -- Vaddr)  8* 800 +  ; \ returns video memory address
: CHARDEF  ( data[] ascii -- )  ]PDT 20 VWRITE ;

HEX
CREATE SPACESHAPE
   243F ,  3736 , 2E24 , 2C36 ,
   2E2C ,  2E25 , 243C , 372E ,
   3436 ,  0000 , 0000 , 0000 ,

CREATE COLONYSHAPE
   122D , 2424 , 3F3F , 3636 , 2D00 ,

CREATE PLANETSHAPE
   2C36 , 3F24 , 0500 , 0000 ,

( star shape)
   3C C$ 36 C$ 2D C$ 24 C$ 1C C$ 1F C$ 16 C$ 16 C$ 0D C$ 0D C$
   1C C$ 2C C$ 1C C$ 0C C$ 04 C$ 00 C$
( players fleet shape)
   3C C$ 1B C$ 36 C$ 26 C$ 08 C$ 2D C$ 2D C$ 25 C$ 36 C$ 36 C$
   00 C$
( computers fleet shape)
   36 C$ 07 C$ 20 C$ 29 C$ 32 C$ 00 C$
 DROP
