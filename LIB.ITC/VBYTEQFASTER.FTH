\ VBYTEQ.FTH

NEEDS .S      FROM DSK1.TOOLS
NEEDS VALLOT  FROM DSK1.VDPMEM
NEEDS MOV,    FROM DSK1.ASM9900
NEEDS ELAPSE  FROM DSK1.ELAPSE 

\ use VDP memory to create 1k BYTE Queues that are managed by variables in CPU RAM

DECIMAL
\ create data structure
: VBYTEQ: ( size -- <text> )
\ Make a 9900 Workspace. Later we used registers instead of memory
   CREATE  0 ,       \ R0  Q tail
           0 ,       \ R1  Q head
           DUP ,     \ R2  size
           DUP 1- ,  \ R3  mask
           VHERE ,   \ R4  VDP address
           0 ,       \ R5  temp
           0 ,       \ R6  temp
           0 ,       \ 7
           0 ,       \  8
           0 ,       \  9
           0 ,       \  10
           0 ,       \  11
           0 ,       \  12
           0 ,       \  13 used for RTWP only
           0 ,       \  14
           0 ,       \  15
           0 ,       \ PROTECTION :-)
           VALLOT ;  \ allot VDP RAM too

HEX
\ circular BYTE Q access words
CODE TAIL+!  ( fifo -- )
           *TOS BLWP,
           R0 ** INC,        \ increment tail pointer
           R3 ** R5 MOV,
                 R5 INV,
           R5  R0 ** SZC,     \ mask -> tail against R3
           RTWP,          \ restore Forth workspace

           TOS POP,
           NEXT,
           ENDCODE

CODE HEAD+!  ( fifo -- )
           *TOS BLWP,
           R1 ** INC,
           R3 ** R5 MOV,
                 R5 INV,
           R5  R1 ** SZC,
           RTWP,

           TOS POP,
           NEXT,
           ENDCODE
           
CODE TEST   *TOS BLWP,  RTWP,  NEXT, ENDCODE

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

\ : Q@     ( fifo -- n) DUP >R ->vaddr R@ ->head @ + VC@ R> HEAD+! ;
\ : Q!     ( n fifo --) DUP >R ->vaddr R@ ->tail @ + VC! R> TAIL+! ;

: Q@        ( fifo -- n)  DUP ^HEAD VC@  HEAD+! ;
: Q!        ( n fifo -- ) TUCK ^TAIL VC!  TAIL+! ;

: Q?     ( fifo -- ?) 2@ <> ;              \ is data ready?
: QLEN   ( fifo -- n) 2@ -  ;
\ ==============================================
\ TEST CODE

400 VBYTEQ: X
400 VBYTEQ: Y
400 VBYTEQ: Z

: Q$!  ( caddr len fifo -- ) -ROT BOUNDS DO  I C@ OVER Q! LOOP DROP ;

: PRINTQ  ( fifo -- ) BEGIN DUP QLEN WHILE  DUP Q@ EMIT  REPEAT DROP ;

: 3DUP     2 PICK 2 PICK 2 PICK ;

: FILLQ  ( cadr len FIFO -- )  20 0 DO   3DUP Q$!  LOOP   2DROP DROP ;

