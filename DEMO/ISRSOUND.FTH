\ ISR Sound player for Camel99 Forth   Jan 10, 2019 BJF
\ Play TI sound lists in VDP RAM as a background task
\ VBYTE directive used to compile sound lists into VDP RAM
\ Changed to use VDPMEM library Nov 10, 2020 BJF

NEEDS VHERE  FROM DSK1.VDPMEM
HEX
 83C2 CONSTANT AMSQ      \ interrupt DISABLE bits
\ AMSQ bit meaning:
\ 80 all interrupts disabled
\ 40 motion disabled
\ 20 Sound disabled
\ 10 quit key disabled

\ VDP byte string compiler
: ?BYTE ( n -- ) FF00 AND  ABORT" Not a byte" ;

: VBYTE ( -- )
         BEGIN  [CHAR] , PARSE-WORD DUP
         WHILE
            EVALUATE DUP ?BYTE
            VC,
         REPEAT
         2DROP ;

: /VEND   0 VC, 0 VC, ;   \ end the list with 2 bytes

CODE 0LIMI ( -- )  0300 , 0000 , NEXT, ENDCODE
CODE 2LIMI ( -- )  0300 , 0002 , NEXT, ENDCODE

\ ........................................
\  ISR Sound List Player
HEX
: ISRPLAY ( vaddr -- )
            0LIMI                     \ interrupts off
            83CC !                    \ Vaddr -> sound table
            AMSQ C@  5 AND AMSQ C!    \ enable sound interrupts
            01 83CE C!                \ trigger sound list processing
            83FD C@  01 OR 83FD C!    \ set "VRAM is source" flag
            2LIMI ;                   \ interrupts on

1000 VP !    \ reset VDP memory heap
\ example list
\ USAGE:  PACMAN ISRPLAY   ( plays as background task)
HEX
 VCREATE PACMAN
       VBYTE 6,80,0D,97,AC,1A,B7,8
       VBYTE 2,8F,08,2
       VBYTE 2,AB,23,5
       VBYTE 2,80,0D,4
       VBYTE 1,BF,3
       VBYTE 2,8E,0B,8
       VBYTE 2,8A,0A,2
       VBYTE 3,AC,1A,B7,8
       VBYTE 2,9F,BF
 /VEND
CR 
CR .( Usage:  PACMAN ISRPLAY )
