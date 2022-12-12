\ VIBE80 Release 2.2
\ Copyright (c) 2001-2003 Samuel A. Falvo II
\ All Rights Reserved
\
\ Highly portable block editor -- works under nearly every ANS Forth
\ I can think of, and with only a single screenful of words, will
\ work under Pygmy and FS/Forth too.
\
\ USAGE: vibe ( n -- ) Edits block 'n'.  Sets SCR variable to 'n'.
\        ed ( -- ) From Pygmy.  Re-edits last edited block.
\
\
\ 2.1 -- Fixed stack overflow bugs; forgot to DROP in the non-default
\        key handlers.
\

\ 2.2 Ported to CAMEL99 Forth with Permission B. Fox 2019
\     Removed some character constants to save space.
\     Changed TYPE for VTYPE. Added CLIP.
\     Removed shadow block function
\     Added some block navigation commands

NEEDS DUMP   FROM DSK1.TOOLS
NEEDS 80COLS FROM DSK1.80COL
NEEDS RKEY   FROM DSK1.RKEY
NEEDS BLOCK  FROM DSK1.BLOCKS

HERE
( Editor Constants )
CHAR i  CONSTANT 'i   \ Insert mode
CHAR c  CONSTANT 'c   \ Command mode
\ camel99 values
DECIMAL
C/L@ CONSTANT LWIDTH
C/L@ CONSTANT WIDTH
 80  CONSTANT MAXBLKS

( Editor State )
 VARIABLE SCR       \ Current block
 VARIABLE X         \ Cursor X position 0..LWIDTH
 VARIABLE Y         \ Cursor Y position 0..15
 VARIABLE MODE      \ current mode: INSERT or command ( 'i OR 'c

\ CMDNAME the command string, is built, found and executed
CREATE CMDNAME    5 C,  CHAR $ C, CHAR $ C,  0 C, 0 C, 0 C,

( Editor Display )
 DECIMAL
: BLANKS      BL FILL ; \ BF add
: MODE.       LWIDTH 0 AT-XY MODE @ EMIT ;
: VTYPE       ( addr len -- ) TUCK  VPOS SWAP VWRITE   VCOL +! ;
: SCR.        0 0 AT-XY S" Block: " VTYPE  SCR @ . S"      " VTYPE ;
: HEADER      SCR. MODE. ;
: 8-S         S" --------" VTYPE ;
: WIDTH-S     8-S 8-S 8-S 8-S 8-S ;
: BORDER      SPACE WIDTH-S CR ;
: ROW         ( addr -- addr') DUP LWIDTH VTYPE  LWIDTH + ;   \ FAST
\ : ROW         ( addr -- addr') DUP LWIDTH TYPE  LWIDTH + ;  \ SLOW
: LINE        ROW CR ;
: 4LINES      LINE LINE LINE LINE ;
: 16LINES     SCR @ BLOCK 4LINES 4LINES 4LINES 4LINES DROP ;
: CARD        0 1 AT-XY BORDER 16LINES BORDER ;
: CURSOR      X @  Y @ 2+ AT-XY ;
: SCREEN      HEADER CARD CURSOR ;

( Editor State Control )
: INSERT      'i MODE ! ;
: REPLACE     [CHAR] r MODE ! ;
: CMD         'c MODE ! ;
: CLIP         ROT MIN MAX ;
: BOUNDED      ( addr n -- ) 0 MAXBLKS CLIP SWAP ! ;
: PREVBLOCK    SCR DUP @ 1- BOUNDED ;
: NEXTBLOCK    SCR DUP @ 1+ BOUNDED ;
\ : TOGGLESHADOW 1 SCR @ XOR SCR ! ;

( Editor Cursor Control )
: FLUSHLEFT     0 X ! ;
: BOUNDX        X @  0 LWIDTH CLIP X ! ;
: BOUNDY        Y @  0 15 CLIP Y ! ;
: BOUNDXY       BOUNDX BOUNDY ;
: LEFT          X 1-! BOUNDXY ;
: RIGHT         X 1+! BOUNDXY ;
: UP            Y 1-! BOUNDXY ;
: DOWN          Y 1+! BOUNDXY ;
\ : beep          7 EMIT ;
: NEXTLINE      Y @ 15 < IF FLUSHLEFT DOWN THEN ;
: NEXT          X @ LWIDTH = IF NEXTLINE EXIT THEN RIGHT ;

( Editor Insert/Replace Text )
: WIDTH*        6 LSHIFT ;  \  2* 2* 2* 2* 2* 2*
: WHERE         SCR @ BLOCK SWAP WIDTH* + SWAP + ;
: WH            X @ Y @ WHERE ;
: EOL           LWIDTH Y @ WHERE ;
: PLACE         WH C! UPDATE NEXT ;
: -EOL?         X @ LWIDTH < ;
: OPENR         WH DUP 1+ LWIDTH X @ - MOVE ;
: OPENRIGHT     -EOL? IF OPENR THEN ;
: INSERTING?    MODE @ 'i = ;
: CHR           INSERTING? IF OPENRIGHT THEN PLACE ;

( Editor Keyboard Handler CMDWORD encoding)
\ CMD name key: $ $ _ _ _
\                    | | |
\ 'c'=command mode --+ | |
\ 'i"=ins/repl mode    | |
\                      | |
\ Key code (hex#) -----+-+
\
\ Called with ( k -- ) where k is the ASCII key code.

( Editor COMMANDS: Quit, cursor, block, et. al. )
( Modified for Ti-99 keyboard )
: $$c51       DROP 0 20 AT-XY R> R> DROP >R ; \ Q -- quits main loop
: $$c30       DROP FLUSHLEFT ;         \ 0
: $$c69       DROP INSERT ;            \ i
: $$c49       DROP FLUSHLEFT INSERT ;  \ I
: $$c52       DROP REPLACE ;           \ R
: $$i0F       DROP CMD ;               \ (escape) GOTO command mode
: $$c68       DROP LEFT ;              \ h
: $$c6A       DROP DOWN ;              \ j
: $$c6B       DROP UP ;                \ k
: $$c6C       DROP RIGHT ;             \ l
: $$c5B       DROP PREVBLOCK ;         \ [
\ : $$c5C       DROP TOGGLESHADOW ;      \ \
: $$c5D       DROP NEXTBLOCK ;         \ ]

( Editor Backspace/Delete )
: PADDING     BL EOL C! UPDATE ;
: DEL         WH DUP 1+ SWAP LWIDTH X @ - MOVE ;
: DELETE      -EOL? IF DEL THEN PADDING ;
: BS          LEFT DELETE ;
: BACKSPACE   X @ 0 > IF BS THEN ;

( Editor Carriage Return )
: NEXTLN      EOL 1+ ;
: #CHRS       SCR @ BLOCK 1024 + NEXTLN - WIDTH - ;
: COPYDOWN    Y @ 14 < IF NEXTLN DUP WIDTH + #CHRS MOVE THEN ;
: BLANKDOWN   NEXTLN WIDTH BLANKS UPDATE ;
: SPLITDOWN   WH NEXTLN 2DUP SWAP - MOVE ;
: BLANKREST   WH NEXTLN OVER -  BLANKS ;
: OPENDOWN    COPYDOWN BLANKDOWN ;
: SPLITLINE   OPENDOWN SPLITDOWN BLANKREST ;
: RETRN       INSERTING? IF SPLITLINE THEN FLUSHLEFT NEXTLINE ;
: RETURN      Y @ 15 < IF RETRN THEN ;

( Editor Wipe Block )
: MSG         0 20 AT-XY ." Are you sure? (Y/N) " ;
: VALID?      DUP [CHAR] n = OVER [CHAR] y = OR ;
: UPPERCASE?  DUP [CHAR] a [CHAR] z 1+ WITHIN ;
: LOWERCASE   DUP UPPERCASE? IF BL XOR THEN ;
: VALIDKEY    BEGIN KEY LOWERCASE VALID? UNTIL ;
: CLRMSG      0 20 AT-XY WIDTH SPACES ;
: NO?         MSG VALIDKEY CLRMSG [CHAR] n = ;
: ?CONFIRM    NO? IF R> DROP THEN ;
: WIPE        ?CONFIRM SCR @ BLOCK 1024 BLANKS UPDATE 0 X ! 0 Y ! ;

( Editor Commands: backspace, delete, et. al. )
: $$i04       DROP DELETE ;                    \ CTRL-D
: $$i08       DROP BACKSPACE ;                 \ (bs)
\ : $$i7F       DROP BACKSPACE ;                 \ DEL -- for Unix
: $$i0D       DROP RETURN ;                    \ (cr)
: $$c5A       DROP WIPE ;                      \ Z
: $$c6F       DROP OPENDOWN DOWN $$c49 ;       \ o
: $$c4F       DROP OPENDOWN ;                  \ O
\ : $$i95       DROP X OFF  Y OFF  ;             \ PC "HOME" key

HEX
  0F CONSTANT $0F
  F0 CONSTANT $F0

: KEYBOARD    RKEY 7F AND ;  \ for TI-99 we need to mask upper bit

DECIMAL
: CMD?        MODE @ 'c = ;
: INS?        MODE @ 'i =   MODE @ [CHAR] r =  OR ;
: MODE!       INS? 'i AND CMD? 'c AND OR  CMDNAME 3 + C! ;
: >HEX        DUP 9 > IF 7 + THEN [CHAR] 0 + ;
: H!          DUP $F0 AND  4 RSHIFT >HEX  CMDNAME 4 + C! ;
: L!          $0F AND >HEX CMDNAME 5 + C! ;
: NAME!       MODE! H! L! ;
: NOMAPPING   DROP ['] BEEP CMD? AND   ['] CHR INS? AND  OR ;
: HANDLERWORD NAME! CMDNAME FIND 0= IF NOMAPPING THEN ;
: HANDLER     DUP HANDLERWORD EXECUTE ;
: ?BREAK      ?TERMINAL ABORT" *BREAK*" ;
: EDITOR      'c MODE !  BEGIN KEYBOARD HANDLER SCREEN ?BREAK AGAIN ;

\ BF commsnds
: VI      ( --)  PAGE SCREEN EDITOR ;
: VIBE    ( n -- ) SCR !  VI ;
: LIST    ( n -- ) SCR ! PAGE SCREEN 50 18 AT-XY ;
: >>      SCR @ 1+ LIST ;
: <<      SCR @ 1- LIST ;
: INDEX   ( from to -- )
  1+ SWAP ?DO  CR I 4 .R 2 SPACES I BLOCK 64 TYPE ?BREAK LOOP  ;

HERE SWAP - DECIMAL . .( bytes)
