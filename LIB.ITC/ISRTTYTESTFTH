\ RS232/1 Interrupt Handler for CAMEL99 Forth   B Fox Feb 14 2019

NEEDS DUMP FROM DSK1.TOOLS    \ DEBUG ONLY
NEEDS MOV, FROM DSK1.ASM9900
NEEDS TO   FROM DSK1.VALUES

\ ****************************************************************************
\ *      Adaptation of Jeff Brown / Thierry Nouspikel (sp) idea to leverage
\ *      the ROM-based ISR to service external interrupts (RS232 in our case)
\ *      within the VDP interrupt framework.
\ *     BASED ON CODE BY INSANEMULTITASKER ATARIAGE

HEX
83C0 CONSTANT >83C0

\ Queue pointers, Initialized during setup
  VARIABLE QHEAD
  VARIABLE QTAIL

\ *circular Q management
  0 VALUE Q        \ Q base address
  0 VALUE QSIZE
  0 VALUE QMASK    \ circular mask value

\ build a queue in low RAM and set all the pointers
: QUEUE  ( size -- )  \ must be power of 2
          DUP MALLOC TO Q  \ set address of Q
          DUP TO QSIZE
          1-  TO QMASK
          QHEAD OFF       \ clear the head
          QTAIL OFF ;     \ clear the tail


\ ************************************************************
\ * QKEY? - Read character from 'Q' at index 'QHEAD'
HEX
 CODE QKEY? ( -- c | 0 )         \ 0 means queue empty
       TOS PUSH,                 \ make space in the TOS cache register
       TOS CLR,                  \ FLAG to say no char ready
       QHEAD @@ QTAIL @@ CMP,
       NE IF,                    \ head<>tail means char waiting
           QHEAD @@ W MOV,       \ get queue head index to W
           Q (W) TOS MOVB,       \ get char from Q -> TOS
           TOS SWPB,             \ move to other side of register
           W INC,                \ inc the index
           W QMASK ANDI,         \ wrap the index
           W QHEAD @@ MOV,       \ save the new index
       ENDIF,
       NEXT,                     \ 34 bytes
       ENDCODE

\ **************************************************************
\ * ISR is in workspace 83C0. ONLY R3 & R4 are free to use!!!
DECIMAL
CREATE TTY1-ISR ( * this is a label, not a runnable Forth word * )
      >83C0 LWPI,                                           \   10
       R12 CLR,          \ select 9901 chip CRU address        \   10
       2 SBZ,            \ Disable VDP int prioritization      \   12
       R11 SETO,         \ 3.5.16 hinder screen timeout        \   10
       PORT @@ R12 MOV,  \ set CRU PORT                        \   22
       QTAIL @@ R4 MOV,  \ index->R4                           \   22
       16 TB,            \ interrupt received?                 \   12
       EQ IF,            \ Yes; enqueue char                   \    8
            Q R4 () 8 STCR,    \                                   52
            18 SBO,            \ clr rcv buffer, enable interrupts 12
            R4 INC,            \ bump the index                    10
            R4 QMASK ANDI,     \ wrap the index                    14
            R4 QTAIL @@ MOV,   \ save the index                    22
       ENDIF,
       R12 CLR,        \ select 9901 chip CRU address              10
       3 SBO,          \ reset timer int                           12
       RTWP,           \ Return                     \           = 238

\ **************************************************************
\ * Configure ROM ISR to pass through external interrupts as VDP interrupts
\ *   (Jeff Brown/Thierry)


HEX
CODE INSTALL ( ISR_address -- )
       0 LIMI,
       TOS 83C4 @@ MOV, \ install ISR handler from Forth to R2 of ISR workspace
       83E0 LWPI,       \ >>GPL workspace<<
       R14 CLR,         \ Disable cassette interrupt; protect 8379
       R15 877B LI,     \ disable VDPST reading; protect 837B
      >83C0 LWPI,       \ >>ISR workspace<<
       R1 SETO,         \ [83C2] Disable all VDP interrupt processing
       R11 SETO,        \ Disable screen timeouts
       R12 CLR,         \ Set to 9901 CRU base
       BEGIN,
          2 TB,         \ check for VDP int
       NE UNTIL,        \ loop until <> 0
       1  SBO,          \ Enable external interrupt prioritization
       2  SBZ,          \ Disable VDP interrupt prioritization
       3  SBZ,          \ Disable Timer interrupt prioritization
       8300 LWPI,       \ >>FORTH WS<<
       TOS POP,         \ refill cache register
       2 LIMI,          \ 3.2  [rs232 ints now serviced!]
       NEXT,            \ and return to Forth
       ENDCODE

DECIMAL
CODE ISRON ( cru -- )  \ * Turn on the 9902 interrupts
       0 LIMI,
       TOS R12 MOV,
       18 SBO,          \  Enable rs232 RCV int
       TOS POP,
       2 LIMI,
       NEXT,
       ENDCODE

CODE ISROFF ( cru -- )  \ * Turn off the 9902 interrupts
       0 LIMI,
       TOS R12 MOV,      \ i.e., >1340
       18 SBZ,           \ Disable rs232 rcv int
       TOS POP,
       2 LIMI,
       NEXT,
       ENDCODE

 : QCLEAR      QHEAD OFF  QTAIL OFF ;

: POLLED-I/O
   /TTY1 ISROFF
    ['] CKEY?  'KEY? ! ;

: ISR-I/O
      QCLEAR             \ reset Queue pointers
      CKEY? DROP         \ clear any char from 9902
\      /TTY1 ISROFF       \ just to be safe
      TTY1-ISR INSTALL
      ['] QKEY? 'KEY? !  \ change 'key?' to read the queue
     /TTY1 ISRON ;       \ activate isr. :-)

HEX 100 QUEUE

\ *************************************************
: ISR-TEST
     QCLEAR             \ reset Queue pointers
     CKEY? DROP         \ clear any chars from 9902
     TTY1-ISR INSTALL    \ obvious :-)
     /TTY1 ISRON        \ activate isr
     BEGIN
       QKEY? DUP EMIT  \ emit each char
       3 =             \ until ^C is sent
     UNTIL
    /TTY1 ISROFF
     0 INSTALL ;
