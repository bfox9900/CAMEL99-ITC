: SCROLL ( -- )
       PAUSE
       HERE 100 +     \ grab some space above Forth PAD
       TOPLN C/SCR @  ( -- buffer Vstart len)
       BOUNDS  ( -- buffer SCRend SCRstart)
       DO
         I  C/L@ +  OVER  C/L@ 2* VREAD
         DUP  I           C/L@ 2* VWRITE
       C/L@ 2* +LOOP
       DROP
       0 17 AT-XY VPOS C/L@ BL VFILL
;

HEX
: MOVE2 ( Vaddr -- Vaddr')
       DUP C/L@ +  PAD  C/L@ 4* VREAD
       PAD  OVER        C/L@ 4* VWRITE
       C/L@ 4* +
;

: SCROLL
   TOPLN
   MOVE2 MOVE2 MOVE2
   MOVE2 MOVE2 MOVE2
   DROP
;
