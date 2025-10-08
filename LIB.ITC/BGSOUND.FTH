\ BACKGROUND TI sound list player in CAMEL99 Forth V2

NEEDS FORK  FROM DSK1.MTASK99

\ 1. This player uses a final '0' to mark the end of the sound data
\ 2. It turns off all sounds when the data is ended
\ 3. Uses the TMS9901 timer to control sound duration
\ 4. It can Queue up to 16 sound lists to play
\ 5. Player goes to sleep when sound Queue is empty
\ 6. TWO end user commands: BGPLAY  >SNDQ

\ ========================================================
\ sound list player

HEX
: SILENT ( --) 9F SND!  BF SND!  DF SND! FF SND! ;  \ turn off all sounds

: PLAY$ ( caddr -- )        \ play 1 sound string
        COUNT               \ -- addr len
        2DUP + C@  >R       \ get duration at end of string, Rpush
        BOUNDS              \ convert addr/len to end-addr. start-addr.
        DO  I C@ SND! LOOP  \ feed bytes to sound chip
        R> JIFFS ;          \ use the delay from Rstack

: PLAYLIST   ( addr -- )    \ play a TI sound list
         BEGIN
           DUP C@           \ read the string length byte
         WHILE ( <> 0)
            PAUSE
            DUP PLAY$       \ play a single string
            COUNT + 1+      \ advance to the next sound string
         REPEAT
         SILENT
         DROP ;             \ mom said always clean up after yourself

\ ========================================================
HEX
\ create a 16 cell fifo to feed the sound player
VARIABLE SHEAD
VARIABLE STAIL

CREATE SOUNDQ   20 CELLS ALLOT
\ circular Q access words
: Q+!    ( fifo -- n) DUP @ 2+ 1F AND DUP ROT ! ;
: Q@     ( fifo -- n) STAIL Q+! + @ ;      \ bump tail and fetch data
: Q!     ( n fifo --) SHEAD Q+! + ! ;      \ bump head and add to FIFO
: Q?     ( fifo -- ?) SHEAD @ STAIL @ <> ; \ is data ready?

\ BackgroundPlayer
: BGPLAYER ( -- )   \ play all lists in the Q then goto sleep
           BEGIN Q? 
           WHILE
              SOUNDQ Q@ PLAYLIST
           REPEAT
           SILENT
           MYSELF SLEEP
           PAUSE ;  \ hand-off to next task


\ === MULTI-TASKING SET-UP ===
INIT-MULTI

CREATE PLAYER USIZE ALLOT  PLAYER FORK

' BGPLAYER PLAYER ASSIGN

\ ===============================================
\ end user commands
\ Usage:  MUNCHMAN BGPLAY  PACMAN BGPLAY  BGPLAY
: >SNDQ  ( list -- ) SOUNDQ Q! ;
: PLAYQ   ( list -- ) PLAYER RESTART ;
: KILLQ  ( -- )      SHEAD @ STAIL ! ;

\ ===============================================
\ sound list examples
: ?BYTE ( c -- ) FF00 AND  ABORT" Not a byte" ;

CREATE NUMBUF  10 ALLOT

: BYTE ( -- )
         BEGIN
           [CHAR] , PARSE-WORD
           DUP
         WHILE
            EVALUATE  DUP ?BYTE  C,
         REPEAT
         2DROP ;

: /END   0 C,  ALIGN  ;   \ compile zero, force even memory boundary

\ HEX
\ CREATE MUNCHMAN
\       BYTE 08,85,2A,90,A6,08,B0,CC,1F,12
\       BYTE 08,85,2A,90,A4,1C,B0,C9,0A,12
\ /END
