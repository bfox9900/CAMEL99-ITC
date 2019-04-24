\ RS232/1 Interrupt Handler for CAMEL99 Forth   B Fox Feb 14 2019

\ ****************************************************************************
\ *      Adaptation of Jeff Brown / Thierry Nouspikel (sp) idea to leverage
\ *      the ROM-based ISR to service external interrupts (RS232 in our case)
\ *      within the VDP interrupt framework.
\ *

HEX
    83C0 CONSTANT ISRWKSP

\ *FAST Queue pointers in scratchpad  (USER VARIABLE space)
     VARIABLE QHEAD    \ >836C Initialized during setup
     VARIABLE QTAIL    \ >836E        "    "
83D6 CONSTANT STO     \ screen time out address

\ *circular Q management
    0100 CONSTANT QSIZE    \ 256 byte buffer
QSIZE 1- CONSTANT QMASK    \ circular mask value

\ *pointer to 256 byte circular buffer
QSIZE MALLOC CONSTANT Q         \ Q must be assigned memory when system boots

: CIRC++   ( addr -- ) DUP @ 1+ QMASK AND   SWAP ! ;

: ENQ      ( c -- )  Q QTAIL @ + C!  QTAIL CIRC++ ;

: ENQ$     ( adr len -- ) BOUNDS DO I C@ ENQ LOOP ;

: QCLEAR    QHEAD OFF  QTAIL OFF ;

\ ************************************************************
\ * FORTH WORD: QKEY1 - Read character from 'Q' at index 'QHEAD'
HEX
 CODE QKEY? ( -- c | 0 )
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
       NEXT,                    \ 34 BYTES
       ENDCODE

\ FORTH equivalent



\ : QKEY1  ( -- c | 0 )  \ read char from queue or return 0
\        FALSE                \ assume no char waiting
\        QHEAD @ QTAIL @ <>
\        IF
\           DROP              \ drop false flag
\           Q QHEAD @ + C@
\           QHEAD CIRC++
\        THEN ;               \ 32 bytes

: QPRINT    BEGIN  QKEY? DUP WHILE   EMIT  REPEAT DROP ;


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
       PROTO @@ 8 LDCR,     \ set protocol (8n1 is normal)
       BPS   @@ C LDCR,     \ set baud (typically 9600)
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
\ * You must disable screen timeout interrupts
\ *   1 83D6 !    \ 3.5.16 hinder screen timeout        \      10

DECIMAL
CREATE TTY1-ISR ( * this is a label, not a runnable Forth word * )
       ISRWKSP LWPI,                                           \   10
       R12 CLR,          \ select 9901 chip CRU address        \   10
       2 SBZ,            \ Disable VDP int prioritization      \   12
       PORT @@ R12 MOV,  \ set CRU PORT                        \   22
       QTAIL @@ R4 MOV,  \ index->R4                           \   22
       16 TB,            \ interrupt received?                 \   12
       EQ IF,            \ Yes; enqueue char                   \    8
            Q R4 () 8 STCR,    \                                   52
            18 SBO,            \ clr rcv buffer, enable interrupts 12
            R4 INC,            \ bump the index                    10
            R4 QMASK ANDI,     \ wrap the index                    14
            R4 QTAIL @@ MOV,   \ save the index                    22
       ENDIF,                                                \    206
      R12 CLR,        \ select 9901 base address
      3 SBO,          \ reset timer 
      RTWP,           \ go home

\ **************************************************************
\ * Configure ROM ISR to pass through external interrupts as VDP interrupts
\ *   (Jeff Brown/Thierry)

HEX
CODE INSTALL ( ISR_address -- )
       0 LIMI,
       TOS 83C4 @@ MOV, \ install ISR handler from Forth-> R2 of ISR workspace

       83E0 LWPI,       \ >>GPL workspace<<2
       R14 CLR,         \ Disable cassette interrupt; protect 8379
       R15 877B LI,     \ disable VDPST reading; protect 837B

       ISRWKSP LWPI,    \ >>ISR workspace<<
       R1 SETO,         \ [83C2] Disable all VDP interrupt processing
\       HANDLER @@ R2 MOV,   \ [83C4] set our interrupt vector
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
CODE RCVON ( cru -- )  \ * Turn on the 9902 interrupts
       0 LIMI,
       STO ON           \ set screen timeout to -1 disables
       TOS R12 MOV,
       18 SBO,          \  Enable rs232 RCV int
       TOS POP,
       2 LIMI,
       NEXT,
       ENDCODE

CODE RCVOFF ( cru -- )  \ * Turn off the 9902 interrupts
       0 LIMI,
       TOS R12 MOV,      \ i.e., >1340
       18 SBZ,           \ Disable rs232 rcv int
       TOS POP,
       2 LIMI,
       NEXT,
       ENDCODE

: ISR-INSTALL  ( -- )  /TTY1 RCVOFF  TTY1-ISR INSTALL ;

Q /TTY1 OPEN-TTY

HEX
: ISR-TEST
             QCLEAR
             CKEY? DROP         \ clear any chars from 9902
             /TTY1 RCVON        \ activate isr
             BEGIN
                QKEY? DUP
                ?DUP IF EMIT THEN
                3 =
             UNTIL
            /TTY1 RCVOFF
;
