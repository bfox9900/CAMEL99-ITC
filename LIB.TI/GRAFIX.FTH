\ GRAPHIX.FTH for CAMEL99 V2

\ DEFINE VDP TABLES AS ARRAYS

HEX
 0380 CONSTANT CTAB      \ COLOUR TABLE
 0800 CONSTANT PDT       \ "PATTERN DESCRIPTOR TABLE"

\ access VDP tables like arrays. Usage:  9 ]CTAB returns VDP addr
 : ]CTAB  ( set# -- 'ctab[n])   CTAB + ;    \ 1 byte fields
 : ]PDT   ( char# -- 'pdt[n] )  8* PDT + ;  \ 8 byte fields


\ ABORT to Forth with a msg if input is bad
: ?MODE  ( n -- )      VMODE @ <>   ABORT" Bad mode" ;
: ?COLOR ( n -- n )    DUP 16 U>    ABORT" Bad Color" ;
: ?SCR   ( vdpadr -- ) C/SCR @ CHAR+ > ABORT" too many chars"  ;

( takes fg nibble, bg nibble, convert to TI hardware #s)
( test for legal values, and combine into 1 byte)
: >COLR ( fg bg -- byte) 1- ?COLOR SWAP 1- ?COLOR  04 LSHIFT + ;

\ : >VPOS ( col row -- VPOS)  C/L@ * + ;  \ moved to CODE word


\ TI-BASIC SUB-PROGRAMS BEGIN

: CLEAR  ( -- )  PAGE  0 17 AT-XY  ;   ( just because you love it )
: COLOR  ( character-set fg-color bg-color -- )
          1 ?MODE  >COLR SWAP ]CTAB  VC! ;


\ ascii value SET# returns the character set no. 

: SET#  ( ascii -- set#) 3 RSHIFT ;     ( usage:  CHAR A SET# 2 8 COLOR)

( *NEW*  change contiguous character sets at once)
: COLORS  ( set1 set2 fg bg  -- )
          1 ?MODE
          >COLR >R
          SWAP ]CTAB SWAP ]CTAB OVER - R> VFILL ;

: SCREEN ( color -- )
         1 ?MODE                \ check for MODE 1
         1- ?COLOR              \ TI-BASIC color to VDP color and test
 ( -- n) 7 VWTR  ;              \ set screen colour in Video register 7

( Changes to familiar TI-BASIC CYAN screen)
: GRAPHICS  ( -- )
             1 VMODE !          \ call this video mode 1
             0 380  0 VFILL     \ erase the entire 40 col. screen space
             E0 DUP KTP C!      \ KSCAN re-writes VDP Reg1 with this byte
      ( -- E0) 1 VWTR           \ VDP register 1  bit3 = 0 = Graphics Mode
             1 6 VWTR           \ set sprite descriptor table to 1x$800=$800
             CTAB 10 10 VFILL   \ black on transparent [1,0]
             8 SCREEN           \ cyan SCREEN
             20 C/L!            \ 32 chars/line
             CLEAR ;

\ CHAR sub-program is renamed to CHARDEF
: CHARDEF  ( addr char# --)  ]PDT      8 VWRITE ;   \ ti basic call char              
: CHARPAT  ( addr char# --)  ]PDT SWAP 8 VREAD ;    \ ti basic call charpat

: PATTERN: ( u u u u  -- )       \ character pattern, compatible with CHARDEF
\ USAGE:  HEX 0000 FF00 AABB CCDD PATTERN: SHAPE1
           CREATE     >R >R >R   \ Rpush 3 values so we can reverse order
           ,  R> , R> , R> , ;   \ compile 4 ints in VDP useable order

: GCHAR ( col row -- char) AT-XY VPOS VC@ ;

\ NOTES:
\ 1. Unlike BASIC HCHAR & VCHAR must have the cnt parameter
\ 2. col and row do not affect VCOL and VROW variables
: HCHAR  ( col row char cnt -- ) \ parameter order not ideal so we shuffle
          SWAP >R >R         \ swap char & cnt, push to return stack
          C/L@ * +           \ ( -- vdp_addr)
          R>  2DUP + ?SCR    \ bring back count add to Vadr and test
          R>  VFILL ;        \ bring back char and FILL Video memory

: VCHAR  ( col row char cnt -- ) \ parameter order not ideal so we shuffle
          2>R                \ ( -- x y )  push char & cnt to rstack
          C/L@ * +           \ ( -- vdp_addr) calc the Video position in memory
          C/SCR @ 1- SWAP    \ ( -- lim vdpaddr) End of screen - 1, is the Video Limit
          R> SWAP            \ ( -- lim char vadr) get the char and reverse order
          R> 0               \ ( -- lim char vadr cnt index) all that crap to get this
          ?DO                \ ( -- lim char vadr)  let 'er rip
             2DUP VC!        \ write char to video memory)
             C/L@ +  VCLIP   \ clip vadr to lim value (CODE word for speed)
          LOOP
          2DROP DROP ;

GRAPHICS CR .( GRAPHICS 1 Mode READY)
