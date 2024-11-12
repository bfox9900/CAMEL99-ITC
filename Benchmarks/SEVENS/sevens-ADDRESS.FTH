\ literal translation of BASIC program to Forth 
\ V1 using variables and ARRAY:  1:10 
\ V2 replaced variables with VALUES: 1:08
\ V3 print with address loop, not indices

\ T= 1:01.16

NEEDS DUMP FROM  DSK1.TOOLS 
NEEDS ELAPSE FROM DSK1.ELAPSE 
NEEDS ARRAY  FROM DSK1.ARRAYS 
NEEDS VALUE FROM DSK1.VALUES 


DECIMAL 
: ?BREAK   ?TERMINAL ABORT" *BREAK*" ; 
\ .......................................................
\ SCROLL entire screen in one block with VMBR and VMBW
 : SCROLL ( -- )
  HERE 100 + DUP>R  VTOP @  ( --  buffer dst) ( r: BUFFER)
  DUP C/L@ + R>             ( -- buffer dst src buffer)  
  [ C/SCR @ C/L @ - ] LITERAL DUP>R VREAD  R> VWRITE 
  0 23 2DUP >VPOS C/L@ BL VFILL  \ erase bottom line
  AT-XY ;                        \ set cursor  

\ this code is the same as the kernel, but with faster scroll 
: CR     (  -- ) VCOL OFF  VROW ++@  L/SCR = IF SCROLL THEN ;
: (EMIT) ( char -- ) VPOS VC!  VCOL ++@ C/L@ = IF CR THEN ;
\ .......................................................

\ define all data before use
0 VALUE WIN 
0 VALUE POWER 
0 VALUE NUMLEN 
0 VALUE CARRY 
0 VALUE INAROW 
0 VALUE NDX   ( transfers loop index out of DO LOOP )

 256 CARRAY ]A                  \ 100 DIM A(256)
  0 ]A 256 0 FILL               \ init ]A to zero. Not automatic in Forth 

: RUN 
  CR ." 7's Problem "           \ 110 PRINT "7's Problem"
  7 0 ]A C!                     \ 120 A(1)=7
  0 TO WIN                      \ 130 WIN=0
  1 TO POWER                    \ 140 POWER=1
  0 TO NUMLEN                   \ 150 NUMLEN=1
  BEGIN 
     1 +TO POWER                \ 160 POWER=POWER+1
    ." 7 ^" POWER . ." IS:"   \ 170 PRINT "7 ^";POWER;"IS:"
    ?BREAK 
    0 TO CARRY                  \ 180 CARRY=0
    0 TO INAROW                 \ 190 INAROW=0

\ change: use addresses rather than indices    
    NUMLEN 1+ ]A  0 ]A          \ 200 FOR I=1 TO NUMLEN
    DO    
        I 0 ]A -  TO NDX        \ copy I for later 
        I C@ 7 *  CARRY +       \ 210 A(I)=A(I)*7+CARRY
\ We avoid some math with divide & mod
        0 10 UM/MOD TO CARRY    \ 220 CARRY=INT(A(I)/10)
        I C!                    \ 230 A(I)=A(I)-CARRY*10
        I C@ 7 =                \ 240 IF A(I)<>7 THEN 290
        IF     
            1 +TO INAROW        \ 250 INAROW=INAROW+1
            INAROW 6 =          \ 260 IF INAROW<>6 THEN 300
            IF                
              TRUE TO WIN       \ 270 WIN=1
            THEN                
        ELSE                    \ 280 GOTO 300 
            0 TO INAROW         \ 290 INAROW=0
        THEN 
    LOOP                        \ 300 NEXT I

    CARRY
    DUP NDX 1+ ]A C!            \ 310 A(I)=CARRY
    IF                          \ 320 IF CARRY=0 THEN 340
       1 +TO NUMLEN             \ 330 NUMLEN=NUMLEN+1
    THEN 
\ changed to use addresses not indices. Saves 2 seconds    
    CR                          \ replaces PRINT 
    0 ]A  NUMLEN ]A             \ 340 FOR I=NUMLEN TO 1 
    DO   
\       I C@ >DIGIT CEMIT        \ for TTY Forth 
       I C@ >DIGIT (EMIT)        \ 350 PRINT CHR$(A(I)+48);
    -1 +LOOP                    \ 360 NEXT I ( STEP -1)
    CR CR                       \ 370 PRINT ::
    WIN                         \ 380 IF WIN<>1
  UNTIL                         \     THEN 160
  ." Winner is 7 ^" POWER .     \ 390 PRINT "WINNER IS 7 ^";POWER
;                               \ 420 END
