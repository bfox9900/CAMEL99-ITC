\ font2src.fth generates CALLCHAR statements FORTH & BASIC  Feb 1, 2023

INCLUDE DSK1.TOOLS 
INCLUDE DSK1.OUTFILE \ redefines TYPE EMIT  CR 
INCLUDE DSK1.UDOTR 

HEX 800 CONSTANT PDT 

DECIMAL 
: ]PDT  ( c-- Vaddr) 8* PDT + ;
\ character markup 
: <BL>    BL EMIT ;
: <">     [CHAR] " EMIT ;
: <\>     [CHAR] \ EMIT  <BL> ; 
: <S">    [CHAR] S EMIT  <">  <BL>  ;
: <(>     [CHAR] ( EMIT ;
: <)>     [CHAR] ) EMIT ;
: <,>     [CHAR] , EMIT ;

: V@++  ( Vaddr -- VAddr++, n) DUP V@  SWAP 2+  SWAP  ;
: .####  ( ) 
  BASE @ >R  HEX  0 <# # # # # #> TYPE  R> BASE !  ;

: .PATTERN ( char -- ) 
  ]PDT V@++ .#### V@++ .#### V@++ .#### V@++ .#### DROP ;

: FTH.PATTERN ( char -- )  
  CR <S"> DUP .PATTERN <"> <BL> DUP 3 .R  S"  CALLCHAR " TYPE <\>  EMIT  ;

: BASIC.PATTERN 
 CR  DUP 2000 + 4 .R  <BL> S" CALL CHAR" TYPE 
 <(> DUP 3 .R <,>  
 <"> .PATTERN <"> <)> ;

: FTH.FONT   ( 1st last --)
     1+ SWAP ?DO  I FTH.PATTERN  LOOP CR   ; 
: BASIC.FONT ( 1st last --) 
     1+ SWAP ?DO I BASIC.PATTERN  LOOP CR   ;

DECIMAL 

S" DSK7.FONT0230-S" MAKE-OUTPUT 
0 126 FTH.FONT 
CLOSE-OUTPUT 

S" DSK7.BASIC230-S" MAKE-OUTPUT 
0 126 BASIC.FONT 
CLOSE-OUTPUT 

