\ GAMELANG.FTH                       Brian Fox 2024
\ This file is extracted from the Oregon game. 
\ It provides some useful words for making games. 

\ VDP STRING and PRINT
\ compile stack string into VDP memory
: VS,     ( $adr len-- )  VHERE OVER CHAR+  VALLOT VPLACE ;

\ Print a VDP stack string
: VTYPE   ( vdp_addr len -- ) BOUNDS ?DO   I VC@ EMIT   LOOP ;

\ Compile a VDP string, that types itself.
\ ### Overides regular FORTH ." word ###
: ."   ( <text> )
        ?COMP                 \ for compiling only
\ Do these compile time actions "immediately"
        VHERE [CHAR] " PARSE VS,

\ later, when we run the word, do these things
        POSTPONE LITERAL
        POSTPONE VCOUNT
        POSTPONE VTYPE ; IMMEDIATE

\ Behaves like BASIC print statement. Compiles text in VDP RAM.
: PRINT."  POSTPONE CR  POSTPONE ." ; IMMEDIATE

\ Print a stack string centered on the screen
: CENTERTYPE  ( addr len -- ) DUP C/L@ SWAP - 2/ 1- SPACES TYPE ;

\ Compile text string and print on a newline centered on the screen
: CENTER."
        ?COMP
        POSTPONE CR
        POSTPONE S"
        POSTPONE CENTERTYPE ;  IMMEDIATE

\ =========================================
\ helpers for choice tables....
: CLIP     ( n lo hi -- n') ROT MIN MAX ;   \ clip input to lo/hi
: RANDOM   ( n -- )   1 OVER CLIP  RND ;    \ limit RND number to min(1)


\ =========================================
\ G A M E  L A N G U A G E

DECIMAL
\ compile addresses
: CHOICES,  ( addr... addr[n] n -- ) 0 ?DO  COMPILE, LOOP ;  

\ get a copy of 3rd item on the stack
: 3RD     ( a b c -- a b c a ) 2 PICK ; 

\ text game language extensions
: BETWEEN ( n lo hi -- ?) 1+ WITHIN ;

\ %CHANCE structure replaces IF for random events
\  50 %CHANCE:    PRINT." Something is moving in the bushes"
\      OTHERWISE  PRINT." It's all quiet here."
\  ;CHANCE

: %CHANCE:  ( n -- ? ) S" 100 RND > IF" EVALUATE ; IMMEDIATE
: OTHERWISE            POSTPONE ELSE ; IMMEDIATE
: ;CHANCE              POSTPONE THEN ; IMMEDIATE

\ syntax sugar
: ENDIF     POSTPONE THEN ; IMMEDIATE
: CHOICE:  :NONAME ;

