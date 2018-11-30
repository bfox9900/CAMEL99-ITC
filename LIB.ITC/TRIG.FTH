\ TRIG for 16 bit Forth to 4 decimals
\ Source: Forth Applications S. D. Roberts
\ Modified for ANS Forth, B. Fox

DECIMAL
CREATE SINTAB   ( 182 bytes)
\  0      1      2      3      4      5      6      7      8      9
\ --------------------------------------------------------------------
  0000 , 0174 , 0349 , 0523 , 0698 , 0872 , 1045 , 1219 , 1392 , 1564 ,
  1736 , 1908 , 2079 , 2249 , 2419 , 2588 , 2756 , 2924 , 3090 , 3256 ,
  3420 , 3584 , 3746 , 3907 , 4067 , 4226 , 4384 , 4540 , 4695 , 4848 ,
  5000 , 5150 , 5299 , 5456 , 5592 , 5736 , 5878 , 6018 , 6157 , 6293 ,
  6428 , 6561 , 6691 , 6820 , 6947 , 7071 , 7193 , 7314 , 7431 , 7547 ,
  7660 , 7772 , 7880 , 7986 , 8090 , 8191 , 8290 , 8387 , 8480 , 8571 ,
  8660 , 8746 , 8829 , 8910 , 8988 , 9063 , 9135 , 9205 , 9272 , 9336 ,
  9397 , 9455 , 9511 , 9563 , 9613 , 9659 , 9703 , 9744 , 9781 , 9816 ,
  9848 , 9877 , 9903 , 9926 , 9945 , 9962 , 9976 , 9986 , 9994 , 9998 ,
  10000 ,

HEX
\ machine Forth "compilers" make it easy to create VERY fast arrays
\ R4 is CAMEL99 Forth cache register for Top of stack
: 2*,   ( n -- 2(n)  A104 , ;             \ A R4,R4
: +@,   ( addr -- )  C124 , ( addr) , ;   \ MOV addr@(R4),R4

DECIMAL
CODE ]SIN  ( ndx -- sin) 2*,  SINTAB +@,  NEXT, ENDCODE
\  : ]SIN  ( ndx -- sin) 2*   SINTAB + @ ;  \ FORTH equivalent

\ save space by defining these constants
 90 CONSTANT 90^   180 CONSTANT 180^   360 CONSTANT 360^

: (SIN)  ( n -- n) DUP  90^ > IF  180^ SWAP -  THEN ]SIN ;

: SIN    ( n -- n )
         360^  MOD DUP 0<
         IF    360^ +  THEN
         DUP 180^ >
         IF    180^ - (SIN) NEGATE
         ELSE (SIN)
         THEN ;

: COS ( n -- n )  360^ MOD 90^ + SIN ;
