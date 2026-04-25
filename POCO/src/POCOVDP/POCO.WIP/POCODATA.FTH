\ POCODATA.FTH   data structures for POCO EDITOR Feb 2026 BJF

HEX
17 CONSTANT BLK/CYAN
C0 CONSTANT GRN/BLK
A0 CONSTANT YEL/BLK
E4 CONSTANT GRAY/BLUE
CREATE MYCOLOR GRAY/BLUE ,

DECIMAL
VARIABLE INSERT   \ insert/over-write flag
VARIABLE TOPLINE  \ topline that is listed on screen
\ VARIABLE CURPOS
VARIABLE updated   \ set to true when you change a buffer

CREATE ROW/COL  0 , 0 ,   \ holds screen position for editline as 2var
\ editor intenal coordinates
ROW/COL       CONSTANT ROW
ROW/COL CELL+ CONSTANT CURPOS

: UPDATE       updated ON ;
: #CHARSRIGHT  ( -- n) C/L@ CURPOS @ - 1+ ;
: ERASELN ( -- ) #CHARSRIGHT BL VFILL ;
: PROMPT: ( -- ) 0 23 AT-XY VPOS ERASELN ;

\             ** NAMING CONVENTION **
\  words with a leading '$' return a stack string
\
CREATE FILENAME  32 ALLOT
: $FILENAME ( -- addr len ) FILENAME COUNT ;

\ data structures
128 CONSTANT BUFFSIZE \ buffer is big to allow insertions
: HEAP ( -- addr)  S" H @" EVALUATE ; IMMEDIATE

\  VALUE EDIT-BUFFER \ allocated at start up
: EDIT-BUFFER ( -- addr) HEAP ; ( use un-allocated memory)

: $EDIT-BUFFER ( -- addr len) EDIT-BUFFER COUNT ;  \ access as a stack string

: 'TEXT  ( -- addr) EDIT-BUFFER 1+ ; \ skip the byte count

\ the LINE we are editing is the screen ROW + TOPLINE
: THELINE#  ( -- n ) ROW @ TOPLINE @ + ;
