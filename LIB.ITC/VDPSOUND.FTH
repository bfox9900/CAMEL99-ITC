\ TI sound list player using VDP RAM    CAMEL99 Forth V2
\ Jan 2022 Removed Jiffs timer, replaced with TICKS for V2.68
CR .( Depracated: Use DSK1.ISRSOUND)

\ INCLUDE DSK1.TOOLS
INCLUDE DSK1.VDPMEM

\ sound list player
HEX
: SILENT ( --)  9F SND!  BF SND!  DF SND! FF SND! ;  \ turn off all sounds

: VPLAY$ ( sound_string -- ) \ play 1 sound string from VDP memory
       VCOUNT                \ -- addr len
       2DUP + VC@  >R        \ get duration at end of string, Rpush
       BOUNDS                \ convert addr/len to end-addr. start-addr.
       DO  I VC@ SND! LOOP   \ feed bytes to sound chip
       R> 8* 2* MS ;         \ time units are 16mS

: VPLAYLIST   ( addr -- )    \ play a TI sound list
         BEGIN DUP VC@
         WHILE \ while the length is not 0
            PAUSE            \ give somebody else some time
            DUP VPLAY$       \ play a single string
            VCOUNT + 1+      \ advance to the next sound string
         REPEAT
         SILENT
         DROP ;

\ VDP byte string compiler
: ?BYTE ( n -- ) FF00 AND  ABORT" Not a byte" ;

: VBYTE ( -- )
         BEGIN  [CHAR] , PARSE-WORD DUP
         WHILE
            EVALUATE DUP ?BYTE
            VC,
         REPEAT
         2DROP ;

: /VEND   0 VC, 0 VC, ;   \ end the list with 2 bytes
