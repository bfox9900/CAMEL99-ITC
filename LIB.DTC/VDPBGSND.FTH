\ BACKGROUND VDP sound list player in CAMEL99 Forth V2

INCLUDE DSK1.MTASK99
INCLUDE DSK1.VDPMEM

.( ..)
\ Sound player features are:
\ 1. It can Queue up to 16 sound lists
\ 2. Sound lists are stored in VDP RAM
\ 3. Code includes VDP byte directive so lists as easy to code
\ 4. Player task goes to sleep when sound Queue is empty
\ 5. Uses the TMS9901 timer for sound duration
\ 6. Size: Multi-tasker, VDP memory manager, VDP byte compiler,
\    BG player adds 1218 bytes to the Forth dictionary
\ 7. >SNDQ command enqueues a sound list
\ 8. PLAYQ command plays whatever is the sound queue
\ 9. KILLQ command emptys the sound queue.
\    (playing sounds will continue until finished)

\ *** see VDPSNDS.FTH for sample sounds to play ***

\ ========================================================
\ sound list player
HEX
: SILENT ( --)  9F SND!  BF SND!  DF SND! FF SND! ;  \ turn off all sounds

\ convert a VDP counted string to a stack string
: VCOUNT    ( vdp$adr -- vdpadr len ) DUP 1+ SWAP VC@ ;

: PLAY$ ( $addr -- )         \ play 1 sound string, no time-sharing
        VCOUNT ( -- addr len)
        2DUP + VC@ -ROT      \ save duration at end of string
        BOUNDS               \ convert addr/len to end-addr, start-addr.
        DO  I VC@ SND! LOOP  \ feed bytes from VDP mem to sound chip
      ( dur) JIFFS ;         \ use saved duration. 1 jiff = 1/60 sec
                             \ JIFFS timer runs PAUSE while waiting

\ play a TI sound list
: PLAYLIST  ( list-addr -- )
         BEGIN
           DUP VC@           \ read the string length byte
         WHILE ( tos <> 0)
           PAUSE
           DUP PLAY$         \ play a single string
           VCOUNT + 1+       \ advance to the next sound string
         REPEAT
         SILENT
         DROP ;              \ mom said always clean up after yourself

\ ========================================================
\ create a fifo to feed the sound player
HEX
                 \    head   tail      data
                 \    ----   ----   --------------
CREATE FIFO ( -- addr)  0 ,    0 ,  20 CELLS ALLOT

\ name the address fields for maximum speed
FIFO           CONSTANT QHEAD
FIFO    CELL+  CONSTANT QTAIL
FIFO 2 CELLS + CONSTANT QDATA

\ circular indexer
\ : []++    ( fifo head|tail -- addr) DUP @ 2+ 1F AND DUP ROT ! + ;

\ CODE []++ ( fifo head|tail -- addr) \ compute next fifo location
\         *TOS R0  MOV,    \ DUP @
\          R0     INCT,    \ 2+
\          R0 1F  ANDI,    \ 1F AND
\          R0 *TOS MOV,    \ DUP ROT !
\          R0  TOS MOV,    \
\         *SP+ TOS A,      \ +
\          NEXT,
\          ENDCODE
.( ..)
\ machine code version of above assembler code
CODE []++  ( fifo head|tail -- addr)
         C014 , 05C0 , 0240 , 001F , 
         C500 , C100 , A136 , NEXT, 
ENDCODE

: Q@     ( fifo -- n) QTAIL []++  @ ;  \ bump tail and fetch data
: Q!     ( n fifo --) QHEAD []++  ! ;  \ bump head and store in FIFO

\ Background Player program
: BGPLAYER ( -- )  \ play all lists in the Q then goto sleep
           BEGIN
             FIFO 2@ <>  \ fetch,compare head & tail
           WHILE
             QDATA Q@ PLAYLIST
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
\ Usage:  MUNCHMAN >SNDQ PLAYQ
: >SNDQ   ( list -- ) QDATA Q! ;
: PLAYQ   ( list -- ) PLAYER RESTART ;
: KILLQ   ( -- )      QTAIL @ QHEAD ! ;
.( ..)
\ ===============================================
\ VDP list compiler
\ Lets us make sound lists like in assember
\ but the compile into VDP RAM
: ?BYTE ( n -- ) FF00 AND  ABORT" Not a byte" ;
: VBYTE ( -- )
         BEGIN
           [CHAR] , PARSE-WORD DUP
         WHILE
            EVALUATE DUP ?BYTE
            VC,
         REPEAT
         2DROP ;
.( ..)
: /VEND   0 VC, 0 VC, ;  \ compile zero

