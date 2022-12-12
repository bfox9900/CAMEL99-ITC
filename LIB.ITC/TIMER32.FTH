\ ISR 32 bit timer for CAMEL99 Forth   12 Feb 2018 BJF

 INCLUDE DSK1.ASM9900
 
 HEX
 CREATE T 0 , 0 , 

: INSTALL ( isr-addr -- ) 83C4 ! ;

: RESET32  ( -- )  0 0 T 2! ;

HERE  \ headless code fragement begins HERE 
   T CELL+ @@ INC,
   OC IF,
        T @@ INC,
   ENDIF,
   RT,
INSTALL
