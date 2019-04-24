\ ISR Sound player for Camel99 Forth   Jan 10, 2019 BJF

\ VDP RAM manager
VARIABLE VP    \ VDP memory pointer (4K block)

HEX 1000 VP !   \ start of free VDP RAM

: VHERE   ( -- addr) VP @ ;   \ FETCH the value in VDP pointer
: VALLOT ( n -- )    VP +! ;  \ add n to the value in VDP pointer

\ Compile a byte in the next available VDP memory location
: VC,    ( n -- )  VHERE VC!  1 VALLOT ;

: VCREATE  ( -- <text>)
            CREATE VHERE ,   \ compile VDP address in CPU RAM
            DOES> @  ;       \ run time: fetch the VDP address

\ setup ISR sound
: ISRPLAY ( vaddr -- )
            LIMI0                     \ interrupts off
            83CC !                    \ load sound table address
            01 83CE C!                \ trigger sound processing
            83FD C@  01 OR 83FD C!    \ set VDP flag
            LIMI2 ;                   \ interrupts on

\ VDP BYTE directive: read bytes and compile into VDP RAM
: VBYTE ( -- )  \ read input stream of bytes and compile to VDP mem.
         BEGIN
           [CHAR] , PARSE-NAME  DUP  ( -- adr len len )
         WHILE
            EVALUATE  DUP FF00 AND ABORT" Not a byte"
            VC,
         REPEAT
         2DROP ;

: /END   ( -- )  0 VC,  ;              \ compile a zero BYTE into VDP RAM

VCREATE PACMAN
       VBYTE 6,86,0D,97,AC,1A,B7,8
       VBYTE 2,8F,08,2
       VBYTE 2,AB,23,5
       VBYTE 2,86,0D,4
       VBYTE 1,BF,3
       VBYTE 2,8E,0B,8
       VBYTE 2,8A,0A,2
       VBYTE 3,AC,1A,B7,8
/END



