\ literal translation of a BASIC version of the sevens problem Brian Fox
\ Original BASIC program from Atariage.com  

\ re-factored the way Forth would be written

INCLUDE DSK1.TOOLS 
INCLUDE DSK1.ELAPSE 
INCLUDE DSK1.ARRAYS 
INCLUDE DSK1.VALUES 

DECIMAL 
\ helper words 
: ?BREAK   ?TERMINAL ABORT" *BREAK*" ; 
: ERASE ( addr len -- )  0 FILL ;

\ define all data before use
\ 0 VALUE WIN   \ replaced with flag on data stack 
0 VALUE POWER 
0 VALUE NUMLEN 
0 VALUE CARRY 
0 VALUE INAROW 
0 VALUE NDX   ( transfers loop index out of DO LOOP )

 256 CARRAY ]A                  \ 100 DIM A(256)

: MEM_INIT 
  0 ]A 256 ERASE                \ init ]A to zeros
  7 0 ]A C!                     \ 120 A(1)=7

  1 TO POWER                    \ 140 POWER=1
  0 TO NUMLEN                   \ 150 NUMLEN=1
;

: PROCESSOR ( -- ? ) \ win FLAG lives on data stack 
    0 TO CARRY                  \ 180 CARRY=0
    0 TO INAROW                 \ 190 INAROW=0
    FALSE                       \ replaces WIN variable 
    NUMLEN 1+ 0                 \ 200 FOR I=1 TO NUMLEN
    DO    
        I TO NDX                \ copy I for later 
        I ]A                    \ Array address onto data stack 
        DUP C@ 7 *  CARRY +     \ 210 A(I)=A(I)*7+CARRY
        0 10 UM/MOD TO CARRY    \ 220 CARRY=INT(A(I)/10)
( addr n) TUCK SWAP C!          \ 230 A(I)=A(I)-CARRY*10
        7 =                     \ 240 IF A(I)<>7 THEN 290
        IF     
            1 +TO INAROW        \ 250 INAROW=INAROW+1
            INAROW 6 =          \ 260 IF INAROW<>6 THEN 300
            IF                
              DROP TRUE 
              LEAVE 
            THEN                
        ELSE                    \ 280 GOTO 300 
            0 TO INAROW         \ 290 INAROW=0
        THEN 
    LOOP                        \ 300 NEXT I
;

: PRINT_A[] 
    CR
    CARRY DUP NDX 1+ ]A C!      \ 310 A(I)=CARRY
    IF                          \ 320 IF CARRY=0 THEN 340
       1 +TO NUMLEN             \ 330 NUMLEN=NUMLEN+1
    THEN 

    0  NUMLEN                   \ 340 FOR I=NUMLEN TO 1 
    DO   
       I ]A C@ >DIGIT (EMIT)    \ 350 PRINT CHR$(A(I)+48);
    -1 +LOOP                    \ 360 NEXT I ( STEP -1)
; 

: RUN 
    CR ." 7's Problem "          \ 110 PRINT "7's Problem"
    MEM_INIT 
    BEGIN 
        1 +TO POWER              \ 160 POWER=POWER+1
       ." 7 ^" POWER . ." IS:"   \ 170 PRINT "7 ^";POWER;"IS:"
        ?BREAK 
        PROCESSOR ( -- ?)
        PRINT_A[] 
        CR CR 
    UNTIL                       \ THEN 160

  ." Winner is 7 ^" POWER .     \ 390 PRINT "WINNER IS 7 ^";POWER
;                               \ 420 END
