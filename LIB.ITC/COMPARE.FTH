\ FAST compare using S= from Camel Forth

CODE S= ( addr1 addr2 len)
    C0B6 , C076 , C004 , 04C4 , 130A , 9CB1 ,
    1306 , 1101 , 1002 , 0604 , 1001 , 0584 ,
    045A , 0600 , 16F6 , 045A , ENDCODE

: COMPARE ( addr n addr2 n2 -- -1|0|1) 
          ROT MAX S= ;
