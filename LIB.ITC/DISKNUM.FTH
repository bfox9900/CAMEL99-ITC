\ find the disk number in use for CAMEL99 Forth

\ MOV @>83D0,R12 		GET THE CRU BASE IN R12
\ JEQ EXIT 			GET OUT IF 0
\ MOV @>83D2,R9 		GET THE ROM ADDRESS FOR DEVICE
\ JEQ EXIT 			GET OUT IF 0
\ SBO 0 				ENABLE THE DEVICE ROM
\ AI R9,8 			Now R9 points to disk number (ascii)

\ get current drive#
DECIMAL
24 USER 'R12

HEX
83D0 CONSTANT DISKCARD
83D2 CONSTANT CARDROM

CODE 0SBO  ( -- ) 1D00 ,  NEXT, ENDCODE
CODE 0SBZ  ( -- ) 1E00 ,  NEXT, ENDCODE

: ?DISKS    4000 C@ AA <> IF 0SBZ TRUE ABORT" No disk" THEN ;

: DSK$  ( -- $addr)
         DISKCARD @ 'R12 !
         0SBO
         ?DISKS CARDROM @ 4 + COUNT PAD PLACE
         0SBZ
         PAD
;

: DSK#  ( -- n)
         DISKCARD @ 'R12 ! \ DUP 0= ABORT" No card"
         0SBO
         ?DISKS CARDROM @ 8 + C@
         0SBZ
        [CHAR] 0 -
;
