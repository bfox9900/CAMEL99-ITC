CR .( GRAPHICS1.FTH for CAMEL99  May 2024 BFox )
CR .( *NEW*  version uses machine colors 0..15) 

NEEDS VC,    FROM DSK1.VDPMEM  \ use by new CALLCHAR
NEEDS VALUE  FROM DSK1.VALUES 

HERE
HEX
837B   CONSTANT VDPSTS   \ copy of vdp status register
83D4   CONSTANT VDPR1    \ VDP Register 1, TI SYSTEM address

( 380) 0 VALUE CTAB    \ color table
( 800) 0 VALUE PDT     \ pattern descriptor table 
(   0) 0 VALUE IMG     \ image table 
( 300) 0 VALUE SAT     \ sprite attribute table 
( 800) 0 VALUE SPT     \ Sprite descriptor table

.( .)
 \ ABORT to Forth with a msg if input is bad
: ?MODE  ( n -- )      VMODE @ <>  ABORT" Bad mode" ;
: ?COLOR ( n -- n )    15 OVER U<  ABORT" Bad Color" ;

\ ti-basic sub-programs begin
: CLEAR  ( -- ) PAGE  0 17 AT-XY  ; ( because you love it )
: SCREEN ( color -- ) 1 ?MODE ?COLOR 7 VWTR ; 

 : GRAPHICS1  ( -- )
      1 VMODE !
      0 3C0  0 VFILL \ erase the entire 40 col. screen space
\      4 DUP 2 VWTR 400 * VPG ! \ alternate page
      00  2 VWTR       \ page zero, same as text mode
      E0 DUP VDPR1 C!   \ KSCAN re-writes VDP Reg1 with this byte
( -- E0) 1 VWTR        \ VDP register 1  bit3 = 0 = Graphics Mode
      
      0E 3 OVER 40 *  TO CTAB VWTR       \ color table
      01 4 OVER 800 * TO PDT VWTR        \ pattern table
      06 5 OVER 80 *  TO SAT VWTR        \ sprite attribute table
      01 6 OVER 800 * TO SPT VWTR        \ sprite pattern table

      CTAB 10 10 VFILL \ color table: black on transparent [1,0]
      7 SCREEN         \ cyan SCREEN
      20 C/L!          \ 32 chars/line, 32X24 -> C/SCR 
      CLEAR
;

GRAPHICS1  
CR .( *GRAPHICS 1 mode ready*)

: ]CTAB  ( c -- Vaddr)  CTAB + ;   \ colour table as VDP array 
: ]PDT   ( c -- Vaddr)  8* PDT + ; \ "pattern descriptor table" VDP array 

.( .)
( test fg & bg for legal values, combines into 1 byte)
: >COLR ( fg bg -- byte)  ?COLOR SWAP ?COLOR 04 LSHIFT + ;

: COLOR  ( char-set fg-color bg-color -- )
        1 ?MODE >COLR SWAP ]CTAB  VC! ;

\ ascii value SET# returns the character set no.
: SET#  ( ascii -- set#) 3 RSHIFT ;

( *NEW*  change RANGE of character sets at once)
: COLORS  ( set1 set2 fg bg  -- )
          1 ?MODE
          >COLR >R  SWAP ]CTAB SWAP ]CTAB OVER - R> VFILL ;

: >DIG  ( char -- n) DIGIT? 0= ABORT" Bad digit" ;
.( .)
: CALLCHAR ( addr len char --) \ can be used for longstrings (128 bytes)
        BASE @  VP @ 2>R  \ save these variables
        ]PDT VP !         \ set vdp mem pointer to character location
        HEX               \ we are converting hex numbers in the string
        BOUNDS
        DO
           I    C@ >DIG  4 LSHIFT \ convert, move to right nibble
           I 1+ C@ >DIG  OR VC,   \ combine with left nibble and compile to VDP
        2 +LOOP
        2R> VP ! BASE !  \ restore the variables
;

.( .)
\ write data block to SPRITE pattern table 
: PDT-WRITE  ( data size 1stchar)  ]PDT SWAP VWRITE ; 
: CHARDEF  ( addr char# --)  8 PDT-WRITE ;  \ write one pattern to PDT
: CHARPAT  ( addr char# --)  ]PDT SWAP 8 VREAD ; \ read pattern to 'addr'
: GCHAR    ( col row -- char) >VPOS VC@ ; \ does not affect VROW,VCOL

\ *new* changed parameter order 
: HCHAR   ( char cnt col row  -- ) 
        >VPOS DUP>R          ( -- char cnt vdp1)  ( r: vdp1)
        OVER +               ( -- char cnt vdp_end)
        C/SCR @  -   0 MAX - ( -- char cnt' )
        R> -ROT SWAP VFILL ;

HEX
CODE VWRAP  ( Vaddr -- Vaddr') \ 4x faster than Forth
  02A1 ,               \ R1 STWP,
  0202 , C/SCR @ 1- ,  \ R2 C/SCR @ 1- LI,
  A121 , 002E ,        \ 2E R1 () TOS ADD,  ( C/L@ TOS + )
  8084 ,               \ TOS  R2 CMP,
  1201 ,               \ HI IF,
  6102 ,               \    R2 TOS SUB,
                       \ ENDIF,
  NEXT,
ENDCODE

: VCHAR ( char cnt col row  --)
    >VPOS  SWAP ?DUP 0= IF  2DROP EXIT THEN 
    0 DO  2DUP VC!  VWRAP  LOOP 2DROP ;

CR HERE SWAP - DECIMAL . .( bytes)
HEX
