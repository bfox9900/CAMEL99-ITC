CR .( GRAPHIX.FTH for CAMEL99 V2.X  Mar 2025 BFox )
CR .( 2025 faster, smaller CALLCHAR)
CR  \ added protections to HCHAR & VCHAR to stop writing off screen

HERE

HEX
: ]CTAB ( n -- Vaddr) 0380 + ; \ colour table VDP array
: ]PDT  ( n -- Vaddr) 8* 0800 + ; \ "pattern descriptor table" VDP array

: PDT-WRITE  ( data size 1stchar)  ]PDT SWAP VWRITE ;
: CHARDEF  ( addr char# --) ]PDT 8 VWRITE ;  \ write one pattern to PDT
: CHARPAT  ( addr char# --) ]PDT SWAP 8 VREAD ; \ read pattern to 'addr'

 \ ABORT to Forth with a msg if input is bad
: ?MODE  ( n -- N)    VMODE @ <>  ABORT" Bad mode" ;
: ?COLOR ( n -- n )   DUP 16 U> ABORT" Bad Color" ;

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
HEX
: GRAPHICS  ( -- )
      1 VMODE !
      0 3C0  0 VFILL \ erase the entire 40 col. screen space
\      4 DUP 2 VWTR 400 * VPG ! \ alternate page
      00  2 VWTR     \ page zero, same as text mode
      E0 DUP 83D4 C! \ KSCAN re-writes VDP Reg1 with this byte
( -- E0) 1 VWTR      \ VDP register 1  bit3 = 0 = Graphics Mode
      0E 3 VWTR        \ color table
      01 4 VWTR        \ pattern table
      06 5 VWTR        \ sprite attribute table
      01 6 VWTR        \ set sprite pattern table to 1x$800=$800
      0 ]CTAB 20 10 VFILL \ color table: black on transparent [1,0]
      8 SCREEN         \ cyan SCREEN
      20 C/L!          \ 32 chars/line
      CLEAR
;

HEX
: CALLCHAR ( addr len ascii# --)
        BASE @ >R
        HEX
        ]PDT >R         \ save pattern table address
        BEGIN
           DUP
        WHILE
        \ convert 1ST 4 chars to 16 bit #
            OVER 4 NUMBER? ABORT" Not HEX"
            R@ V!            \ store integer (2 bytes)
            4 /STRING 0 MAX  \ cut 4 chars off the string
            R> 2+ >R         \ bump PDT address by 2
        REPEAT
        2DROP
        R> DROP
        R> BASE ! ;

.( .)
\ write data block to pattern descriptor table
: GCHAR    ( col row -- char) >VPOS VC@ ; \ does not affect VROW,VCOL

: HCHAR   ( col row char cnt -- ) \ *new* added automatic size protection
        2SWAP >VPOS   ( -- char cnt vdp1)
        DUP>R         ( -- char cnt vdp1)  ( r: vdp1)
        OVER +        ( -- char cnt vdp_end)
        C/SCR @  -   0 MAX - ( char cnt' )
        R> -ROT SWAP VFILL ;

\ change to Graphics mode (C/SCR = HEX300) to compile VWRAP correctly
GRAPHICS

.( .)
HEX
CODE VWRAP ( addr -- addr')  \ 4x faster than Forth
  02A1 ,               \ R1 STWP,
  0202 , C/SCR @ 1- ,  \ R2 C/SCR @ 1- LI,
  A121 , 002E ,        \ 2E R1 () TOS ADD,  ( C/L@ TOS + )
  8084 ,               \ TOS  R2 CMP,
  1201 ,               \ HI IF,
  6102 ,               \    R2 TOS SUB,
                       \ ENDIF,
  NEXT,
ENDCODE

: VCHAR ( col row char cnt --)
  DUP 0= IF 2DROP 2DROP EXIT THEN
  2SWAP >VPOS  SWAP 0 DO  2DUP VC! VWRAP  LOOP 2DROP  ;

DECIMAL
0 32 2 1 COLORS

CR .( GRAPHICS 1 Mode READY)
CR HERE SWAP -  . .( bytes)
