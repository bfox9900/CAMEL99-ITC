\ MULTCOLR.FTH for   CAMEL99 V2

          **work_in_progress** 

\ This mode is selected by setting bit 4 of VDP register 1 as 1.
\ Bit 3 must be 0, as well as bit 7 of register 0. VR0: 0 VR1: 0 1

\ In this mode, the screen is divided into 48 rows of 64 boxes.
\ Each box is 4x4 pixel and can be independently assigned a color.
\ The screen image table is still >300 bytes long, but each byte now represents
\ a "character" made of 4 boxes.
\ The boxes are arranged as:
\   0 1
    2 3

\ define vdp tables as arrays
HEX
 0380 CONSTANT CTAB      \ colour table
 0800 CONSTANT PDT       \ "pattern descriptor table"

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

\ TI-BASIC SUB-PROGRAMS BEGIN
: CLEAR  ( -- )  PAGE  0 17 AT-XY  ;   ( just because you love it )
: COLOR  ( character-set fg-color bg-color -- )
          1 ?MODE  >COLR SWAP ]CTAB  VC! ;

\ ascii value SET# returns the character set no.
: SET#  ( ascii -- set#) 3 RSHIFT ;

( *NEW*  change contiguous character sets at once)
: COLORS  ( set1 set2 fg bg  -- )
          1 ?MODE
          >COLR >R
          SWAP ]CTAB SWAP ]CTAB OVER - R> VFILL ;

: SCREEN ( color -- )
         1 ?MODE             \ check for MODE 1
         1- ?COLOR ( -- n)   \ TI-BASIC color to VDP color and test
         7 VWTR  ;           \ set screen colour in Video register 7

( Like TI-BASIC )
: GRAPHICS  ( -- )
             1 VMODE !        \ call this video mode 1
             0 380  0 VFILL   \ erase the entire 40 col. screen space
             E0 DUP 83D4 C!    \ KSCAN re-writes VDP Reg1 with this byte
      ( -- E0) 1 VWTR         \ VDP register 1  bit3 = 0 = Graphics Mode
             1 6 VWTR         \ set sprite descriptor table to 1x$800=$800
             CTAB 10 10 VFILL \ color table: black on transparent [1,0]
             8 SCREEN         \ cyan SCREEN
             20 C/L!          \ 32 chars/line
             CLEAR ;

\ CHAR sub-program is renamed to CHARDEF
: CHARDEF  ( addr char# --)  ]PDT      8 VWRITE ; \ ti basic call char
: CHARPAT  ( addr char# --)  ]PDT SWAP 8 VREAD ;  \ ti basic call charpat

: PATTERN: ( u u u u -- )
\ USAGE:  HEX 0000 FF00 AABB CCDD PATTERN: SHAPE1
           CREATE
              >R >R >R
           ,  R> , R> , R> , ;

: GCHAR ( col row -- char) VROW 2@ >VPOS VC@ ;

\ NOTES:
\ 1. Unlike BASIC HCHAR & VCHAR must have the cnt parameter
\ 2. col and row do not affect AT-XY, VCOL or VROW
: HCHAR  ( col row char cnt -- )
          SWAP 2>R           \ swap char & cnt, push to return stack
          >VPOS              \ ( -- vdp_addr)
          R>  2DUP + ?SCR    \ add count to Vadr and test
          R>  VFILL ;        \ get char, FILL Vmemory

: VCHAR  ( col row char cnt -- ) \ parameter order not ideal so we shuffle
          2>R                \ ( -- x y )
          >VPOS              \ ( -- vdp_addr)
          C/SCR @ 1- SWAP    \ ( -- lim vdpaddr)
          R> SWAP            \ ( -- lim char vadr)
          R> 0               \ ( -- lim char vadr
          ?DO                \ ( -- lim char vadr)
             2DUP VC!
             C/L@ +  VCLIP
          LOOP
          2DROP DROP ;


GRAPHICS CR .( GRAPHICS 1 Mode READY)
