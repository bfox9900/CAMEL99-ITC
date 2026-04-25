\ TEXTCTRL.FTH  poco editor text functions  FEB 2026 BJF

HEX
0D CONSTANT ^M  \ enter
0F CONSTANT ESC

DECIMAL
: PUTCURS   ROW/COL 2@ AT-XY ;
: CLIPPED  0 SCRWIDTH CLIP ;

: SOL+!     ( n -- ) SOL    @ +  CLIPPED      SOL ! ;
: CURPOS+!  ( n -- ) CURPOS @ +  CLIPPED   CURPOS ! ;

: LEN+! ( n Caddr -- ) DUP>R C@ + CLIPPED R> C! ;

\ =======================
\ text functions
DECIMAL
: RIGHTSIDE ( addr len -- addr' len') CURPOS @ /STRING 0 MAX ;
: LEFTSIDE  ( addr len -- addr len')  DROP CURPOS @ ;

: RETYPE.BUFFER ( --) AT-LINE  $EDIT-BUFFER DROP C/L@  FITTED VTYPE ;

\ Automate all this stuff
: EMIT2BUFFER ( c --)
   DUP (EMIT) 'CURSOR C!
   CURPOS @ SCRWIDTH =  \ at right edge of screen?
   IF   1 SOL+!         \ shift the start of line variable
   ELSE 1 CURPOS+!
   THEN  1 EDIT-BUFFER LEN+! \   CURPOS @ MAX  EDIT-BUFFER C!
   UPDATE
;

: PUSHRIGHT ( -- )
    1 EDIT-BUFFER LEN+!
\  source string  destination  len
    ( *MUST USE CMOVE> here * )
    $EDIT-BUFFER RIGHTSIDE -TRAILING  'CURSOR 1+  SWAP CMOVE>
    BL 'CURSOR C!
    UPDATE
;

: WRITE.CHAR ( c -- ) INSERT @ IF  PUSHRIGHT  THEN EMIT2BUFFER ;

: |MAX#LINES| ( n -- n') 0  LASTLINE 12 - CLIP ;
: LASTROW     ( -- n)  LASTLINE L/SCR MOD ;

: TOPLINE+!  ( n -- )
   TOPLINE @ +
   DUP LASTLINE > IF  ROW OFF THEN
   |MAX#LINES|  TOPLINE !
;

: TEMP   ( -- addr) PAD 128 + ; \ buffer in unallocated dictionary
: CLEARLN   C/L@ BL VFILL ;

: SCROLLDN ( line# --)
  C/L@ * DUP>R ( R: Vaddr )        \ address of video screen
  SCRSIZE OVER -  TEMP SWAP VREAD  \ copy screen to temp buffer
  TEMP R@ C/L@ +  SCRSIZE OVER - VWRITE
  R> CLEARLN ;

: SCROLLUP ( line# --)
  C/L@ * DUP>R  ( R: Vaddr )
  ( Vaddr) SCRSIZE OVER -  TEMP  SWAP VREAD \ screen->temp
  TEMP  R> C/L@ -   SCRSIZE OVER - VWRITE   \ temp->screen
  BOTTOMLINE CLEARLN ;
