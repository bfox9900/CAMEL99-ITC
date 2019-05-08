\ BACKGROUND VDP sound list player in CAMEL99 Forth V2

INCLUDE DSK1.MTASK99
INCLUDE DSK1.VDPMEM

.( ..)
\ Sound player features are:
\ 1. It can Queue up to 16 sound lists
\ 2. Sound lists are stored in VDP RAM
\ 3. Code includes VBYTE directive so lists are easy to code
\ 4. Player task goes to sleep when sound Queue is empty
\ 5. Uses the TMS9901 timer for sound duration
\ 6. Size: Multi-tasker, VDP memory manager, VDP byte compiler,
\    BG player adds 1218 bytes to the Forth dictionary
\ 7. >SNDQ command enqueues a sound list
\ 8. PLAYQ command plays whatever is the sound queue
\ 9. KILLQ command emptys the sound queue.
\    (playing sounds will continue until finished)

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
         BEGIN DUP VC@
         WHILE \ while the length is not 0
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
         BEGIN
            [CHAR] , PARSE-WORD DUP
         WHILE
            EVALUATE DUP ?BYTE VC,
         REPEAT
         2DROP ;

: /VEND   0 VC, 0 VC, ;   \ end the list with 2 bytes


.( ..)
\ ========================================================
HEX
\ create a 16 cell fifo to feed the sound player

\ fifo pointers
CREATE SHEAD 0 , 0 ,
SHEAD CELL+ CONSTANT STAIL   \ points to the second cell in SHEAD

CREATE SOUNDQ   20 CELLS ALLOT
\ circular Q access words
: Q+!    ( fifo -- n) DUP @ 2+ 1F AND DUP ROT ! ;
: Q@     ( fifo -- n) STAIL Q+! + @ ;      \ bump tail and fetch data
: Q!     ( n fifo --) SHEAD Q+! + ! ;      \ bump head and add to FIFO
: Q?     ( fifo -- ?) SHEAD @ STAIL @ <> ; \ is data ready?

\ Background Player program
: BGPLAYER ( -- )  \ play all lists in the Q then goto sleep
           BEGIN
             SHEAD 2@ <>  \ fetch,compare head & tail
           WHILE
             SOUNDQ Q@ VPLAYLIST
           REPEAT
           MYSELF SLEEP
           PAUSE ;       \ hand-off to next task

\ ===============================================
\ CREATE player task
INIT-MULTI

CREATE PLAYER  USIZE ALLOT    \ get memory for task
PLAYER FORK                   \ init the task
' BGPLAYER PLAYER ASSIGN      \ assign something to do

\ ===============================================
\ end user commands
\ Usage:  MUNCHMAN BGPLAY  PACMAN BGPLAY  BGPLAY
: >SNDQ  ( list -- ) SOUNDQ Q! ;
: PLAYQ   ( list -- ) PLAYER RESTART ;
: KILLQ  ( -- )      SHEAD @ STAIL ! ;
