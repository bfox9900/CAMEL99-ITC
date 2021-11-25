\ FASTKEY is better for multi-tasking

\ KSCAN in the system ROM uses internal delays for debounce.
\ It takes 1.2 mS to run even if no key is pressed!
\ This slows down cooperative multi-tasking by slowing down
\ the context switch time while waiting for a key keypress.


NEEDS WORDLIST FROM DSK1.SUPERTOOLS

\ Source:
\ http://www.unige.ch/medecine/nouspikel/ti99/keyboard.htm#quick%20scan

FORTH DEFINITIONS ALSO ASSEMBLER
HERE
HEX
CODE (KEY?) ( -- ?)      \ return TRUE if any key pressed
      TOS PUSH,          \
      TOS CLR,           \ TOS=false
      R1 CLR,            \ Start with column 0
      BEGIN,
         R12 0024 LI,    \ R12-address for column selection
         R1  0003 LDCR,  \ Select a column
         R12 0006 LI,    \ R12-address to read rows
               R2 SETO,  \ Make sure all bits are 1
         R2  0008 STCR,  \ read 8 row values
               R2 INV,   \ pressed keys read as 0 so flip all bits
         NE IF,          \ A key was pressed
             TOS SETO,   \ Set TOS true for Forth
             NEXT,       \ return to Forth
         ENDIF,
         R1 0100 AI,     \ Next column
         R1 0600 CI,     \ Are we done?
      EQ UNTIL,
      NEXT,              \ Return to Forth
 ENDCODE

: FLUSHKEY  ( -- ) \ make sure no key is pressed
    BEGIN
    (KEY?) WHILE
    REPEAT ;

: WAITKEY   ( -- )
    BEGIN
        PAUSE               \ Essential for Multi-tasking with Console
        CURS @              \ fetch 2 char cursor (space & _ )
        TMR@ 1FFF < IF >< THEN VPUT  \ swap cursor bytes & write
       (KEY?)
    UNTIL ;

\ over-write the old version
: NEWKEY  ( -- c)  WAITKEY  KEY ;

HERE SWAP - DECIMAL .  .( bytes)
