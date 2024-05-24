CR .( COMPARE using S= from Camel Forth) 
HEX
CODE S= ( addr1 addr2 len)
    C0B6 , C076 , C004 , 04C4 , 130A , 9CB1 ,
    1306 , 1101 , 1002 , 0604 , 1001 , 0584 ,
    NEXT,  0600 , 16F6 , NEXT,
ENDCODE

: COMPARE ( addr n addr2 n2 -- -1|0|1) S" ROT MIN S=" EVALUATE ; IMMEDIATE
DECIMAL
