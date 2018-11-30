\ TI sound list player using VDP RAM    CAMEL99 Forth V2
\ ========================================================

INCLUDE DSK1.VDPMEM.F

\ ========================================================
\ sound list player
HEX
: SILENT ( --)  9F SND!  BF SND!  DF SND! FF SND! ;  \ turn off all sounds

: VPLAY$ ( sound_string -- ) \ play 1 sound string from VDP memory
       VCOUNT                \ -- addr len
       2DUP + VC@  >R        \ get duration at end of string, Rpush
       BOUNDS                \ convert addr/len to end-addr. start-addr.
       DO  I VC@ SND! LOOP   \ feed bytes to sound chip
       R> JIFFS ;            \ use the delay from Rstack (JIFF=1/60)

: VPLAYLIST   ( addr -- )    \ play a TI sound list
         BEGIN DUP VC@ WHILE \ while the length is not 0
            PAUSE            \ give somebody else some time
            DUP VPLAY$       \ play a single string
            VCOUNT + 1+      \ advance to the next sound string
         REPEAT
         SILENT
         DROP ;
\ ========================================================
\ VDP byte string compiler
: ?BYTE ( n -- ) FF00 AND  ABORT" Not a byte" ;

: VBYTE ( -- )
         BEGIN  [CHAR] , PARSE-NAME DUP
         WHILE
            EVALUATE DUP ?BYTE
            VC,
         REPEAT
         2DROP ;

: /END   0 VC, 0 VC, ;   \ end the list with 2 bytes

\ ========================================================
\ VDP sound lists
HEX
VCREATE MUNCHMAN
       VBYTE 08,85,2A,90,A6,08,B0,CC,1F,12
       VBYTE 08,85,2A,90,A4,1C,B0,C9,0A,12
/END

VCREATE PACMAN
       VBYTE 06,86,0D,97,AC,1A,B7,08
       VBYTE 02,8F,08,02
       VBYTE 02,AB,23,05
       VBYTE 02,86,0D,04
       VBYTE 01,BF,03
       VBYTE 02,8E,0B,08
       VBYTE 02,8A,0A,02
       VBYTE 03,AC,1A,B7,08
/END

VCREATE NOKIA
       VBYTE 01,9F,20
       VBYTE 03,90,85,05,09
       VBYTE 02,8F,05,09
       VBYTE 02,87,09,12
       VBYTE 02,87,08,12
       VBYTE 02,85,06,09
       VBYTE 02,81,07,09
       VBYTE 02,8E,0B,12
       VBYTE 02,8A,0A,12
       VBYTE 02,81,07,09
       VBYTE 02,8F,07,09
       VBYTE 02,8A,0C,12
       VBYTE 02,8A,0A,12
       VBYTE 02,8F,07,24
       VBYTE 01,9F,00
/END

