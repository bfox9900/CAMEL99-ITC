\ STRAIGHT a word from PolyForth
\ Accept chars into a buffer with no echo
\ capable of reading continuous data at 9600 bps

\ **** for CAMEL99 on TTY ONLY!  ****

\ NEEDS MOV,      FROM DSK1.ASM9900
 NEEDS OPEN-FILE FROM DSK1.ANSFILES

HEX
CREATE ALLDONE         \ branch here to exit readcom
      020C , RS232/1 , \ R12 RS232/1 LI,
      1E07 ,           \ 7 SBZ,   \ turn off LED
      C337 ,           \ R12 RPOP,
      0300 , 0002 ,    \ 2 LIMI,
      C101 ,           \ R1 TOS MOV,  \ get the char count to Forth TOS
      NEXT,

\ READCOM can reliably receive at 19200 bps (no delays needed by sender)
\ Board led on solid while waiting, blinks with incoming data
\ LED turns off while counting down timeout
HEX
CODE READCOM  ( addr n -- n' ) \ machine code version
 0300 , 0000 , 0647 , C5CC ,
 020C , RS232/1 , 1D07 , C236 ,
 A108 , 0700 , 04C1 , C320 ,
 B050 , 1F15 , 1608 , 3638 ,
 1D12 , 0700 , 0581 , 020C ,
 1300 , 1D07 , 1007 , 0600 ,
 1602 , 0460 , CCB8 , 020C ,
 1300 , 1E07 , 8108 , 16EB ,
 0460 , ALLDONE ,  \  NEXT,
ENDCODE

: STRAIGHT   ( addr len -- n)
       SWAP 1+ TUCK 1-   ( addr+1 n addr)
       CR ." Send file now..."
       KEY SWAP C!     \ store first Char
       READCOM
       CR ;

HEX 1D00 MALLOC CONSTANT SBUFF

: ACCEPT-FILE  ( -- size) SBUFF 1D00 STRAIGHT ;

HEX
0D CONSTANT ^M

: 3RD  ( a b c -- a b c a ) 2 PICK ;

\ extract a line from buffer delimited by ^M (0D)
: /LINE ( addr len -- str1 len1 str2 len2)
        ^M SKIP         \ SKIP empty lines
         2DUP ^M SCAN   \ find end of line
         2SWAP  3RD - 0 MAX ;

: NEXTLINE ( addr len -- remainder len line len )
         /LINE 2SWAP 1 /STRING  2SWAP  ;

: SEE-BUFF ( addr len -- )
        LINES OFF
        BEGIN
             DUP -1 <>
        WHILE
            NEXTLINE TYPE ." . "
            ?TERMINAL ABORT" STOPPED"
            LINES 1+!
        REPEAT
        2DROP ;

DECIMAL
: SAVE-BUFF ( buffaddr len file$ len-- )
      2DUP  DISPLAY SEQUENTIAL 80 VARI W/O OPEN-FILE ?FILERR >R
      CR TYPE ."  Opened" CR
      LINES OFF
      BEGIN
        DUP -1 <>
      WHILE
        NEXTLINE R@ WRITE-LINE ?FILERR
        LINES 1+!  ." ."
      REPEAT
      S" " R@ WRITE-LINE ?FILERR \ add 1 final empty line
      R@ CLOSE-FILE ?FILERR
      R> DROP ;

DECIMAL
: SAVE-FILE ( addr len -- )
      ACCEPT-FILE
      SBUFF SWAP 2SWAP SAVE-BUFF
      CR LINES @ . ." lines saved"
      CR  ;
