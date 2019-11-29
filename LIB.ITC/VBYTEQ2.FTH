\ VBYTEQ.FTH                           Sept 18 2019 B Fox
\ NEEDS .S      FROM DSK1.TOOLS

\ use VDP memory to create BYTE Queues that are
\ managed by a structure in CPU RAM

NEEDS MOV,    FROM DSK1.ASM9900
NEEDS VALLOT  FROM DSK1.VDPMEM

HEX
\ create data structure *SIZE MUST BE POWER OF 2*
: VBYTEQ: ( size -- addr )  \ define a queue
         CREATE
\           tail  head  size   mask    VDP Addr
\           ----  ----  ----   ----    --------
             0 ,  0 ,   DUP , DUP 1- ,  VHERE ,  VALLOT ;

CODE +@  ( addr ndx -- n) \ + @  improves speed by ONLY 4%
          A136 , \  *SP+ TOS ADD,
          C114 , \  *TOS TOS MOV,
          NEXT,
          ENDCODE

CODE DUP@  TOS PUSH,  *TOS TOS MOV,  NEXT, ENDCODE

: ^TAIL ( fifo -- vaddr) DUP 8 +@   SWAP @ + ;
: ^HEAD ( fifo -- vaddr) DUP 8 +@   SWAP CELL+ @ + ;

\ circular BYTE Q access words
\ circular BYTE Q access words
: TAIL+!  ( FIFOaddr --)
           DUP@ 1+
           OVER 6 +@ AND
           SWAP ! ;

: HEAD+!  ( FIFOaddr --)
           CELL+
           DUP@ 1+
           OVER 4 +@ AND
           SWAP ! ;

: Q@      ( fifo -- n)
           DUP 2@ = ABORT" Byte Q underflow"
           DUP ^HEAD VC@ SWAP HEAD+! ;

: QLEN   ( fifo -- n) 2@ - ABS ;

: Q!        ( n fifo -- )
  \           DUP QLEN OVER 6 +@ 2- < ABORT" Queue full"
             TUCK ^TAIL VC!  TAIL+! ;

: QRST    ( fifo -- ) 0 0 ROT 2! ;

\ ==============================================
\ TEST CODE

400 VBYTEQ: X
400 VBYTEQ: Y
400 VBYTEQ: Z

: Q$!  ( caddr len fifo -- ) -ROT BOUNDS DO  I C@ OVER Q! LOOP DROP ;

: PRINTQ  ( fifo -- ) BEGIN DUP QLEN WHILE  DUP Q@ EMIT  REPEAT DROP ;

: 3DUP     2 PICK 2 PICK 2 PICK ;

: FILLQ  ( cadr len FIFO -- )  20 0 DO   3DUP Q$!  LOOP   2DROP DROP ;

