\ find the disk number in use CAMEL99 Forth

\       MOV @>83D0,R12 		GET THE CRU BASE IN R12
\	JEQ EXIT 			GET OUT IF 0
\	MOV @>83D2,R9 		GET THE ROM ADDRESS FOR DEVICE
\	JEQ EXIT 			GET OUT IF 0
\	SBO 0 				ENABLE THE DEVICE ROM
\	AI R9,8 			Now R9 points to disk number (ascii)

NEEDS 0SBO   FROM DSK1.CRU

HEX
: DSK#  ( -- n)
         83D0 @ DUP 0= ABORT" No disk"
         CRU!                          \ store top of stack to R12
         83D2 @ DUP 0= ABORT" No ROM"
         0SBO                          \ turn the card on
         ( 83D2) @ 8 +  C@             \ fetch char from address on stack+8
         0SBZ                          \ turn the card off
         [CHAR] 0 -                    \ subtract ascii '0' to return integer
;




