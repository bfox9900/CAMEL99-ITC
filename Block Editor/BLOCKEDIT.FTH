( simple block editor with few frills  Aug 2025 Brian Fox)
NEEDS DUMP      FROM DSK1.TOOLS
NEEDS BLOCK     FROM DSK1.BLOCKS
NEEDS 80COLS    FROM DSK1.80COL
NEEDS -TRAILING FROM DSK1.TRAILING
NEEDS CASE      FROM DSK1.CASE
NEEDS .R        FROM DSK1.UDOTR
NEEDS RKEY      FROM DSK1.RKEY
NEEDS VOCABULARY FROM DSK1.WORDLISTS

HERE
VOCABULARY EDITOR
ONLY FORTH ALSO EDITOR DEFINITIONS

 DECIMAL
       64 CONSTANT #64 \ 1 line of text has 64 bytes
 #64 16 * CONSTANT B/SCR
 #64 1-   CONSTANT WIDTH

: BETWEEN   1+ WITHIN ;
: BLANK     BL FILL ;

\ Editor begins
DECIMAL
  VARIABLE COL   \ index into the block
  VARIABLE ROW
  VARIABLE SOL   \ "start of line"

: COL!   ( n -- )   0 MAX  WIDTH MIN COL ! ;
: COL+!  ( n -- )   COL @ +  COL! ;

: ROW!   ( n -- ) 0 MAX  15 MIN  ROW ! ;
: ROW+!  ( n -- ) ROW @ +  ROW! ;

: LINE   ( n -- addr)  #64 * SCR @ BLOCK + ;

\ fitted allows us to handle 64 char lines on a 40 col screen
: FITTED ( addr n -- addr' n') SOL @ /STRING ;
: .LINE#  ( n --) 2 .R  [CHAR] | EMIT ;

\ Fast type to VDP with no scrolling
: VTYPE  ( addr len --) DUP>R  VPOS SWAP VWRITE  R> VCOL +! ;

: .LINE  ( addr -- addr') DUP #64 -TRAILING VTYPE  #64 + ;

: LIST   ( n --)
    SCR !
    0 LINE
    16 0 DO  I CR .LINE# .LINE  LOOP DROP ;

: .SCR#  ( n--) ." SCR #" DECIMAL SCR @ 3 U.R ;

: RELIST
    BASE @
    PAGE   DECIMAL .SCR# CR  SCR @ LIST
    BASE ! ;

: 'LINE     ( -- addr) ROW @ LINE ;
: 'CURSOR   ( -- addr) 'LINE COL @ + ;

\ cursor line as stack string, fixed width
: LINE$   ( -- addr len) 'LINE #64 ;

: 'EOT ( -- addr) LINE$ -TRAILING + ; \ end of text
: !CHAR   ( c -- ) 'CURSOR C!  UPDATE ;
: PUTCHAR ( c -- ) DUP !CHAR  1 COL+!  VPOS VC! ;

: /CHAR   ( addr n -- addr' n') 1 /STRING 0 MAX ;
: TAILEN    ( -- n)  #64 COL @ - ; \ bytes after cursor

: <SLIDELN ( -- ) 'CURSOR DUP>R TAILEN   /CHAR  R> SWAP CMOVE ;
: SLIDELN> ( -- )
   'CURSOR #64 -TRAILING 'CURSOR 1+ SWAP CMOVE> ;

: 'LASTLINE  ( addr ) 15 LINE ;
: BYTESBELOW ( addr -- n) 'LASTLINE #64 +  OVER - ;

: SLIDEUP
    'LINE DUP>R  BYTESBELOW  #64 /STRING  R> SWAP CMOVE
    'LASTLINE #64 BLANK  UPDATE ;

: SLIDEDN
    'LINE BYTESBELOW #64 - 'LINE #64 + SWAP CMOVE> ;

: CURSXY  ( -- x y)  COL @ 3 +  ROW @ 2+ ; \ translate to screen

DECIMAL
\ move editor cursor CURSOR to correct screen position
: ATCURS    CURSXY AT-XY ;
: HOME      COL OFF  ROW OFF ;
: RELINE    3 ROW @ 2+ AT-XY LINE$ TYPE ;

: RIGHTSIDE  ( -- addr len) LINE$  COL @ /STRING ;

: DELCHAR ( --)
  BL 'EOT 1- ( char addr )
  <SLIDELN
  C! UPDATE
  RIGHTSIDE VTYPE ;

: PRINTABLE?   32 127 BETWEEN ;

VARIABLE INSERT
30 CONSTANT BLKCURSOR
: TOGGLE-INSERT
    INSERT @  -1 XOR INSERT !
    INSERT @ IF [CHAR] _  ELSE BLKCURSOR THEN CURS ! ;

: WRITECHAR ( n -- )
  INSERT @ DUP>R ( copy the flag )
  IF  SLIDELN> THEN PUTCHAR
  R> IF ATCURS RIGHTSIDE VTYPE THEN ;

\ create copy stack in VDP RAM --------------
HEX
1000 CONSTANT STKBASE \ VDP pointer starts at >1000
2000 CONSTANT STKTOP
1000 VP +!  \ allocate the VDP space

DECIMAL
CREATE LNSTK  STKBASE , \ init pointer to stkbase

: /LINESTK    STKBASE  LNSTK ! ; \ reset
: LNSTK+!  LNSTK +! ;

: COPYBUFFER LNSTK @ ;
: PUSHLINE ( addr -- ) #64 LNSTK+!  COPYBUFFER #64 VWRITE ;
: POPLINE  ( addr -- ) COPYBUFFER SWAP #64 VREAD  -64 LNSTK+! ;
\ ------------------------------------------

\ cut copy paste 1 line using VDP RAM temp memory
: COPYLN   'LINE PUSHLINE ;

: CUTLN    COPYLN  LINE$ BLANK  UPDATE ;

: DELLIN        COPYLN SLIDEUP RELIST ;
: INSLIN        SLIDEDN  LINE$ BLANK UPDATE RELIST ;

: PASTELN ( paste as overwrite )
  LNSTK @ STKBASE = IF DROP BEEP   EXIT THEN
  'LINE POPLINE  UPDATE  RELINE ;

: INSERT-PASTE
  LNSTK @ STKBASE = IF  DROP BEEP   EXIT THEN
  SLIDEDN  PASTELN RELIST ;

: ?CLOSE  BHNDL @ IF CLOSE-BLOCKS THEN ;

\ user console commands
: CLEAR     ( n -- ) BLOCK B/BUF BLANK UPDATE ;
: >>   1 SCR +!  RELIST  HOME ; \ page up
: <<   SCR @ 1- 0 MAX SCR !  RELIST  HOME ; \ page down
: USE  ( <path> ) ?CLOSE  PARSE-NAME OPEN-BLOCKS ;
: UNDO ( -- ) EMPTY-BUFFERS ;

: PROMPT  0 19 AT-XY  VPOS #64  BL VFILL ;
: SAVE  PROMPT ." Saving.. "  PROMPT ;

DECIMAL
: CONTROLLER ( n -- )
  RKEY? DROP \ prevent random characters (DON'T KNOW WHY)
  CASE
      01 OF 8 COL+!                     ENDOF \ TAB
      02 OF >>                          ENDOF \ page down
      03 OF DELCHAR                     ENDOF \ DEL
      04 OF TOGGLE-INSERT               ENDOF \ Insert
\      05 OF                            ENDOF
      06 OF INSLIN                      ENDOF \ Fcnt 8
      07 OF DELLIN                      ENDOF \ Fcnt 3

      08 OF -1 COL+!                    ENDOF \ right arrow
      09 OF  1 COL+!                    ENDOF \ left arrow
      10 OF  1 ROW+!                    ENDOF \ down arrow
      11 OF -1 ROW+!                    ENDOF \ up arrow
      12 OF <<                          ENDOF \ page down
      13 OF 1 ROW+! COL OFF             ENDOF \ ENTER
     131 OF COPYLN                      ENDOF \ ^C
     144 OF PASTELN ( overwrite)        ENDOF \ ^P
     147 OF SAVE                       ENDOF \ ^S
     149 OF HOME                        ENDOF \ HOME
     150 OF INSERT-PASTE                ENDOF \ ^V
     152 OF CUTLN  RELINE               ENDOF \ ^X

      15 OF 0 18 AT-XY ." Forth> " QUIT ENDOF
  ENDCASE ;

: CLIP  ROT MIN MAX ;

\ adjust RKEY speed
: CURSOR-SPEED ( fast slow)
    20 50 CLIP SLOWKEY !
     2  5 CLIP FASTKEY !
;

: EDIT ( n -- )
      SCR !
      80COLS
      2 30 CURSOR-SPEED
      RELIST
      INSERT ON   TOGGLE-INSERT
      BEGIN
        PROMPT DEPTH . \ DEBUG line
        ATCURS RKEY
        DUP PRINTABLE?
        IF    WRITECHAR
        ELSE  CONTROLLER
        THEN
      AGAIN ;

: ED   SCR @ EDIT ;

HERE SWAP - DECIMAL . .( bytes)

: DEBUG
PAGE
HEX
CONTEXT 8 CELLS DUMP
CR ." 'latest = " LATEST U.
CR ."  Latest = " LATEST @ U.
CR ."  DP =     " DP     @ U.
CR ." ' EDITOR =" ' EDITOR 4 CELLS DUMP
;

ONLY FORTH DEFINITIONS
\ to make Forth system for block editing
\ lock the current dictionary for COLD boots
: LOCK    DP @ ORGDP !
          CONTEXT @ @ ORGLAST !
;

: COLD
    WARM
    ['] FIND12 'FIND !
    DEBUG
    ONLY FORTH DEFINITIONS ALSO EDITOR
    ORDER
    ABORT ;

ONLY FORTH DEFINITIONS ALSO EDITOR

LOCK

INCLUDE DSK1.SAVESYS


' COLD SAVESYS DSK7.BLKDEVSYS
