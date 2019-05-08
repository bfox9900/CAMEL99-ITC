\ STRAIGHT a word from PolyForth
\ Accept chars into a buffer with no echo
\ capable of reading continuous data at 9600 bps

NEEDS MOV, FROM DSK1.ASM9900

CREATE ALLDONE     \ branch here to exit readcom
      R12 RS232/1 LI,
      7 SBZ,       \ turn off LED
      R12 RPOP,
      2 LIMI,
      R1 TOS MOV,  \ get the char count to Forth TOS
      NEXT,
DECIMAL
CODE READCOM ( addr n -- n' )
         0 LIMI,                \ we need the entire machine
         R12 RPUSH,
         R12 RS232/1 LI,
         7 SBO,                 \ turn on LED
         PORT @@ R12 MOV,       \ select the 9902
        *SP+ W MOV,             \ addr ->W   (ie: R8)
         W TOS ADD,             \ calc last address ->TOS
         R0 SETO,               \ set timeout register >FFFF
         R1 CLR,                \ reset char counter
         BEGIN,
            21 TB,
            EQ IF,
               *W+ 8 STCR,    \ put char in buf & inc
                18 SBO,       \ clr rcv buffer
                R0 SETO,      \ reset timeout to 0FFFF
                R1 INC,       \ count char
            ELSE,
                R0 DEC,       \ no char, dec TIMEDOUT
                EQ IF,
                    ALLDONE @@ B,
                ENDIF,
            ENDIF,
            W TOS CMP,        \ W =   end of buffer ?
         EQ UNTIL,
         ALLDONE @@ B,
         ENDCODE

: STRAIGHT   ( addr len -- n)
       SWAP 1+ TUCK 1-   ( addr+1 n addr)
       CR ." Send file now..."
       KEY SWAP C!     \ store first Char
       READCOM
       CR ;

HEX
0D CONSTANT ^M

: 3RD  ( a b c -- a b c a ) 2 PICK ;

\ extract a line from buffer delimited by ^M (0D)
: /LINE ( addr len -- str1 len1 str2 len2)
         2DUP ^M SCAN  2SWAP  3RD - ;

: NEXTLINE ( addr len -- remainder len line len )
         /LINE 2SWAP 1 /STRING  2SWAP ;

: SEE-BUFF ( addr len -- )
          LINES OFF
          BEGIN
             DUP -1 <>
          WHILE
            NEXTLINE CR TYPE
            LINES 1+!
          REPEAT
         2DROP ;

: LOAD-BUFF ( addr len -- )
         LINES OFF
         BEGIN
           DUP -1 <>
         WHILE
            NEXTLINE PAD PLACE
            PAD COUNT INTERPRET ." ."
            LINES 1+!
         REPEAT
         2DROP ;

: STRIP^M ( adr len -- )
       BOUNDS
       DO
         I C@ 0D =
         IF BL I C! THEN
       LOOP ;


VARIABLE MYBUFF
VARIABLE BSIZE
VARIABLE FHNDL

: SAVE-BUFF ( addr len -- )
      DV80 R/W OPEN-FILE FHNDL !
      MYBUFF @  BSIZE @
      LINES OFF
      BEGIN
        DUP -1 <>
      WHILE
        NEXTLINE FHNDL @ WRITE-LINE
        LINES 1+!
      REPEAT
      FHNDL DUP @  CLOSE-FILE
      OFF
      DROP ;

: SEE-BUFF ( addr len -- )
          MYBUFF @  BSIZE @
            LINES OFF
            BEGIN
              DUP -1 <>
            WHILE
              NEXTLINE CR TYPE
              LINES 1+!
            REPEAT
            DROP ;

: SAVE-FILE ( addr len -- )
       2000 DUP MALLOC DUP MYBUFF !   \ take the entire heap (8k)
       OVER BSIZE !
      ( buff size ) STRAIGHT
      CR ." Complete. Press Enter to save"
      KEY DROP
