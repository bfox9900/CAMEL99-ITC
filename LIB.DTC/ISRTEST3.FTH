\ RS232/1 Interrupt Handler for CAMEL99 Forth   B Fox Feb 14 2019

NEEDS DUMP  FROM DSK1.TOOLS  \ DEBUG ONLY
NEEDS MOV,  FROM DSK1.ASM9900
NEEDS VALUE FROM DSK1.VALUES

\ ****************************************************************************
\ *      Adaptation of Jeff Brown / Thierry Nouspikel (sp) idea to leverage
\ *      the ROM-based ISR to service external interrupts (RS232 in our case)
\ *      within the VDP interrupt framework.
\ *

HEX
    83C0 CONSTANT ISRWKSP

\ Queue pointers, Initialized during setup
  VARIABLE QHEAD
  VARIABLE QTAIL

\ *circular Q management
    1000 VALUE QSIZE    \ 4k byte buffer
QSIZE 1- VALUE QMASK    \ circular mask value

\ allocate to 256 byte circular buffer in low RAM
QSIZE MALLOC VALUE Q    \ *Q must be assigned memory when system boots

\ ***********************************************************
\ * queue debugging tools
\ : CIRC++   ( addr -- ) DUP @ 1+ QMASK AND   SWAP ! ;
\ : ENQ      ( c -- )  Q QTAIL @ + C!  QTAIL CIRC++ ;
\ : ENQ$     ( adr len -- ) BOUNDS DO I C@ ENQ LOOP ;

\ : QKEY?  ( -- c | 0 )  \ read char from queue or return 0
\        FALSE                \ assume no char waiting
\        QHEAD @ QTAIL @ <>
\        IF
\           DROP              \ drop false flag
\           Q QHEAD @ + C@
\           QHEAD CIRC++
\        THEN ;               \ 32 bytes

\ : QPRINT     BEGIN
\                 QKEY1 DUP
\              WHILE ( tos<>0)
\                 EMIT
\              REPEAT
\              DROP ;


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

\ ************************************************************
\ * Init RS232,buffers,CIB.
\ * usage:  100 MALLOC /TTY1 OPEN-TTY

HEX
CODE OPEN-TTY ( buffer cruaddr -- )
       0 LIMI,              \ inhibit ints until setup is complete
       R12  RPUSH,          \ save R12 which might be in use
       TOS R12 MOV,         \ 9902 CRU address -> R12
       1F SBO,              \ Reset 9902

\ * Need a delay after reset so...
\ * Assign buffer to  Q, init Q head and tail indices
      *SP+  ' Q >BODY @@ MOV,  \ POP buffer to Forth constant 'Q'
       QHEAD @@ CLR,        \ clear the head
       QTAIL @@ CLR,        \ clear the tail

\ * We can configure the 9902 now
       0D SBZ,              \ 9902 Bit 13, disable interval register
       PROTO @@ 08 LDCR,     \ set protocol (8n1 is normal)
       BPS   @@ 0C LDCR,     \ set baud (typically 9600)
       R12 RPOP,            \ restore R12
       TOS POP,             \ refill Forth top of stack cache
       NEXT,
       ENDCODE

\ **********************************************************
\ * Interrupt Handler
\ *    Entered from the ROM ISR via the user defined interrupt
\ *    We immediately test the configured RS232 for a received character.
\ *--------------------------------------------------------
\ * RS232 Circular Buffer character reception
\ *      Only test interrupts on active port as defined during setup
\ *      Spurious ints from another RS232 will result in virtual lockup
\ *      because they will never be serviced
\ *      OVERRUNS will overwrite old data in the QUEUE


\ **************************************************************
\ * ISR is in workspace 83C0. ONLY R3 & R4 are free to use!!!

DECIMAL
CREATE TTY1-ISR ( * this is a label, not a runnable Forth word * )
       ISRWKSP LWPI,                                           \   10
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

\ * variable use to transport ISR from Forth to ISR workspace
\ VARIABLE HANDLER

HEX
CODE INSTALL ( ISR_address -- )
       0 LIMI,
       TOS 83C4 @@ MOV,
       83E0 LWPI,
       R14 CLR,         \ Disable cassette interrupt; protect 8379
       R15 877B LI,     \ disable VDPST reading; protect 837B

       ISRWKSP LWPI,    \ switch to ISR workspace
       R1 SETO,         \ [83C2] Disable all VDP interrupt processing
       R11 SETO,        \ Disable screen timeouts

       R12 CLR,         \ Set to 9901 CRU base
       BEGIN,
          2 TB,         \ check for VDP int
       NE UNTIL,        \ loop until <> 0

       1  SBO,          \ Enable external interrupt prioritization
       2  SBZ,          \ Disable VDP interrupt prioritization
       3  SBZ,          \ Disable Timer interrupt prioritization
       8300 LWPI,       \ return to the FORTH WS
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

Q /TTY1 OPEN-TTY

: POLLED-I/O
     /TTY1 ISROFF
    ['] CKEY?  'KEY? ! ;

: ISR-I/O
      QCLEAR             \ reset Queue pointers
      CKEY? DROP         \ clear any char from 9902
      TTY1-ISR INSTALL
      ['] QKEY?  'KEY? !  \ change 'key?' to read the queue
     /TTY1 ISRON ;       \ activate isr. :-)

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

HEX
: STRAIGHT ( addr len -- )
    CR ." Waiting for file..."
    QCLEAR             \ reset Queue pointers
    CKEY? DROP         \ clear any chars from 9902
    TTY1-ISR INSTALL    \ obvious :-)
    /TTY1 ISRON        \ activate isr
    LINES OFF
    BOUNDS
    ?DO
       BEGIN QKEY? ?DUP UNTIL
       DUP I C!
       3 = IF LEAVE THEN
    LOOP
    /TTY1 ISROFF ;
