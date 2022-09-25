\ VI99.FTH  editor for TI-99 V 1.2 wip80

\ ** WIP to allow 80 column editing on 40 column screen **

\ Sept 7, 2022 Brian Fox
\ VI99 concepts:
\ Use VI key mappings.
\ Use Forth interpreter
\ Commands created from key value
\ Read files into low ram
\ Edit text directly in VDP RAM
\ Change
\ GOTO is the G command
\ goto the line & remember the address

NEEDS WORDLIST   FROM DSK1.WORDLISTS
ONLY FORTH DEFINITIONS
\ NEEDS DUMP       FROM DSK1.TOOLS
NEEDS READ-LINE  FROM DSK1.ANSFILES
NEEDS #1         FROM DSK5.HEAPSTRINGS
NEEDS CASE       FROM DSK1.CASE
NEEDS RKEY       FROM DSK1.RKEY
NEEDS -TRAILING  FROM DSK1.TRAILING
NEEDS MOVE       FROM DSK1.MOVE
NEEDS MARKER     FROM DSK1.MARKER
NEEDS 80COLS     FROM DSK1.80COL

MARKER VI99

HERE

HEX
: ^ ( c -- ) \ compile ctrl char
  ?COMP  CHAR  1F AND
  POSTPONE LITERAL ; IMMEDIATE

DECIMAL
VARIABLE INSERTING
VARIABLE MODE
VARIABLE LINESTK
VARIABLE TOPLINE
VARIABLE LINE#   \ active line#
VARIABLE 'ELINE  \ address of line# in HEAP

C/L@ 1- CONSTANT SCRWIDTH

\ ========================
\ Helpers
: BETWEEN ( n lo hi -- ?) 1+ WITHIN ;
: CLIP   ( n lo hi -- n) ROT MIN MAX ;
: ERASE   ( addr len -- )  0 FILL ;
: BLANK   ( addr len -- )  BL FILL ;
: VBLANK  ( vaddr len -- ) BL VFILL ;
: VBLANKLN ( -- ) VPOS C/L@ VBLANK ;
: HLINE   ( col row -- )
  >VPOS C/L@  [CHAR] __ VFILL ;

: LOWER? ( c -- c')
  [CHAR] a [ CHAR z 1+ ] LITERAL
  WITHIN ;

HEX
: TOUPPER ( addr len -- addr len)
  2DUP BOUNDS
  ?DO
    I C@ DUP LOWER?
    IF 05F AND THEN I C!
  LOOP ;

DECIMAL
: --  ( addr ) \ Safe DEC to zero
     DUP @ 1- 0 MAX  SWAP ! ;

: GETXY   ( -- x y ) VROW 2@ ;
: SAVECURS
  S" GETXY 2>R" EVALUATE ; IMMEDIATE

: RESTCURS
  S" 2R> AT-XY" EVALUATE ; IMMEDIATE

: PROMPT  ( -- ) 0 23 AT-XY VBLANKLN ;

: SCRLINE  ( -- Vaddr) VROW @ C/L@ * ;

\ fix box cursor and hi-lighter char
HEX
CREATE PATTERNS
( solid) 00FF , FFFF , FFFF , FF00 ,
( bar)   7070 , 7070 , 7070 , 7070 ,
( box)   00FC , 8484 , 8484 , FC00 ,

: NEW-CURSORS
 PATTERNS 8E8 3 8* VWRITE ;

HEX
: CURSOR ( c --)  CURS ! ;
\ cursor characters
5F CONSTANT uLINE
1E CONSTANT BAR
1F CONSTANT BOX
1D CONSTANT SOLID

DECIMAL
\ fast screen write
: VTYPE ( $ len )
  DUP>R VPOS SWAP VWRITE R> VCOL +! ;

: HOME    0 0 AT-XY ;

\ top 22 lines
C/SCR @ C/L@ 2* - CONSTANT SCRSIZE

\ clears top 21 lines
: CLS  ( --) VTOP @ SCRSIZE VBLANK ;

: SCROLLDN ( line# --)
  C/L@ * DUP>R
  SCRSIZE OVER -  HERE SWAP VREAD
  HERE R@ C/L@ +
  SCRSIZE OVER - VWRITE
  R> C/L@ VBLANK
;

\ VARIABLE SOL  \ start of line

: LIST  ( -- )
  BUFFER TOPLINE @ NTH
  SAVECURS
  CLS HOME
  22 0
  DO
    DUP C@ 0=
    IF   [CHAR] ~ CPUT DROP
    ELSE DUP COUNT ( SOL @ /STRING SCRWIDTH MIN ) -TRAILING VTYPE
    THEN CR
    NEXT$
  LOOP
  DROP
  RESTCURS ;

\ cursor movement controls
: TOPLINE+! ( n --)
  TOPLINE @ SWAP +  0 2000 CLIP
  TOPLINE ! ;

: MOVESCR  ( n --) TOPLINE+! LIST ;

DECIMAL
: INS/DEL
  INSERTING @ -1 XOR INSERTING !
  INSERTING @
  IF    BAR CURSOR
  ELSE  uLINE CURSOR
  THEN ;

\ "right of cursor" as a stack string
: ROC  ( -- VDPaddr len)
  SCRLINE C/L@  VCOL @ /STRING ;

\ =======================
\ text manipulation
: DELCHAR    ( -- )
  PAD C/L@ 2+ BLANK
  ROC TUCK 1 /STRING
  PAD SWAP  VREAD
  PAD VPOS ROT VWRITE
;

: PUSHRIGHT ( -- )
  ROC TUCK
  PAD SWAP VREAD
  BL VPUT
  PAD VPOS 1+ ROT 1- VWRITE ;

DECIMAL
CREATE FILENAME  16 ALLOT

FILENAME OFF

: "TYPE" ( addr len --)
 [CHAR] " (EMIT)
 VTYPE
 [CHAR] " (EMIT) ;

\ line# of the cursor
: ELINE#  ( -- n )
  TOPLINE @  VROW @  + ;

\ using VTYPE for faster refresh
: .LINES
  LINES @ (.) VTYPE
  S"  lines, " VTYPE ;

: .FSIZE
  FSIZE (.) VTYPE
  S"  chars" VTYPE ;

: .FILE ( $ -- )
  FILENAME COUNT DUP 0=
  IF 2DROP S" new file"
  THEN PROMPT "TYPE" ;

: .FSTATS
  SAVECURS
  .FILE SPACE .LINES .FSIZE
  RESTCURS ;

\ ===[ "INSERT" MODE primitives ]===
: V$! ( Vaddr len addr -- )
  2DUP C! 1+ SWAP VREAD ;

\ -trailing for a VDP string
: V-TRAILING ( V$ len -- V$ len')
  1-
  BEGIN
     2DUP + VC@ BL =
  WHILE
     1-
  REPEAT
  1+ ;

\ seek to the address of the ELINE#
\ REMEMBER the address of the line
: GOTOLN    ( ln# --)
  DUP LINE# !
  BUFFER SWAP NTH 'ELINE ! ;

\ return buffer address of edit line
: ELINE$ ( ln# -- Caddr) 'ELINE @  ;

: SCR$ ( -- Vaddr len)
  SCRLINE C/L@ V-TRAILING 1 MAX ;

: EOL ( V$ -- n) C/L@ V-TRAILING NIP ;

\ ========================
\ line stack for cut/paste
HEX
1000 CONSTANT STKBASE

DECIMAL
  42 CONSTANT STKWIDTH
STKBASE STKWIDTH 50 * CONSTANT STKEND

CREATE LSTK  STKBASE ,

: VTOS$ ( Va) LSTK @ ;
: LDEPTH ( -- n)
  VTOS$ STKBASE - STKWIDTH / ;

: ROOM?  ( n -- ?) \ ?=true if bad
  VTOS$ OVER +
  STKBASE STKEND 1+ WITHIN ;

: VCOUNT ( v$ -- vaddr u)
  DUP 1+ SWAP VC@ ;

\ open space for a string in HEAP
\ return the HEAP address
: MAKEROOM ( len line# -- addr)
  OVER 1+ HALLOT
  GOTOLN
  ELINE$ DUP>R ( len $ ) ( r: eline$)
  OVER R@ + 1+ ( len $ $+len+1 )
  HEAP R@ - 0 MAX  ( len $ $' size )
  MOVE R> ;

: LINES++
  ELINE# LINES @ MAX LINES ! ;

\ store VDP string at addr in CPU RAM
: INSERTLN  ( Vaddr len ELINE# --)
  MAKEROOM  V$!
  LINES 1+! ;

: OVERWRITE ( len line# -- addr)
  GOTOLN
  ELINE$ DUP>R
  DUP NEXT$ SWAP
  2 PICK + 1+
  HEAP OVER - 0 MAX 2+
  MOVE R> ;

: DELLN ( lnaddr-- len )
  DUP NEXT$ SWAP ( $2 $1)
  DUP C@ 1+ DUP>R ( $2 $1 len)
  FSIZE SWAP -  MOVE
  R> ;

: DEALLOT ( n -- )
  HEAP OVER - C/L@ 2* ERASE
\ deallocate
  HEAP SWAP - BUFFER MAX H !
;

: DELETELN ( lnaddr -- n)
  DELLN  DEALLOT  LINES --
;

: DEL-LINE# ( ln# --)
  GOTOLN ELINE$ DELETELN ;

: UPDATELN
  SCR$ DUP>R ELINE# OVERWRITE V$!
  R> HALLOT
  LINES++ ;

\ text/screen color combos
HEX
\ 17 CONSTANT BLK/CYAN
\ E4 CONSTANT WHT/BLU
\ 21 CONSTANT MEDGRN/BLK
\ 31 CONSTANT LTGRN/BLK
C1 CONSTANT DKGRN/BLK
E1 CONSTANT GRAY/BLK

DECIMAL
: SCREEN  ( c -- ) 7 VWTR ;

: NEW
  CLS  BUFFER 8K PURGE
  FILENAME OFF  TOPLINE OFF ;

: GET-FILENAME ( -- addr len)
  PARSE-NAME TOUPPER ;

: SAVE      ( -- )
  FILENAME COUNT WRITE-FILE ;

\ ====================================

DECIMAL
13 CONSTANT ^M
15 CONSTANT <ESC>

HEX
: GETKEY ( -- c) RKEY 7F AND ;

\ Command mode KEY commands
\ Ideas from VIBE by Sam Falvo
\ Word name key:  $$ _ - _
\                    |   |
\ c = command mode --+   |
\ i = ins/repl mode      |
\                        |
\ ASCII code       ------+
\
\ Define formated command words
DECIMAL
: END
  POSTPONE EXIT
  POSTPONE THEN ; IMMEDIATE

: EXPECTED
  POSTPONE <> POSTPONE IF
  POSTPONE END ; IMMEDIATE

: DO-DELLN
  SAVECURS
  ELINE# DEL-LINE#
  LIST  RESTCURS ;

: $$c-d \ delete line
  KEY [CHAR] d EXPECTED
  DO-DELLN  ;

: YANK
  LSTK +! SAVECURS
  ELINE# GOTOLN
  ELINE$ DUP COUNT VTOS$ VPLACE
  DELETELN
  LIST RESTCURS ;

: $$c-y \ yank line
  KEY [CHAR] y EXPECTED
  LINES @ 0= IF BEEP END
  STKWIDTH ROOM? 0=
  IF DROP BEEP END
  YANK
;

\ command mode cursor control
: $$c-h \ Cleft
  VCOL -- ;

: $$c-k  \ CUP
  VROW DUP --
  @ 0= IF -1 MOVESCR THEN ;

: CDOWN
  VROW @ 1+ DUP 21 >
  IF 1 MOVESCR THEN 21 MIN VROW ! ;

: $$c-j
   ELINE# LINES @ 1- <
   IF CDOWN THEN ;

: NEWLINE  CDOWN  VCOL OFF ;

: $$c-l  \ CRGHT
  VCOL @ 1+ [ C/L@ 1- ] LITERAL MIN
  VCOL ! ;

: $$c-$  SCRLINE EOL VCOL ! ;
: $$c-0  VCOL OFF ;

: $$c-:
  SAVECURS
  PROMPT [CHAR] : EMIT
  PAD DUP C/L@ 2-  ACCEPT EVALUATE
  RESTCURS LIST ;

\ Replace single char
: $$c-r  INSERTING OFF
  uLINE CURSOR  GETKEY VPUT
  UPDATELN  ;

: $$c-x  DELCHAR UPDATELN ;

: /~ \ erase ~ if found
  SCRLINE VC@ [CHAR] ~ =
  IF BL SCRLINE VC! THEN ;

\ =====================
\ on screen line editor
\ =====================

DECIMAL
: EDITLN ( column -- )
  VCOL !
  GRAY/BLK SCREEN
  BEGIN
    /~
    GETKEY
    DUP BL [CHAR] ~ BETWEEN
    IF
      INSERTING @
      IF PUSHRIGHT THEN CPUT DROP
         VCOL @ C/L@ 2- MIN VCOL !

    ELSE
      CASE
       ^ C OF  DELCHAR          ENDOF
       ^ D OF  INS/DEL          ENDOF
       ^ H OF  $$c-h            ENDOF
        ^M OF UPDATELN NEWLINE  ENDOF
     <ESC> OF UPDATELN EXIT     ENDOF
        ( otherwise:) HONK
    ENDCASE
    THEN .FSTATS
  AGAIN
;

\ start editing commands
: $$c-i
  INSERTING ON  BAR CURSOR
  VCOL @ PUSHRIGHT EDITLN ;

: $$c-I
  INSERTING ON  BAR CURSOR
  0 EDITLN ;

: $$c-o \ open new line
  VROW @ SCROLLDN
  SCRLINE C/L@ ELINE# INSERTLN
  $$c-I ;

\ VDP-to-VDP memory movement :)
: VDPTYPE ( Vaddr len )
  0 ?DO VCOUNT (EMIT) LOOP DROP ;

: INSERT-AT ( row -- )
  SCROLLDN
  VTOS$ VCOUNT SCRWIDTH MIN VDPTYPE
  ( -n ) LSTK +!
  SCRLINE C/L@ ELINE# INSERTLN
  UPDATELN
  VCOL OFF ;

: $$c-p \ put line
  STKWIDTH NEGATE ROOM? 0=
  IF DROP BEEP END
  VROW @ INSERT-AT
;
: $$c-R INSERTING OFF
  uLINE CURSOR
  VCOL @ EDITLN ;

\ append @ curs
: $$c-a
  VCOL @ 1+! $$c-R ;

\ append line
: $$c-A INSERTING OFF
  uLINE CURSOR
  SCRLINE EOL EDITLN ;


\ ===========================
\ Editor Key Handler
HEX
     FF CONSTANT $FF
CHAR i  CONSTANT 'i   \ Insert mode
CHAR c  CONSTANT 'c   \ Command mode

'c MODE !
\ CMD$ is built dynamically
\ with ascii value
\ then found and executed
CREATE CMD$
5 C,
CHAR $ C, CHAR $ C, 'c C,
CHAR - C,  0 C,

DECIMAL
: CMD? ( --?) MODE @ 'c = ;
: INS? ( --?) MODE @ 'i = ;

: MODE! ( --)
  INS? 'i AND CMD? 'c AND OR
  CMD$ 3 + C! ;

: ASCII! ( c --) $FF AND CMD$ 5 + C! ;
: CMD!   ( -- )  MODE! ASCII! ;

\ ===================
\ command interpreter
\ ===================
: HANDLER ( k -- )
  CMD!
  CMD$ FIND 0=
  IF  DROP BEEP EXIT
  THEN EXECUTE ;

DECIMAL
21 CONSTANT 1SCR
11 CONSTANT 1/2SCR

\ ===[ VI Command Mode keys ]===

\ command to edit existing buffer
: EDIT ( -- )
  INSERTING ON
  STKBASE LSTK ! \ clr copy buffer
  TOPLINE OFF
  0 22 HLINE
  LIST  HOME
  'c MODE !
  BEGIN
    DKGRN/BLK SCREEN
    .FSTATS
    BOX CURSOR GETKEY
    CASE
       \ control keys
  ^ F OF  1SCR MOVESCR        ENDOF
  ^ B OF  1SCR NEGATE MOVESCR ENDOF
  ^ D OF  1/2SCR MOVESCR      ENDOF
  ^ U OF  1/2SCR NEGATE MOVESCR ENDOF
  ^ L OF  LIST  0 22 HLINE   ENDOF
  ^M OF  NEWLINE             ENDOF
  ^ Q OF  CR CR ." Shell" ABORT ENDOF
       \ Commands:
          DUP HANDLER
    ENDCASE
  AGAIN ;

\ ===[ vi style user commands ]===
 VOCABULARY EDITOR
 ONLY FORTH ALSO EDITOR DEFINITIONS
\ =================================================
 : x   SAVE  uLINE CURSOR ABORT ;
 : q   x  ABORT ;
 : q!   uLINE CURSOR  CR ." Not saved"
      ABORT ;

: w
  GET-FILENAME ( addr len)
  DUP IF  FILENAME PLACE THEN SAVE ;

: w!    w ;
: wq    x q ;

\ 123 G *MUST have space after no.
: G    ( n -- )
  1-  0 2000 CLIP TOPLINE !
  LIST HOME  ;

: 1G     1 G ;
: $      LINES @  G ;

INCLUDE DSK5.VIDIR2

: ls     dir ;

: vi
  GET-FILENAME 2DUP FILENAME PLACE
  DUP 0=
  IF   2DROP NEW
  ELSE READ-FILE
  THEN EDIT ;

: help  \ read man page
   w
   FILENAME COUNT PAD PLACE
   S" DSK1.VIMANPAGE" READ-FILE EDIT
;

: //  EDIT ;

: BYE    BYE ;
: COLD   COLD ;

HERE SWAP - DECIMAL .

\ -------------------------------------------------
ONLY FORTH DEFINITIONS

: VI99
  WARM INIT-WORDLISTS
  80COLS
  DKGRN/BLK SCREEN
  NEW-CURSORS
  uLINE CURSOR
  PAGE ." VI99 Command Shell 1.2"
  CR
  CR ." vi to start a new file"
  CR ." vi dsk1.myfile to edit myfile"
  CR ." dir -or- ls to see a directory"
  CR ." Usage: ls dsk1."
  CR ." BYE to exit"
  CR
  ONLY FORTH ALSO EDITOR DEFINITIONS
  ABORT ;

 LOCK
 INCLUDE DSK1.SAVESYS
 ' VI99 SAVESYS DSK4.VI9980

NEW-CURSORS
ALSO EDITOR
