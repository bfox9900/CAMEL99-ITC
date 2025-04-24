\ pluspath.fth   add path to a filename      Mar 4 2023 Brian Fox 

: +PLACE  ( addr n $ -- ) 2DUP 2>R  COUNT +  SWAP MOVE 2R> C+! ;

\ ========================
\ get current drive string
\ ========================
DECIMAL
24 USER 'R12

HEX
CODE 0SBO  ( -- ) 1D00 ,  NEXT, ENDCODE \ turn on card 
CODE 0SBZ  ( -- ) 1E00 ,  NEXT, ENDCODE \ turn off card 

: DISKCARD ( -- CRU) 83D0 @ ;    ( CRU address of the disk CARD )
: DEVLIST  ( -- $)  83D2 @ 4 + ; ( device strings in the card's ROM)

CREATE DSK$ 8 ALLOT  \ place for the device name in Forth 

: GETDEV  (  -- addr len) \ DSK$ will contain boot device 
  DISKCARD 'R12 !
  0SBO   DEVLIST COUNT DSK$ PLACE   0SBZ
  S" ." DSK$ +PLACE \ add the '.' char
  DSK$ COUNT 
;

\ ========================
\ append drive to filename 
\ ========================
: +PATH  ( filename$ len -- path$ len )
   GETDEV PAD PLACE  PAD +PLACE   PAD COUNT ;

\ test if we need to append the drive
: ?+PATH   ( addr$ len -- addr$ len )
    2DUP [CHAR] . SCAN NIP   \ scan string for '.'
    0= IF  +PATH  THEN  ;    \ if no '.' add the path 
