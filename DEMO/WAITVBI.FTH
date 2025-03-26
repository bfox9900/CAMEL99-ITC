\ wait for vertical blanking interval on TMS9918 VDP chip

NEEDS .S   FROM DSK1.LOWTOOLS

INCLUDE DSK1.EMPTY

EMPTY 

HEX
 CODE WAITVBI ( -- )
   0 LIMI,
   8802 @@ R0 MOVB,
   BEGIN,
     8802 @@ R0 MOVB,
     R0 8000 ANDI,
   NE UNTIL,
   NEXT,
 ENDCODE

: FILL1
     [CHAR] Z 1+  [CHAR] A
     DO
       WAITVBI
       0 3C0 I VFILL
     LOOP
;

: TEST1
    BEGIN
      WAITVBI
      FILL1
      ?TERMINAL
    UNTIL ;

: FILL2
     [CHAR] Z 1+  [CHAR] A
     DO
       0 3C0 I VFILL
     LOOP
;

: TEST2
        BEGIN
          FILL2
          ?TERMINAL
        UNTIL ;

: TEST3 
    BEGIN 
       0 3C0 [CHAR] A  VFILL 
       PAGE 
      ?TERMINAL 
    UNTIL       
;        

: TEST4 
    BEGIN 
      WAITVBI 0 3C0 [CHAR] A  VFILL 
      WAITVBI PAGE 
      ?TERMINAL 
    UNTIL       
;        
