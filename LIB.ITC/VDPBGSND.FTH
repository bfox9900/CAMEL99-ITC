\ BACKGROUND TI sound list player in CAMEL99 Forth V2.1

\ NEEDS MOV,   FROM DSK1.ASM9900
\ NEEDS DUMP   FROM DSK1.TOOLS
NEEDS FORK   FROM DSK1.MTASK99
NEEDS VCOUNT FROM DSK1.VDPMEM
HERE
\ 1. This player uses a final '0' to mark the end of the sound data
\ 2. It turns off all sounds when the data is ended
\ 3. Uses the TMS9901 timer to control sound duration
\ 4. It can Queue 20 sound lists to play
\ 5. Player puts itself to sleep when sound Queue is empty
\ 6. Three end user commands:  ( sound_list ) >SNDQ   PLAYQ  KILLQ

\ ========================================================
\ VDP byte string compiler
HEX
: ?BYTE ( n -- ) FF00 AND  ABORT" Not a byte" ;

: VBYTE ( -- )
         BEGIN
           [CHAR] , PARSE-WORD
           DUP
         WHILE
            EVALUATE  DUP ?BYTE  VC,
         REPEAT
         2DROP ;

: /VEND   0 VC, 0 VC, ;   \ end the list with 2 bytes

\ ========================================================
\ sound list player
HEX
: SILENT ( -- ) 9F SND!  BF SND!  DF SND! FF SND! ;

\ play 1 string with
: VPLAY$ ( VDP_sound_string -- )  \ play 1 sound string from VDP memory
       PAUSE                   \ give somebody else some time
       DUP VCOUNT + VC@  >R    \ get duration at end of string, Rpush
       VC@ 0 DO  8800 C@ SND! LOOP
       R> JIFFS ;              \ use the delay from Rstack (JIFF=1/60)

: VPLAYLIST   ( Vaddr -- )     \ play a TI sound list from VDP memory
         BEGIN DUP VC@ 
         WHILE                 \ while the length is not 0
            DUP VPLAY$         \ play a single string
            VCOUNT + 1+        \ advance to the next sound string
         REPEAT
         DROP
         SILENT
;

\ ========================================================
HEX
\ create a 20 cell fifo to feed the sound player
VARIABLE SHEAD
VARIABLE STAIL

CREATE SOUNDQ   20 CELLS ALLOT
\ circular Q access words
: Q+!    ( fifo -- n) DUP @ 2+ 1F AND DUP ROT ! ;
: Q@     ( fifo -- n) STAIL Q+! + @ ;      \ bump tail and fetch data
: Q!     ( n fifo --) SHEAD Q+! + ! ;      \ bump head and add to FIFO
: Q?     ( fifo -- ?) SHEAD @ STAIL @ <> ; \ is data ready?

\ Background Player Program
: BGPLAYER ( -- )  \ play all lists in the Q then goto sleep
           BEGIN 
           Q? WHILE
              SOUNDQ Q@ VPLAYLIST
           REPEAT
           MYSELF SLEEP
           PAUSE ;      \ hand-off to next task

\ === MULTI-TASKING SET-UP ===
INIT-MULTI

CREATE PLAYER   USIZE ALLOT  \ allocate memory for this task

PLAYER FORK   \ copy current task into PLAYER task, with new stacks

' BGPLAYER PLAYER ASSIGN  \ assign the program to run in the PLAYER

\ ===============================================
\ User commands:
\ Usage:  MUNCHMAN >SNDQ  PLAYQ   
: >SNDQ  ( list -- ) SOUNDQ Q! ;
: PLAYQ  ( list -- ) PLAYER RESTART ;
: KILLQ  ( -- )      PLAYER SLEEP  SILENT   SHEAD @ STAIL ! ;

HERE SWAP -  DECIMAL SPACE .  .( bytes)

HEX



