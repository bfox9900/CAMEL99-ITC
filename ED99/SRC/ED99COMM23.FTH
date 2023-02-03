\ ED99 editor common code for 80 col and 40 col version  Feb 2023 Brian Fox
\ CHANGES FOR v2.69 Oct 22.  Removed CMOVE, CMOVE>. Replaced with MOVE
\ FEB 2023: Changed ]RECORD divisor to use 51x80 lines per SAMS PAGE

\ NEEDS .S        FROM DSK1.TOOLS
NEEDS LOCK      FROM DSK1.MARKER
NEEDS CASE      FROM DSK1.CASE
NEEDS READ-LINE FROM DSK1.ANSFILES
NEEDS PAGED     FROM DSK1.SBLOCKS
NEEDS -TRAILING FROM DSK1.TRAILING
NEEDS VTYPE     FROM DSK1.VTYPE
NEEDS MARKER    FROM DSK1.MARKER
NEEDS COMPARE   FROM DSK1.COMPARE
NEEDS SEARCH    FROM DSK1.SEARCH
NEEDS VALUE     FROM DSK1.VALUES
NEEDS DEFER     FROM DSK1.DEFER
NEEDS LOAD-FONT FROM DSK1.LOADSAVE

\ utility commands
 NEEDS DIR      FROM DSK1.DIR
 NEEDS CAT      FROM DSK1.CATALOG
.( .)
HERE
CR .( ED99 Multi-file Editor V1.7 BFox 2022) CR
\ named colors for Graphics programs
: ENUM  ( 0 <text> -- n) DUP CONSTANT  1+ ;
0 ENUM TRANS   ENUM BLACK    ENUM GREEN    ENUM LTGRN
  ENUM BLUE    ENUM LTBLUE   ENUM RED      ENUM CYAN
  ENUM RED     ENUM LTRED    ENUM YEL      ENUM LTYEL
  ENUM DKGRN   ENUM MAGENTA  ENUM GRAY     ENUM WHITE
DROP
\ new constants and variables in HEAP memory
HEX
\  80 CONSTANT TOPBAR
  81 CONSTANT BOTBAR
1000 CONSTANT 4K
\ cursor characters
DECIMAL
29 CONSTANT ARROW
30 CONSTANT BAR
31 CONSTANT BOX

\ screen management & record constants
         C/L@ CONSTANT WIDTH   \ screen width. Detects 40/80 columns
    WIDTH 1- CONSTANT RMARGIN
          80 CONSTANT #80      \ length of text lines
          19 CONSTANT EL/SCR   \ editor lines per screen
EL/SCR 3 +   CONSTANT PY       \ prompt line y coordinate

         #80 CONSTANT RECSIZE  \ Change recsize to 80
4K 32 UM* RECSIZE UM/MOD NIP CONSTANT MAXLINES

VARIABLE INSERTING
VARIABLE LASTSRCH
\ color control variables
HEX
GRAY VALUE FG
BLUE VALUE BG

\ utility words
: GETXY   ( -- COL ROW)  VROW 2@ ;
HEX
CODE FILL16 ( adr len char) \ fills 2 bytes per interation
    C004 , 06C0 , E100 , C036 , 0580 ,
    0810 , C076 , CC44 , 0600 , 16FD ,
    C136 , NEXT,
ENDCODE

HEX
CODE MOVE16 ( src dst len -- ) \ Faster: moves len/2 CELLS
    C036 , C076 , C104 , 1306 , 0584 ,
    0244 , FFFE , CC31 , 0644 , 15FD ,
    C136 , NEXT,
ENDCODE

DECIMAL
: BLANK   ( adr len -- ) BL FILL16 ;
: BETWEEN ( n lo hi -- ? ) 1+ WITHIN ;
: CURSOR  ( char -- ) CURS ! ;
: ERASELN ( col row --) AT-XY  VPOS WIDTH BL VFILL ;
: CLIP    ( n n1 n2 -- n1..n2) ROT MIN MAX ;
.( .)
\ graphics helpers
HEX
 0800 CONSTANT PDT   \ "pattern descriptor table"
: ]PDT     ( char# -- 'pdt[n])  8* PDT + ;
: CHARDEF  ( addr char# --)  ]PDT 8 VWRITE ;
: COLORS   ( fg bg -- ) SWAP 4 LSHIFT SWAP +  7 VWTR ;
: FORTHCOLOR     1 7 COLORS ;

HEX
CREATE SGLN  0000 , 0000 , FF00 , 0000 ,
CREATE ABOX  FC84 , 8484 , 8484 , 84FC ,
CREATE AROW  1038 , 7C00 , 007C , 3810 ,  \ double arrow cursor
.( .)
HEX
: DEF-CHARS
     SGLN  BOTBAR CHARDEF
     ABOX    BOX  CHARDEF
     AROW  ARROW  CHARDEF ;

\ busy spinner ...
VARIABLE SPIN#
CREATE SCHARS   CHAR | C, CHAR / C, CHAR - C, CHAR \ C,
: SPINCHAR ( -- char ) SPIN# @ 1+ 3 AND DUP SPIN# ! SCHARS + C@ ;
: SPINNER  ( -- )  PAUSE  SPINCHAR GETXY >VPOS PAUSE VC! ;

DECIMAL
.( .)
\ local file data storage mechanisms
DECIMAL
\ pointers to memory in the HEAP
10 1+ CONSTANT #FILES  \ no. of files +1 that we can edit at once
CREATE FNAMES  #FILES 16 * ALLOT

: FILENAME ( -- caddr) SEG @  4 LSHIFT FNAMES + ;
\ EVARS can hold 10 different values. One for each SAMS segment
HEX
: EVAR: ( -- n+1 )
    CREATE   #FILES CELLS  ALLOT   \ allocated in high RAM
    DOES> SEG @ CELLS + ;

DECIMAL
 ( Editor variables )
 EVAR: LASTLINE
 EVAR: TOPLINE
 EVAR: SOL     \ start of line
 EVAR: EROW
 EVAR: ECOL
 EVAR: UPDT
 EVAR: PURGED
 EVAR: GAP     \ # of lines in the GAP-buffer

: INIT-LOCALS
      TOPLINE OFF   LASTLINE OFF
      SOL OFF       UPDT OFF
      EROW OFF      ECOL OFF   32 GAP !
      FILENAME 16 BLANK ;

: INIT-EVARS ( --)
      #FILES 0
      DO
         I SEG !
         INIT-LOCALS
         PURGED OFF
      LOOP
      1 SEG ! ;

: UPDATED   UPDT ON ;

\ normal variables
VARIABLE #CLIPS     \ no. of lines in the clipboard
VARIABLE BLK        \ LAST sams memory block selected

\ ===============================================
\ Record management system
\ EROW is screen row we are editing, TOPLINE is line in file
: REC#    ( -- n ) EROW @ TOPLINE @ + ;

\ Fast multipliers use SLA instruction
HEX
CODE 16*  ( n -- n')  0A44 ,  NEXT, ENDCODE  \ TOS 3 SLA
CODE 32*  ( n -- n')  0A54 ,  NEXT, ENDCODE  \ TOS 5 SLA

DECIMAL
: 1STBLK  ( -- n)  SEG @ 32* ;
<<<<<<< HEAD:ED99/SRC/ED99COMM23.FTH
\ ************************************************************************
\ changes needed for better use of SAMS page. 51 lines of 80 bytes each
               51 CONSTANT L/PAGE   \ text lines in one 4K SAMS memory page
 RECSIZE L/PAGE * CONSTANT B/PAGE   \ bytes per page used with 80 byte lines
\ ************************************************************************
=======
\ **************************************************************************
\ replace ]RECORD with this version
\ : ]RECORD ( n -- addr)  RECSIZE UM* B/PAGE UM/MOD 1STBLK + DUP BLK ! BLOCK + ;

>>>>>>> d9841d015bffac082faf452ad9d09e5d08c1faac:ED99/SRC/ED99COMM.FTH
: ]RECORD ( n -- addr)  RECSIZE UM* 4K UM/MOD 1STBLK + DUP BLK ! BLOCK + ;

: [REC#]RECORD  ( -- ) REC# ]RECORD ;
: ERASE-REC ( addr -- )  #80 BLANK ;
: COPY-REC  ( addr -- )  #80 MOVE16 ;

\ SCREEN formatting ...
DECIMAL
: .R    ( n n -- )
   >R DUP ABS 0 <# #S ROT SIGN #>  R> OVER - SPACES VTYPE ;

: .FILENAME  ( -- )
     0 0 AT-XY ." #"  SEG @ 2 .R ." | "
     VPOS 16 BL VFILL FILENAME COUNT VTYPE
     UPDT @ IF ." *"  THEN ;

: .LINE#     ( -- )
     RMARGIN 12 -  0 AT" Line "  REC# 3 .R  ." /" LASTLINE @ 4 .R ;

\ manually build a long string. DV80 files can't handle longer lines
DECIMAL
CREATE R$   82 ALLOT
S" 0----+----1----+----2----+----3----+----"  R$ PLACE
S" 4----+----5----+----6----+----7----+----"  R$ COUNT + SWAP MOVE
80 R$ C!  \ set the length to 80 bytes

: RULER$ ( -- caddr len)  R$ COUNT ;

: .TOPBAR  ( -- ) RULER$ SOL @ /STRING C/L@ MIN 0 1 >VPOS SWAP VWRITE ;
: .BOTBAR  ( -- ) 0 PY 1- >VPOS C/L@  BOTBAR VFILL ;
: .HEADER  ( -- ) .FILENAME  .LINE# .TOPBAR ;
: DRAW.SCR ( scr# -- )  PAGE  .HEADER  .BOTBAR ;

DECIMAL

: (PURGE) ( -- ) \ erase the current segment, 4K bytes at once
      32 0
       DO
         I 1STBLK + BLOCK  4K  BL FILL16 \ BLANK
         SPINNER
      LOOP \ reset file's variables
      INIT-LOCALS
      PURGED ON
      S" DSK1.UNTITLED" FILENAME PLACE
;
\ cursor management
DECIMAL
: SCRXY   ( -- ecol erow) ECOL @ EROW @ 2+ ;
: PUTCURS ( -- ) SCRXY  AT-XY  ; \ Editor's X,Y on vdp
: PROMPT: ( -- ) 0 PY ERASELN ;

: ?PURGE  ( -- ) PURGED @ 0= IF PROMPT: (PURGE) THEN  ;

: ?EOF.   ( VDPaddr rec# -- VDPaddr)
     LASTLINE @ 1+ =
     IF DUP >R   S"  <<EOF>>" R> SWAP VWRITE  THEN ;

: WRITELN ( VDPaddr CPUaddr -- VDPaddr) SOL @ + OVER WIDTH  VWRITE ;
: LIST ( -- )
     ?PURGE
     0 2 >VPOS ( -- VDPaddr )
     TOPLINE @ DUP EL/SCR +  SWAP
     DO
       ( VDPaddr ) I ]RECORD WRITELN
         I ?EOF.
        WIDTH +  ( -- VDPaddr' )
     LOOP
     DROP ;

DECIMAL
.( .)
: ?BREAK   ?TERMINAL IF  PROMPT: FATAL ABORT" *Break*"  THEN ;

DECIMAL
: LOADDV80 ( addr len -- )
     DV80 R/O OPEN-FILE ?FILERR >R
     TOPLINE OFF
     LASTLINE OFF
     BEGIN
        R@ EOF 0=
     WHILE
       PAD DUP 80 R@ READ-LINE ?FILERR ( -- pad len flag)
       DROP
       LASTLINE @ ]RECORD ( pad len record) SWAP MOVE
       SPINNER
       LASTLINE 1+!
       ?BREAK
     REPEAT
     DROP
     R> CLOSE-FILE ?FILERR ;

.( .)
\ save SAMS memory, remove trailing zeros
VARIABLE SH   \ save handle var is simpler inside DO/LOOP
: SAVEDV80  ( addr len -- )
     DUP 0= ABORT" SAVEDV80: len=0"
     DV80 W/O OPEN-FILE ?FILERR SH !
     LASTLINE @ 1+  0
     DO
        I ]RECORD #80 -TRAILING  1 MAX  SH @ WRITE-LINE ?FILERR
        SPINNER
        ?BREAK
     LOOP
     SH @ CLOSE-FILE ?FILERR ;
.( .)
: EDLINE    ( -- addr len ) [REC#]RECORD  #80 ;
: 'CURS     ( -- n ) ECOL @  SOL @  + ;          \ cursor pos. in record
: 'CHAR     ( --  adr ) [REC#]RECORD 'CURS + ;   \ address in SAMS block
: !CHAR     ( n -- )   'CHAR C!    ;
: 'EOL      ( -- adr )  EDLINE 1- + ;    \ End of Line address
: RIGHTSIDE ( -- addr len) EDLINE 'CURS  /STRING ;

: BREAK;    POSTPONE EXIT POSTPONE THEN ; IMMEDIATE

: RELINE    ( -- )
     RIGHTSIDE DROP        ( -- addr )
     SCRXY >VPOS           ( -- addr vdpaddr)
     WIDTH ECOL @ -        ( -- addr vdpaddr bytes-to-end)
     VWRITE  ;
.( .)
: |MARGINS|  ( n -- n')  0 WIDTH CLIP ;  \ 40 COLUMN verion
\ left/right text window scrolling
: SOL+!      ( n -- ) SOL  @ +  |MARGINS| SOL ! ; \ 40 col. version
: HORIZONTAL ( n -- ) SOL+! LIST ;  \ +n  slide right, -n slide left

: TOPLINE+!  ( n -- ) TOPLINE @ +   0 MAXLINES 15 - CLIP   TOPLINE ! ;
: LASTLINE!  ( -- ) LASTLINE @  REC# MAX  LASTLINE ! ;

\ decrement a variable, clip at zero
: DECR! ( n addr -- ) TUCK @ SWAP - 0 MAX SWAP ! ;

: LEFT  ( -- ) \ automatically scrolls screen if at limits
     ECOL 1 OVER DECR!
     @ 0=  IF -1 HORIZONTAL     THEN RELINE ;

: RIGHT ( -- )
     ECOL DUP 1+! @ RMARGIN >
     IF  1 HORIZONTAL
         RMARGIN ECOL !
     THEN RELINE ;

: AT-EOF?  ( -- ?) REC# LASTLINE @ = ;
: MEMFULL? ( -- ) LASTLINE @ MAXLINES = ;
: .MEMFULL ( -- ) PROMPT: ." Mem full" HONK  1000 MS ;

: (CURSDWN)
     MEMFULL? IF  .MEMFULL HONK BREAK;
     EROW @  [ EL/SCR 2- ] LITERAL >
     IF   1 TOPLINE+!
     ELSE EROW 1+!
     THEN LASTLINE!  ;

: CURSDWN ( -- ) (CURSDWN) LIST ;

: CURSUP ( -- )
      EROW  1 OVER DECR! @ 0=
      IF -1 TOPLINE+! LIST THEN ;

: -TAB  ( -- ) ECOL -8 HORIZONTAL LIST ;

: +TAB  ( -- )
     ECOL 8 OVER +!
     @ RMARGIN >
     IF  8 HORIZONTAL
         RMARGIN ECOL !
     THEN LIST ;

: LEN ( caddr n -- n) -TRAILING NIP ;

: TOSTART ( -- ) ECOL OFF  SOL OFF  LIST ;

\ this is complicated because we manage 2 cursor variables
\ ECOL and SOL (start of line)
: TOEND   ( -- )
     EDLINE LEN
     DUP RMARGIN <
     IF    |MARGINS| ECOL !

     ELSE  WIDTH SOL !    \ 40 column MODE
           ECOL OFF
           RIGHTSIDE LEN |MARGINS| ECOL !
     THEN LIST ;
.( .)
\ page movement
: PGUP  ( -- )
     TOPLINE @ 0=
     IF    EROW OFF
     ELSE -16 TOPLINE+!
     THEN LIST ;

DECIMAL
: PGDN  ( -- )
     REC# 8 +  LASTLINE @ >
     IF  HONK
     ELSE 16 TOPLINE+!
     THEN LIST ;

\ editor functions
DECIMAL
.( .)
: ASCII?  ( c -- ?) BL [CHAR] ~ BETWEEN ;

: WRITECHAR  ( c -- )
  DUP ASCII? 0= IF DROP  EXIT THEN
  DUP !CHAR VPUT  RIGHT UPDATED ;

: DELCHAR    ( -- )
     RIGHTSIDE  1 /STRING  \ get string right of cursor, cut leading char
     'CHAR SWAP 1+ MOVE    \ write buffer back to CURSOR position +1 space
     RELINE  UPDATED  ;

: PUSHRIGHT ( -- )
     RIGHTSIDE 'CHAR 1+ SWAP 1- MOVE \ write back at 'CHAR+1
     BL !CHAR                         \ blank at cursor position
     RELINE UPDATED ;

.( .)

: CLIPBRD ( -- n)  #CLIPS @ ;

: .CLIPS ( -- ) C/L@ 14 - PY AT-XY S" Clip board" VTYPE CLIPBRD  4 .R ;


: .MODE  ( -- )
     INSERTING @
     IF   BAR CURSOR  PROMPT: S" Inserting" VTYPE
     ELSE BOX CURSOR  PROMPT: S" Overwrite" VTYPE
     THEN ;

: .STATUS  ( -- )  .MODE .CLIPS  ;
: .REFRESH ( -- )  .FILENAME .LINE# .STATUS ;

: TOGGLE  ( -- ) INSERTING DUP DUP @ -1 XOR  SWAP ! .STATUS  ;

DECIMAL
: BSPACE  ( -- )
     LEFT
     INSERTING @
     IF    DELCHAR
     ELSE  BL DUP  !CHAR VPUT
     THEN ;

: ESCAPE  ( -- )
     FORTHCOLOR
     PROMPT: ." Command Mode  "
     [CHAR] _ CURSOR
     CR KEY? DROP QUIT ;
\ ======================================================
\ CLIPBOARD MANAGEMENT in a SEGMENT at top of SAMS memory
DECIMAL
\ clip board uses blocks 161..193
: ]CLIP    ( rec# -- addr) RECSIZE UM* 4K UM/MOD 161 + BLOCK + ;

: >CLIP ( rec-addr -- ) #CLIPS 1+!  #CLIPS @ ]CLIP #80 MOVE16 ;

: CLIP2LINE ( line# -- )
      #CLIPS @ ]CLIP [REC#]RECORD COPY-REC
      1 #CLIPS DECR! ;

\ =======================================================
\ Insertions and deletions...
: HEAP  ( -- addr) 2 BLOCK ;

HEX
: DEL-LINES  ( start #lines  -- ) \ delete offset lines from image
      PROMPT: ." Delete"
      LASTLINE @ 1+ ROT
      ?DO
         I OVER ( -- rec# n) + DUP ]RECORD  I ]RECORD COPY-REC
          ]RECORD ERASE-REC
         SPINNER
      LOOP
      REC# LASTLINE @ = IF CURSUP THEN
      LASTLINE @ 1+ ]RECORD ERASE-REC
      ( n) LASTLINE DECR!
      LIST  UPDATED ;

HEX
: YANK    ( -- )
         REC# ]RECORD >CLIP
         REC# 1 DEL-LINES  UPDATED ;

: DEL-CHAR    ( -- )
      EDLINE -TRAILING 0 MAX NIP \ blank l le?
      IF   DELCHAR
      ELSE KEY DROP   \ prevent accidental line removal
           REC# 1 DEL-LINES
      THEN UPDATED ;

: CLIPFULL? ( --?) CLIPBRD LASTLINE @ +  MAXLINES >  ;

: COPY-LINE ( -- )
      CLIPFULL? IF PROMPT: ." Clipboard full" HONK  BREAK;
       REC# ]RECORD >CLIP ;

\ copy entire file to clipstack
: COPYLINES (  last 1st  -- )
       PROMPT: ." Copying"
       ?DO   I ]RECORD >CLIP   LOOP  .CLIPS ;

HEX
: COPYALL   ( -- )
     CLIPFULL? IF HONK BREAK;
     LASTLINE @  0  COPYLINES  RELINE .CLIPS ;

DECIMAL
: INSERT-LINES ( n -- )
      REC# LASTLINE @
      ?DO
          I ]RECORD    OVER I + ]RECORD COPY-REC
          I ]RECORD ERASE-REC
         SPINNER
     -1 +LOOP
     UPDATED
    .CLIPS ;

DECIMAL
: NEW-LINE  ( -- )
      MEMFULL? IF HONK BREAK;
      1 INSERT-LINES
      LIST UPDATED ;

: PASTE-LINES ( n )
        DUP 0= IF DROP HONK  BREAK;
        TOPLINE @ >R
        DUP LASTLINE @ +  MAXLINES >
        IF PROMPT: ." Won't fit"  HONK  BREAK;

        PROMPT: ." Expand"  DUP INSERT-LINES
        PROMPT: ." Paste"
       ( n) 1+  1
        ?DO
           I ]CLIP  [REC#]RECORD COPY-REC
           TOPLINE 1+!  LASTLINE 1+!
           1 #CLIPS DECR!
           SPINNER
        LOOP
        R> TOPLINE !   TOSTART
        .CLIPS ;

: +FILE   ( -- ) SEG @ +  1 5 CLIP SEG ! DRAW.SCR LIST ;

: ENTER   ( -- )
      MEMFULL? IF .MEMFULL BREAK;
      ECOL @ 0=
      IF
         EDLINE   1 INSERT-LINES  BLANK
        (CURSDWN)
      ELSE
        (CURSDWN) 1 INSERT-LINES EDLINE BLANK
      THEN TOSTART   UPDATED  LIST
      LASTLINE 1+!
      DROP  ; \ *BUG* had to add this drop to prevent stack overflow.

\ =================================================================
\ Repeating KEY customized for ED99   V2 BFox 24JUL22
DECIMAL
VARIABLE OUTKEY     \ key buffer
VARIABLE OLDKEY     \ previous key buffer
CREATE   DLY  10 ,  \ initial delay
200 VALUE CSPEED    \ cursor speed can be changed in ED99CONFIG

HEX

: RKEY?  ( -- char)
    DLY @ >R    \ delay counter to rstack
    BEGIN
        R> 1- DUP>R        \ dec counter
    WHILE ( not expired)
        83C8 ON  83CA ON   \ clear key buffers
        CSPEED TICKS          \ sets the speed of the loop
        KEY? DUP OUTKEY !
        OLDKEY @ =         \ compare to oldkey
    WHILE ( key is same)
        2 DLY !  \ set fast repeats
    REPEAT
    0C DLY !     \ set initial delay
    THEN         \ end time expired loop
    R> DROP
    OUTKEY @
    DUP OLDKEY !
    OUTKEY OFF
;

: BLINK  ( char -- )
  TMR@ 1FFF > IF DROP  CURS @ THEN VPUT ;

: RKEY ( -- char)
  'CHAR C@ >R  \ Get & push character at cursor from the record
   BEGIN
      R@ BLINK
      RKEY? ?DUP
   UNTIL
   R> VPUT
;

\ reverse color characters
HEX
: INVERTFONT ( -- )
         0 ]PDT  HEAP  400 VREAD      \ copy to heap
         HEAP 400  BOUNDS             \ all ASCII chars
         DO
           I DUP C@ INVERT SWAP C!    \ invert char patterns
         LOOP
         HEAP  80 ]PDT  400 VWRITE ;  \ write back to upper charset

: NORMAL  ( addr len --) BOUNDS DO   I C@ 7F AND I C!   LOOP ;
: REVERSE ( addr len --) BOUNDS DO   I C@ 80 XOR I C!   LOOP ;
: HILITE  ( addr len --) BOUNDS DO   I C@ 80 OR  I C!   LOOP ;

HEX
0F CONSTANT <ESC>
VARIABLE LOWLINE
VARIABLE HILINE
: MARKERS  ( -- n n ) HILINE @ LOWLINE @ ;
: UN-MARK     ( -- ) MARKERS ?DO   I ]RECORD #80 NORMAL  LOOP ;

: MARK ( -- )
       REC# DUP LOWLINE !  1+ HILINE !
       EDLINE HILITE
       ARROW CURSOR
       BEGIN
        .LINE# LIST .STATUS
         PROMPT: ." Mark: Up/Down, ^C(copy),^X, Del, ESC"
         PUTCURS
         RKEY DUP <ESC> <>
       WHILE
          CASE
( Fnct X)   0A OF
                  CURSDWN
                  EDLINE REVERSE
                  REC# 1+ HILINE !
                                          ENDOF
( Fnct E)   0B OF
                  REC# LOWLINE @ >
                  IF
                    EDLINE REVERSE
                    CURSUP
                    REC# 1+ HILINE !
                  ELSE BEEP
                  THEN
                                         ENDOF

    ( ^C)   83 OF UN-MARK
                  MARKERS COPYLINES
                  LIST .STATUS            BREAK;

    ( ^X)   98 OF UN-MARK
                  MARKERS COPYLINES
                  LOWLINE @ DUP MARKERS -  DEL-LINES
                  TOPLINE !  EROW OFF
                  LIST .STATUS            BREAK;

  ( delete) 03 OF UN-MARK
                  LOWLINE @ DUP
                  MARKERS -  DEL-LINES
                  TOPLINE !  EROW OFF
                  LIST .STATUS            BREAK;
          ENDCASE
       REPEAT
       EDLINE NORMAL
       HILINE @ LOWLINE @ <> IF UN-MARK THEN
       LIST .STATUS
;

DEFER LOCATE \ stub word. Will be assigned a function later

.( .)
HEX
: KEYHANDLER ( char -- ) \ TI-99 BASIC key codes used
      CASE
         01 OF  +TAB                    ENDOF  \ TAB
         02 OF  PGDN      .LINE#        ENDOF  \ FCTN 6
         03 OF  DEL-CHAR                ENDOF  \ PC Delete / FCTN 1
         04 OF  TOGGLE .MODE            ENDOF  \ PC Insert / FCTN 2
         06 OF  NEW-LINE                ENDOF  \ FCTN 8
         07 OF  REC# 1 DEL-LINES        ENDOF  \ FCTN 3
         08 OF  LEFT                    ENDOF  \ FCTN S
         09 OF  RIGHT                   ENDOF  \ FCTN D
         0A OF  CURSDWN   .LINE#        ENDOF  \ FCTN X
         0B OF  CURSUP    .LINE#        ENDOF  \ FCNT E
         0C OF  PGUP      .LINE#        ENDOF  \ FCTN 4
         0D OF  ENTER .REFRESH          ENDOF  \ ENTER
         0F OF  ESCAPE                  ENDOF  \ Esc
         81 OF  COPYALL                 ENDOF  \ ^A
         83 OF  COPY-LINE .REFRESH      ENDOF  \ ^C
         84 OF  TOEND                   ENDOF  \ ^D
         86 OF  LASTSRCH @ LOCATE       ENDOF  \ ^F
         8D OF  MARK                    ENDOF  \ ^M
         93 OF  BSPACE                  ENDOF  \ ^backspace
         95 OF  TOSTART                 ENDOF  \ ^U / PC Home
         96 OF  CLIPBRD PASTE-LINES     ENDOF  \ ^V
         99 OF  YANK                    ENDOF  \ ^Y
         9B OF  1 +FILE .FILENAME       ENDOF  \ ^>
         B7 OF -TAB                     ENDOF  \ ^TAB
         80 OF -1 +FILE  .FILENAME      ENDOF  \ ^<
                 HONK
      ENDCASE
      RKEY? DROP   \ prevent accidental random chars
;

.( .) \ file control primitives
DECIMAL
: .LINES ( -- ) CR LASTLINE @  DECIMAL . ."  lines" ;

: (SAVE) ( -- )
        UPDT @ IF  FILENAME COUNT SAVEDV80 .LINES   UPDT OFF   THEN ;
.( .)
: ?PATH  ( addr len -- addr len)
        2DUP [CHAR] . SCAN NIP 0= ABORT" File path expected" ;

DECIMAL
: SETUP  ( -- )
    DEF-CHARS
    FG BG COLORS  DRAW.SCR
    BOX CURSOR ;

: (EDIT) ( -- )
    DECIMAL
    SETUP
    INSERTING ON  TOGGLE
    LIST
    RKEY? DROP    \ prevent accidental CR into file
    BEGIN
        .HEADER .STATUS
\       PROMPT: DEPTH .  ( debug line )
        PUTCURS
        RKEY DUP ASCII?
        IF
            INSERTING @ IF PUSHRIGHT THEN WRITECHAR
        ELSE
            KEYHANDLER
        THEN
    AGAIN ;

DECIMAL
\ User commands
: GET ( <dsk*.path> )  \ parse for file name and load if found
        BL PARSE-WORD DUP
        IF ( filename) ?PATH
            ." Loading" (PURGE)
            2DUP FILENAME PLACE
            LOADDV80
       ELSE 2DROP   THEN ;

: EDIT   ( -- ) GET (EDIT) ;
: GO     ( line# --) EROW OFF  0 LASTLINE @ CLIP TOPLINE ! (EDIT) ;
: FILE   ( file# --) SEGMENT DRAW.SCR LIST ESCAPE ;
: >>     ( -- )  1 +FILE ESCAPE ;
: <<     ( -- ) -1 +FILE ESCAPE ;
: SAVEAS ( -- ) BL PARSE-WORD ?PATH  FILENAME PLACE UPDATED (SAVE) ;
: SAVE   ( -- ) BL PARSE-WORD NIP 0> ABORT" Use SAVEAS command" (SAVE) ;
: PURGE  ( -- ) (PURGE)  DRAW.SCR PROMPT: ." Ready" ;
: PRINT  ( <device> ) BL PARSE-WORD SAVEDV80 ;

: PURGEALL CR ." Purging "
        CR 6 1
        DO
           I DUP . SEGMENT (PURGE)
        LOOP
        1 SEGMENT ;

: SAVEALL  CR ." Saving changed files "
        SEG @
        CR
        11 1 DO
            I SEGMENT
            UPDT @ IF  I DUP . (SAVE)  THEN
        LOOP
        SEG @ SEGMENT ;

\ LOCATE utility .................
DECIMAL
CREATE SRCH$  40 ALLOT  \ buffer holds the search string

: ECOL! ( col --)   \ set column with correct start-of-line
    DUP C/L@ >      \ are we off screen?
    IF  C/L@ SOL !  \ set SOL variable
        C/L@ -      \ subtract screen width from column on stack
    THEN ECOL ! ;

: LOC+ ( n -- line#)
    PROMPT: ." Locating: " SRCH$ COUNT TYPE
    TRUE       \ -1 is the NOT found flag
    LASTLINE @ 1+  ROT
    ?DO
        I ]RECORD #80 -TRAILING 1 MAX 1+
        2DUP ( -- rec len rec len)
        SRCH$ COUNT SEARCH       ( -- adr len adr len $ len ? )
        IF ( -- adr len  adr len  $ len)
            NIP - NIP  ( -- col ) ECOL!
            DROP                  \ remove the true flag
            I DUP  1+ LASTSRCH !  \ save in the LASTSRCH variable
            ( -- rec# )           \ REC# copy returned on dstack
            LEAVE
        ELSE
            2DROP 2DROP ( -- )
            SPINNER
        THEN
        ?TERMINAL ABORT" Search stopped"
    LOOP
    DUP 0< ABORT" Can't find it"
    GO
;

' LOC+ IS LOCATE    \ assign this routine to LOCATE

\ USER command
: LOC ( <text> -- rec# ecol)
        ECOL OFF    \ reset editor variable
        1 PARSE SRCH$ PLACE     REC# LOCATE ;
