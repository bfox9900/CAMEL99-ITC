\ Fastest access to an array in CPU RAM uses indexed addressing instructions

100 CONSTANT SIZE
CREATE ARRAY    SIZE CELLS ALLOT

\ fetch contents of any cell in ARRAY
CODE ARRAY@  ( i -- array[i]@) 
        TOS  1 SLA,               \ shift R1 1 bit left (mult. By 2)
        ARRAY (TOS) TOS MOV,      \ fetch contents of ARRAY(TOS) to TOS
	NEXT,
ENDCODE
           
\ store 'n' on stack to any cell in ARRAY
CODE ARRAY!  ( n index --) 
       TOS  1 SLA,               \ shift TOS 1 bit left (mult. By 2)
      *SP+ ARRAY (TOS) MOV,      \ POP 2nd stack item into address ARRAY(TOS)
       TOS POP,                  \ refill TOS register
       NEXT,
ENDCODE
	
