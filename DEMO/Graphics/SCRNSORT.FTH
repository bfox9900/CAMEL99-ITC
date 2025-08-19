\ combsort.fth  taken from byte April 1991.  coded bfox Sept 94
\ PORTED to CAMEL99 2017 for demo in screen

INCLUDE DSK1.GRAFIX
INCLUDE DSK1.CASE 

VARIABLE GAP
VARIABLE ITEMS
VARIABLE ADR
VARIABLE SFLAG
VARIABLE PASSES
VARIABLE SWAPS

DECIMAL

C/L @ 8 * CONSTANT SIZE \ we will use top 7 lines of screen as the array

: COLORSET  17 0  DO  I 16 +   2  I 2 +  COLOR LOOP ;
: .CHARSET    PAGE  255 0 DO I EMIT LOOP ;
: ?   @ . ;

: .REPORT
   CR  
   CR ." Done in " PASSES ? ." passes"
   CR SWAPS ? ."  exchanges"  ;

: ]Q  ( n -- adr)   ; \ the screen is the array we will sort in VDP memory

: /1.3 ( N -- N )   10 13 */  1 MAX  ;

: 1+!  ( n addr -- ) 1 SWAP +! ;

: XCHGS  ( adr adr -- ) OVER VC@  OVER VC@  SWAP ROT VC!  SWAP VC! ;

: COMBSORT ( n -- )
   CR 
   CR ." Descending COMB sort..."
    SIZE DUP ITEMS ! GAP !
    PASSES OFF
    SWAPS OFF
    BEGIN
        GAP @  /1.3  GAP !                 \ additional line
        SFLAG ON
        ITEMS @  GAP @ -  0
        DO
           I GAP @ + ]Q VC@ I ]Q VC@ >
           IF
              I GAP @ + ]Q  I ]Q XCHGS
              SFLAG OFF
              SWAPS 1+!
           THEN
        LOOP
        PASSES 1+!
       SFLAG @  GAP @ 1 = AND            \ additional conditional
   UNTIL
   .REPORT ;

: SHELLSORT ( n -- )
   CR 
   CR ." Shell sort... "
    SIZE DUP ITEMS ! GAP !
    PASSES OFF
    SWAPS OFF
    BEGIN
        GAP @  1- GAP !                  \ additional line
        SFLAG ON
        ITEMS @  GAP @ -  0
        DO
           I GAP @ + ]Q VC@   I ]Q VC@ >
           IF
              I GAP @ + ]Q   I ]Q  XCHGS
              SFLAG OFF
              SWAPS 1+!
           THEN
        LOOP
        PASSES 1+!
       SFLAG @  GAP @ 0=  AND            \ additional conditional
   UNTIL
   .REPORT ;

: BUBBLESORT ( n -- )
   CR 
    CR ." Descending BUBBLE sort..."
    SIZE DUP ITEMS ! GAP !
    PASSES OFF
    SWAPS OFF
    BEGIN
        SFLAG ON
        ITEMS @ 1-  0
        DO
           I 1+ ]Q VC@ I ]Q VC@ >
           IF
              I 1+ ]Q  I ]Q XCHGS
              SFLAG OFF
              SWAPS 1+!
           THEN
       LOOP
       PASSES 1+!
       SFLAG @
   UNTIL
   .REPORT ;
   
: BUBBLE_DEMO   .CHARSET BUBBLESORT ;
: SHELL_DEMO    .CHARSET SHELLSORT ;
: COMB_DEMO     .CHARSET COMBSORT ;

: MENU  
    CR
    CR ." 1  BUBBLE SORT"
    CR ." 2  SHELL SORT" 
    CR ." 3  COMB SORT"
    CR ." X  Return to Forth"
;

: DEMO 
   COLORSET
   BEGIN 
      PAGE ." ** SORT DEMONSTRATION ** "
      CR 
      CR ." This demo shows sorting"
      CR ." on the screen."
      CR 
      CR ." Choose from the menu" 
      MENU 
      KEY
      CASE 
         [CHAR] 1 OF  BUBBLE_DEMO   ENDOF 
         [CHAR] 2 OF  SHELL_DEMO   ENDOF 
         [CHAR] 3 OF  COMB_DEMO   ENDOF 
         [CHAR] X OF  CR CR ABORT   ENDOF 
                      HONK 
      ENDCASE 
      CR 
      CR ." Press a key for menu" KEY DROP 
       
   AGAIN 
;

