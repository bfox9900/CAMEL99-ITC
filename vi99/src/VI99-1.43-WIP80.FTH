\ VI99.FTH  editor for TI-99 V 1.2 wip80

\ Sept 7, 2022 Brian Fox
\ VI99 concepts:
\ Use VI key mappings.
\ Use Forth interpreter
\ Commands created from key value
\ Read files into low ram
\ Edit text directly in VDP RAM (TI-99 screen)
\ Changes:
\ GOTO is the G command
\ goto the line & remember the address
\ ---------------------------------------------
\ *i – Insert at cursor (goes into insert mode)
\ *a – Write after cursor (goes into insert mode)
\ *A – Write at the end of line (goes into insert mode)
\ *ESC – Terminate insert mode
\ u – Undo last change
\ U – Undo all changes to the entire line
\ *o – Open a new line (goes into insert mode)
\ dd – Delete line
\ 3dd – Delete 3 lines.
\ D – Delete contents of line after the cursor
\ C – Delete contents of a line after the cursor and insert new text.
\     Press ESC key to end insertion.
\ dw – Delete word
\ 4dw – Delete 4 words
\ cw – Change word
\ x – Delete character at the cursor
\ r – Replace character
\ R – Overwrite characters from cursor onward
\ s – Substitute one character under cursor continue to insert
\ S – Substitute entire line and begin to insert at the beginning of the line
\ ~ – Change case of individual character

NEEDS WORDLIST   FROM DSK1.WORDLISTS
ONLY FORTH DEFINITIONS
\ NEEDS DUMP       FROM DSK1.TOOLS
NEEDS READ-LINE  FROM DSK1.ANSFILES
NEEDS #1         FROM DSK4.HEAPSTRINGS
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
: BETWEEN  ( n lo hi -- ?) 1+ WITHIN ;
: CLIP     ( n lo hi -- n) ROT MIN MAX ;
: ERASE    ( addr len -- )  0 FILL ;
: BLANK    ( addr len -- )  BL FILL ;
: VBLANK   ( vaddr len -- ) BL VFILL ;
: VBLANKLN ( -- ) VPOS C/L@ VBLANK ;
: HLINE    ( col row -- ) >VPOS C/L@  [CHAR] __ VFILL ;
: .$       ( $ --) COUNT TYPE ;

\ RESERVE/RESTORE: cheap way to allocate dictionary space and return it
\ : RESERVE  ( n -- addr) HERE ALLOT ;
\ : RESTORE  ( n -- ) NEGATE ALLOT ;

\ letter case controls
HEX
: LOWER? ( c -- c') [CHAR] a [ CHAR z 1+ ] LITERAL WITHIN ;
: TOUPPER ( addr len -- addr len)
  2DUP BOUNDS
  ?DO
    I C@ DUP LOWER?
    IF 05F AND THEN I C!
  LOOP ;

DECIMAL
: --  ( addr -- ) \ Safe DEC a variable to zero
    DUP @ 1- 0 MAX  SWAP ! ;

: GETXY   ( -- x y ) VROW 2@ ;
: SAVECURS
  S" GETXY 2>R" EVALUATE ; IMMEDIATE

: RESTCURS
  S" 2R> AT-XY" EVALUATE ; IMMEDIATE

: PROMPT  ( -- ) 0 23 AT-XY VBLANKLN ;

: SCRLINE  ( -- Vaddr) VROW @ C/L@ * ;

: +PLACE  ( addr n $ -- ) \ append addr,n to counted string $
  2DUP 2>R  COUNT +  SWAP MOVE 2R> C+! ;

\ fix cursors and hi-lighter char for 40/80 column mode 
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

\ top 22 lines is the editor screen 
  C/SCR @ C/L@ 2* - CONSTANT SCRSIZE
  
  SCRSIZE C/L@ -    CONSTANT BOTTOMLINE 

\ clears top 22 lines ie: editing screen
: CLS  ( --) VTOP @ SCRSIZE VBLANK ;

: TEMP   HERE 100 + ;

: SCROLLDN ( line# --)
  C/L@ * DUP>R ( R: Vaddr )              \ address of video screen 
  SCRSIZE OVER -  TEMP SWAP VREAD  \ copy screen to temp buffer 
  TEMP R@ C/L@ +  SCRSIZE OVER - VWRITE
  R> C/L@ VBLANK ;  \ erase last line 

: SCROLLUP ( line# --)
  C/L@ * DUP>R  ( R: Vaddr )
  ( Vaddr) SCRSIZE OVER -  TEMP  SWAP VREAD
  TEMP  R> C/L@ -   SCRSIZE OVER - VWRITE
  BOTTOMLINE C/L@ VBLANK ;

: LIST  ( -- )
  TXTBUFFER TOPLINE @ NTH
  SAVECURS
  CLS  0 0 AT-XY
  22 0
  DO
    DUP         ( -- txtbuff txtbuff )
    COUNT DUP  
    IF    -TRAILING VPOS SWAP VWRITE 
    ELSE  [CHAR] ~ VPUT 2DROP 
    THEN  (CR) DROP 
    NEXT$       ( follow the link)
  LOOP 
  DROP
  RESTCURS ;

\ cursor movement controls
: TOPLINE+! ( n --) TOPLINE @ SWAP +  0 2000 CLIP  TOPLINE ! ;
: MOVESCR   ( n --) TOPLINE+! LIST ;

DECIMAL
: INS/DEL
  INSERTING @ -1 XOR INSERTING !
  INSERTING @
  IF    BAR CURSOR
  ELSE  uLINE CURSOR
  THEN ;

\ text on screen, "right of cursor" as a VDP stack string
: RIGHTSIDE ( -- VDPaddr len)
  SCRLINE C/L@  VCOL @ /STRING ;

\ =======================
\ text manipulation
: DELCHAR    ( -- )
  PAD C/L@ 2+ BLANK       \ init pad to all spaces  
  RIGHTSIDE TUCK 1 /STRING      \ cut off first character  
  PAD SWAP  VREAD         \ read shortened string to PAD buffer  
  PAD VPOS ROT VWRITE ;   \ write it back to screen 

: PUSHRIGHT ( -- )
  RIGHTSIDE TUCK         ( -- len Vaddr len )
  PAD SWAP VREAD              \ read VDP string into PAD buffer 
  BL VPUT                     \ write blank at cursor
  PAD VPOS 1+ ROT 1- VWRITE ; \ write buffer back to screen in new position 

DECIMAL
CREATE FILENAME  16 ALLOT

FILENAME OFF
: QUOTE  ( -- ) [CHAR] " (EMIT) ;
: "TYPE" ( addr len --) QUOTE VTYPE QUOTE ;

\ line# of the cursor in the _editor window_
: ELINE#  ( -- n ) TOPLINE @  VROW @  + ;

\ using VTYPE for faster refresh
: .LINES     LINES @ (.) VTYPE   S"  lines, " VTYPE ;
: .FSIZE     FSIZE   (.) VTYPE   S"  chars" VTYPE ;

: .FILE ( $ -- )
  FILENAME COUNT DUP 0=
  IF 2DROP S" new file"
  THEN PROMPT "TYPE" ;

: .FSTATS
  SAVECURS
  .FILE SPACE .LINES .FSIZE
  RESTCURS ;

\ ===[ "INSERT" MODE primitives ]===
: V$! ( Vaddr len addr -- )  2DUP C! 1+ SWAP VREAD ;

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
\ REMEMBER the line# and the address
: GOTOLN    ( ln# --)
  DUP LINE# !
  TXTBUFFER SWAP NTH 'ELINE ! ;

\ return buffer address of edit line
: ELINE$ ( -- Caddr) 'ELINE @ ;

: SCR$ ( -- Vaddr len)
  SCRLINE C/L@ V-TRAILING 1 MAX ;

: EOL ( V$ -- n) C/L@ V-TRAILING NIP ;

\ ========================
\ line stack for cut/paste
HEX
1000 CONSTANT STKBASE

DECIMAL
  C/L@ CONSTANT STKWIDTH
STKBASE STKWIDTH 100 * CONSTANT STKEND

CREATE LSTK  STKBASE ,
: LNPUSH   STKWIDTH LSTK +! ;
: LNPOP    STKWIDTH NEGATE LSTK +! ;

: VTOS$    ( Va) LSTK @ ;
: LDEPTH   ( -- n) VTOS$ STKBASE - STKWIDTH / ;
: CLR-COPY ( --)   STKBASE LSTK ! ; \ clear line-stack

: STKROOM?  (  -- ?) \ ?=true if bad
  VTOS$ STKWIDTH +  STKBASE STKEND 1+ WITHIN ;

\ open space for a string in HEAP
\ return the HEAP address
: MAKEROOM ( len line# -- addr)
  OVER 1+ HALLOT
  GOTOLN
  ELINE$ DUP>R ( len $ ) ( r: eline$)
  OVER R@ + 1+ ( len $ $+len+1 )
  HEAP R@ - 0 MAX  ( len $ $' size )
  MOVE R> ;

: LINES++   ELINE# LINES @ MAX LINES ! ;

\ store VDP string at addr in CPU RAM
: INSERTLN  ( Vaddr len ELINE# --)
  MAKEROOM  V$!    LINES 1+! ;

\ over a line from screen (VDP RAM) in txtbuffer 
: OVERWRITE ( len line# -- addr)
  GOTOLN
  ELINE$ DUP>R
  DUP NEXT$ SWAP
  2 PICK + 1+
  HEAP OVER - 0 MAX 2+ MOVE R> ;

: DELLN ( lnaddr-- len )
  DUP NEXT$ SWAP  ( $2 $1)
  DUP C@ 1+ DUP>R ( $2 $1 len)
  FSIZE SWAP -  MOVE
  R> ;

: DEALLOT ( n -- )
  HEAP OVER - C/L@ 2* ERASE
\ deallocate
  HEAP SWAP - TXTBUFFER MAX H ! ;

: DELETELN ( lnaddr -- n) DELLN  DEALLOT  LINES -- ;

: DEL-LINE# ( ln# --) GOTOLN ELINE$ DELETELN ;

: UPDATELN
  SCR$ DUP>R ELINE# OVERWRITE V$!
  R> HALLOT
;

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
  CLS  TXTBUFFER 8K PURGE
  FILENAME OFF  TOPLINE OFF ;

: ?DOT   ( $ len -- $ len) 
  2DUP  [CHAR] . SCAN NIP 0= ABORT" Missing '.'" ;

: GET-FILENAME  ( -- addr len)  PARSE-NAME ?DOT TOUPPER ;

: SAVE          ( -- )  FILENAME COUNT WRITE-FILE ;

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

DECIMAL
\ some handy macros 
: END
  POSTPONE EXIT
  POSTPONE THEN ; IMMEDIATE

: EXPECTED
  POSTPONE <> POSTPONE IF
  POSTPONE END ; IMMEDIATE

: PUSH$ ( -- ) \ push$ current line onto line stack 
  ELINE# GOTOLN
  LNPUSH 
  ELINE$ ( DUP) COUNT VTOS$ VPLACE 
 ;

\ Define formatted command words
: $$c-y   \ YANK line (copy to buffer )
  KEY [CHAR] y EXPECTED
  STKROOM? 0= IF  BEEP  END
  SAVECURS
  PUSH$
  LIST
  RESTCURS ;

: YANKS ( n --) 0 ?DO  PUSH$  LOOP ;

: DO-DELLN
  SAVECURS
  ELINE# DEL-LINE#
  LIST  
  RESTCURS ;

: $$c-d   \ delete line to buffer
  KEY [CHAR] d EXPECTED
  STKROOM? 0= IF BEEP END
  PUSH$  
  DO-DELLN ;

: $$c-D
  RIGHTSIDE VBLANK
  UPDATELN ;

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
: $$c-r
  INSERTING OFF
  uLINE CURSOR  GETKEY VPUT
  UPDATELN  ;

: $$c-x  DELCHAR UPDATELN ;

: /~ \ erase ~ if found
  SCRLINE VC@ [CHAR] ~ =
  IF BL SCRLINE VC!
     UPDATELN
  THEN ;

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
  CLR-COPY
  INSERTING ON  BAR CURSOR /~
  VCOL @ PUSHRIGHT EDITLN ;

: $$c-I
  CLR-COPY
  INSERTING ON  BAR CURSOR /~
  0 EDITLN ;

: OPEN-LINE 
  VROW @ SCROLLDN
  SCRLINE C/L@ ELINE# INSERTLN ;

: $$c-o \ open new line
  OPEN-LINE  $$c-I ;

\ VDP-to-VDP memory movement :)
: VDPTYPE ( Vaddr len )
  0 ?DO VCOUNT (EMIT) LOOP DROP ;

\ **IMPORTANT** 
\ Since the VDP screen is the buffer we only need to type the
\ vtos$ string on the screen and call UPDATELN 
: INSERT-AT ( row -- )
  VTOS$ VCOUNT SCRWIDTH MIN VDPTYPE
  LNPOP 
  UPDATELN
  VCOL OFF ;

: PASTELN
  SAVECURS
  OPEN-LINE 
  VROW @ INSERT-AT
  RESTCURS ;

: $$c-p \ paste all lines
  LDEPTH 0= IF  BEEP END
  LDEPTH 0 ?DO  PASTELN  LOOP ;

: $$c-R \ replace many chars
  INSERTING OFF
  uLINE CURSOR
  VCOL @ EDITLN ;

: $$c-r \ replace 1 char
  CURS @ >R
  uLINE CURSOR
  GETKEY EMIT UPDATELN
  R> CURSOR ;

\ append @ curs
: $$c-a   CLR-COPY  VCOL @ 1+!  $$c-R ;

\ append line
: $$c-A
  CLR-COPY
  INSERTING OFF
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
  CLR-COPY
  TOPLINE OFF
  0 22 HLINE
  LIST  0 0 AT-XY 
  'c MODE !

  BEGIN
    DKGRN/BLK SCREEN
    .FSTATS
    BOX CURSOR GETKEY
    CASE
       \ control keys
    ^ F OF  1SCR MOVESCR          ENDOF
    ^ B OF  1SCR NEGATE MOVESCR   ENDOF
    ^ D OF  1/2SCR MOVESCR        ENDOF
    ^ U OF  1/2SCR NEGATE MOVESCR ENDOF
    ^ L OF  LIST  0 22 HLINE      ENDOF
     ^M OF  NEWLINE               ENDOF
     BL OF  $$c-l                 ENDOF  ( Cursor right)
    ^ Q OF  CR CR ." Shell" ABORT ENDOF
        \ Commands:
          DUP HANDLER
    ENDCASE
  AGAIN ;

\ ========================
\ get current drive string
\ ========================
DECIMAL
24 USER 'R12

HEX
CODE 0SBO  ( -- ) 1D00 ,  NEXT, ENDCODE
CODE 0SBZ  ( -- ) 1E00 ,  NEXT, ENDCODE

\ : ?DISKS    4000 C@ AA <> IF 0SBZ TRUE ABORT" No disk" THEN ;

\ 83D0 CONSTANT DISKCARD
\ 83D2 CONSTANT DEVLIST
CREATE HOME$ 8 ALLOT

: GETDEV  (  --) \ HOME$ will contain "DSK1." 
  83D0 @ 'R12 !
  0SBO
  83D2 @ 4 + COUNT HOME$ PLACE
  0SBZ
  S" ." HOME$ +PLACE \ add the '.' char
;

\ ======================================
\ ===[ vi style user commands ]===
 VOCABULARY EDITOR
 ONLY FORTH ALSO EDITOR DEFINITIONS

: x   SAVE  uLINE CURSOR ABORT ;
: q   x  ABORT ;
: q!  uLINE CURSOR  CR ." Not saved"   ABORT ;

: w   GET-FILENAME DUP IF  FILENAME PLACE  THEN SAVE ;

: w!  w ;
: wq  x q ;

\ 123 G *MUST have space after no.
: G    ( n -- )
  1-  0 2000 CLIP TOPLINE !
  LIST  0 0 AT-XY   ;

: 1G     1 G ;
: $      LINES @  G ;

\ ==========================
\ Additional shell commands
\ ==========================
INCLUDE DSK4.VIDIR2
INCLUDE DSK4.VILS-L

\ ==========================
: ls     dir ;

: vi
  GET-FILENAME 2DUP FILENAME PLACE
  DUP 0=
  IF   2DROP NEW
  ELSE READ-FILE
  THEN EDIT ;

: MANPAGE ( -- addr len)
   HOME$ COUNT PAD PLACE
   S" VIMANPAGE" PAD +PLACE
   PAD COUNT ;

: help  MANPAGE READ-FILE EDIT ;

: //  EDIT ;

: bye    BYE ;
: cold   COLD ;
: clear  PAGE ;
: home=  GET-FILENAME HOME$ PLACE ;

ONLY FORTH DEFINITIONS
\ console with prompt for vi99
DECIMAL 
: prompt$  CR  HOME$ .$  ." $ " ;
: NEWQUIT 
           RP0 RP! L0 LP !
           SOURCE-ID OFF
           POSTPONE [
           BEGIN
            prompt$  TIB DUP 82 ACCEPT SPACE
            ( addr len) INTERPRET
            STATE @ 0= IF  ."  ok"  THEN 
           AGAIN ;

\ -----------------------
: VI99
  WARM 
  DECIMAL 
  INIT-WORDLISTS
  80COLS  DKGRN/BLK SCREEN
  NEW-CURSORS
  uLINE CURSOR
  ['] NEWQUIT ['] QUIT CELL+ !  \ patch quit 
  
  PAGE ." VI99 Command Shell 1.41 2022 Brian Fox"
  CR
  CR ." HOME$=" GETDEV HOME$ .$
  CR
  CR ." vi to start a new file"
  CR ." vi dsk1.myfile to edit myfile"
  CR ." dir -or- ls to see a directory if start DSK"
  CR ." Alternate usage:"
  CR ." ls dsk2."
  CR ." ls-l to see file attributes"
  CR
  CR ." help   to see the man page"
  CR ." clear  to clear the screen"
  CR ." path= DSK1. to change default path" 
  CR ." bye    to exit vi99"

  ONLY FORTH ALSO EDITOR DEFINITIONS
  ABORT ;

HERE SWAP - DECIMAL .

 LOCK
 INCLUDE DSK1.SAVESYS
 ' VI99 SAVESYS DSK4.VI9980

NEW-CURSORS
ALSO EDITOR
