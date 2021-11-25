CR .( GRAPHIX.FTH for CAMEL99 V2.X  July 6, 2021 BFox )
CR  \ added VWRAP to speed up VCHAR by 4X
HERE
NEEDS VC, FROM DSK1.VDPMEM  \ use by new CALLCHAR

HEX
 0380 CONSTANT CTAB      \ colour table VDP address
 0800 CONSTANT PDT       \ "pattern descriptor table" VDP address

\ access VDP tables like arrays. Usage:  9 ]CTAB returns VDP addr
 : ]CTAB  ( set# -- 'ctab[n])   CTAB + ;    \ 1 byte fields
 : ]PDT   ( char# -- 'pdt[n] )  8* PDT + ;  \ 8 byte fields

\ ABORT to Forth with a msg if input is bad
: ?MODE  ( n -- )      VMODE @ <>   ABORT" Bad mode" ;
: ?COLOR ( n -- n )    DUP 16 U>    ABORT" Bad Color" ;
: ?SCR   ( vdpadr -- ) C/SCR @ CHAR+ > ABORT" too many chars" ;

( takes fg nibble, bg nibble, convert to TI hardware no.)
( test for legal values, and combine into 1 byte)
: >COLR ( fg bg -- byte) 1- ?COLOR SWAP 1- ?COLOR  04 LSHIFT + ;
.( .)
\ ti-basic sub-programs begin
: CLEAR  ( -- ) PAGE  0 17 AT-XY  ; ( because you love it )

: COLOR  ( character-set fg-color bg-color -- )
          1 ?MODE  >COLR SWAP ]CTAB  VC! ;

\ ascii value SET# returns the character set no.
: SET#  ( ascii -- set#) 3 RSHIFT ;

( *NEW*  change RANGE of character sets at once)
: COLORS  ( set1 set2 fg bg  -- )
          1 ?MODE
          >COLR >R
          SWAP ]CTAB SWAP ]CTAB OVER - R> VFILL ;

: SCREEN ( color -- )
         1 ?MODE             \ check for MODE 1
         1- ?COLOR ( -- n)   \ TI-BASIC color to VDP color and test
         7 VWTR  ;           \ set screen colour in Video register 7
.( .)
 : GRAPHICS  ( -- )
      1 VMODE !
      0 3C0  0 VFILL \ erase the entire 40 col. screen space
      E0 DUP 83D4 C! \ KSCAN re-writes VDP Reg1 with this byte
( -- E0) 1 VWTR      \ VDP register 1  bit3 = 0 = Graphics Mode
      0E 3 VWTR        \ color table
      01 4 VWTR        \ pattern table
      06 5 VWTR        \ sprite attribute table
      01 6 VWTR        \ set sprite pattern table to 1x$800=$800
      CTAB 10 10 VFILL \ color table: black on transparent [1,0]
      8 SCREEN         \ cyan SCREEN
      20 C/L!          \ 32 chars/line
      CLEAR ;

: >DIG  ( char -- n) DIGIT? 0= ABORT" Bad digit" ;
: CALLCHAR ( addr len char --) \ can be used for longstrings (128 bytes)
        BASE @  VP @ 2>R  \ save these variables
        ]PDT VP !         \ set vdp mem pointer to character location
        HEX               \ we are converting hex numbers in the string
        BOUNDS
        DO
           I    C@ >DIG  4 LSHIFT
           I 1+ C@ >DIG  OR VC,
        2 +LOOP
        2R> VP ! BASE !  \ restore the variables
;
.( .)
\ PATTERN: is deprecated. Use CREATE and comma
 : PATTERN: ( u u u u -- ) CREATE  >R >R >R  , R> , R> , R> , ;

: CHARDEF  ( addr char# --)  ]PDT      8 VWRITE ; \ write pattern to PDT
: CHARPAT  ( addr char# --)  ]PDT SWAP 8 VREAD ;  \ read pattern to 'addr'
: GCHAR    ( col row -- char) >VPOS VC@ ; \ does not affect VROW,VCOL

: HCHAR   ( col row char cnt -- )
          2SWAP >VPOS   ( -- char cnt vdp_addr)
          2DUP + ?SCR
         -ROT SWAP VFILL ;

\ change to Graphics mode (C/SCR = HEX300) to compile VCHAR correctly
GRAPHICS

HEX
CODE VWRAP   \ 4x faster than Forth
  02A1 ,               \ R1 STWP,
  0202 , C/SCR @ 1- ,  \ R2 C/SCR @ 1- LI,
  A121 , 002E ,        \ 2E R1 () TOS ADD,  ( C/L@ TOS + )
  8084 ,               \ TOS  R2 CMP,
  1201 ,               \ HI IF,
  6102 ,               \    R2 TOS SUB,
                       \ ENDIF,
  NEXT,
ENDCODE

: (VCHAR) ( char vdp_addr cnt --) 0 ?DO   2DUP VC!   VWRAP   LOOP ;
: VCHAR   ( col row char cnt -- ) 2SWAP >VPOS SWAP (VCHAR) 2DROP ;

CR .( GRAPHICS 1 Mode READY)
CR HERE SWAP - DECIMAL . .( bytes)
HEX
