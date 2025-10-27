\ FASTKEY is better for multi-tasking

\ KSCAN in the system ROM uses internal delays for debounce.
\ It takes 1200 uS to run even if no key is pressed!
\ This slows down cooperative multi-tasking by slowing down
\ the context switch time while waiting for a key keypress.
\ (KEY?) run in ~300uS or 4X faster

NEEDS DUMP FROM DSK1.LOWTOOLS

\ Source:
\ http://www.unige.ch/medecine/nouspikel/ti99/keyboard.htm#quick%20scan

HERE
HEX
CODE (KEY?) ( -- ?)      \ return TRUE if any key pressed
    TOS PUSH,          \
    R1 CLR,            \ Start with column 0
    BEGIN,
        R12 0024 LI,    \ R12-address for column selection
        R1  0003 LDCR,  \ Select a column
        R12 0006 LI,    \ R12-address to read rows
             TOS SETO,  \ Make sure all bits are 1
       TOS  0008 STCR,  \ read 8 row values
             TOS INV,   \ pressed keys read as 0 so flip all bits
    EQ WHILE,
         R1 0100 AI,      \ Next column
         R1 0600 CI,      \ Are we done?
    EQ UNTIL,
    ENDIF,
    NEXT,              \ Return to Forth
 ENDCODE

: TEST  BEGIN  (KEY?)  .   ?TERMINAL UNTIL  ;


\
: TIMEKEY  TMR@  (KEY?) TMR@ NIP  - ABS 213 10 */ . ." uS " ;
\

\ used if you need debouncing
: WAITNOKEY  ( -- ) \ make sure no key is pressed
    BEGIN
    (KEY?) WHILE
    REPEAT ;

: WAITKEY   ( -- ) \ this waits for a key press and manages the cursor
    BEGIN
        PAUSE               \ Essential for Multi-tasking with Console
        CURS @              \ fetch 2 char cursor (space & _ )
        TMR@ 1FFF < IF >< THEN VPUT  \ swap cursor bytes & write
       (KEY?)
    UNTIL ;

\ over-write the old KEY, but use it for the ascii value
: KEY  ( -- c)  WAITKEY  KEY ;

HERE SWAP - DECIMAL .  .( bytes)
