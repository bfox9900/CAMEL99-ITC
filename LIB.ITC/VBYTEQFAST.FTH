\ VBYTEQFAST.FTH   Using code words is 2.3 times faster than only forth

NEEDS .S      FROM DSK1.TOOLS
NEEDS VALLOT  FROM DSK1.VDPMEM
NEEDS MOV,    FROM DSK1.ASM9900
NEEDS ELAPSE  FROM DSK1.ELAPSE 

\ use VDP memory to create 1k BYTE Queues that are managed by variables in CPU RAM

HEX
\ create data structure
: VBYTEQ: ( size -- <text> )
\              tail  head  size   mask    VDP Addr
\               ----  ---- ----   ----    --------
        CREATE  0 ,  0 ,   DUP , DUP 1- ,  VHERE ,  VALLOT ;


CODE TAIL+!  ( fifo -- )     \
          *TOS R0 MOV,      \ head @ -> R0
           R0 INC,          \ R0 1+
           6 (TOS) R1 MOV,  \ mask @ -> R1
           R1  INV,
           R1 R0      SZC,  \ R1 R0 AND ( R0 has new head)
           R0 *TOS MOV,
           TOS POP,
           NEXT,
           ENDCODE

CODE HEAD+!  ( fifo -- )     \
           2 (TOS) R0 MOV,  \ head @ -> R0
           R0 INC,          \ R0 1+
           6 (TOS) R1 MOV,  \ mask @ -> R1
           R1  INV,
           R1 R0      SZC,  \ R1 R0 AND ( R0 has new head)
           TOS INCT,        \ point to head field
           R0 *TOS MOV,
           TOS POP,
           NEXT,
           ENDCODE

CODE ^TAIL ( fifo -- vaddr)
            8 (TOS) R0 MOV,
            *TOS    R0 ADD,
            R0 TOS MOV,
            NEXT,
            ENDCODE

CODE ^HEAD ( fifo -- vaddr)
            8 (TOS) R0 MOV,
            2 (TOS) R0 ADD,
            R0 TOS MOV,
            NEXT,
            ENDCODE

: Q@        ( fifo -- n)
             DUP 2@ = ABORT" Byte Q underflow"
             DUP ^HEAD VC@ SWAP HEAD+! ;

: QLEN   ( fifo -- n) 2@ - ABS ;

: Q!        ( n fifo -- )
  \           DUP QLEN OVER 6 []@  2- < ABORT" Queue full"
             TUCK ^TAIL VC!  TAIL+! ;

: Q?     ( fifo -- ?) 2@ <> ;              \ is data ready?
: QLEN   ( fifo -- n) 2@ - ABS ;
\ ==============================================
\ TEST CODE

400 VBYTEQ: X
400 VBYTEQ: Y
400 VBYTEQ: Z

: Q$!  ( caddr len fifo -- ) -ROT BOUNDS DO  I C@ OVER Q! LOOP DROP ;

: PRINTQ  ( fifo -- ) BEGIN DUP QLEN WHILE  DUP Q@ EMIT  REPEAT DROP ;

: 3DUP     2 PICK 2 PICK 2 PICK ;

: FILLQ  ( cadr len FIFO -- )  20 0 DO   3DUP Q$!  LOOP   2DROP DROP ;

