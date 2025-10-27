\ FASTKEY is better for multi-tasking

\ KSCAN in the system ROM uses internal delays for debounce.
\ It takes 1.2 mS to run even if no key is pressed!
\ This slows down cooperative multi-tasking by slowing down
\ the context switch time while waiting for a key keypress.
\ KEYCHECK scans the keyboard in 191 uS or 8 times faster


\ NEEDS WORDLIST FROM DSK1.SUPERTOOLS
 NEEDS DUMP FROM DSK1.LOWTOOLS

\ Source:
\ http://www.unige.ch/medecine/nouspikel/ti99/keyboard.htm#quick%20scan
\ *--------------------------------------------
\ * Quick-and-dirty check to see if a key is pressed.
\ * If not return in a hurry,
\ * else call the standard scanning routine.
\ * Uses R1, R2 and R12.
\ *--------------------------------------------
\ KCHECK CLR  R1                 Start with column 0
\ LP1    LI   R12,>0024          R12-address for column selection
\        LDCR R1,3               Select a column
\        LI   R12,>0006          R12-address to read rows
\        SETO R2                 Make sure all bits are 1
\        STCR R2,8               Get 8 row values
\        INV  R2                 Since pressed keys read as 0
\        JNE  KPR                A key was pressed
\        AI   R1,>0100           Next column
\        CI   R1,>0600           Are we done
\        JNE  LP1                Not yet
\        B    *R11               No key pressed: return (with EQ bit set)

\ KPR    BLWP @KSCAN             Call KSCAN routine
\        INCT R11               (either) signal key by skipping a jump
\ *      MOV  R2,R2             (or) signal key by clearing the EQ bit
\        B    *R11               Return


HERE
HEX
CODE KEYCHECK ( -- ?)    \ return TRUE if any key pressed
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

:  TEST   BEGIN  KEYCHECK .   ?TERMINAL UNTIL ;

: FLUSHKEY  ( -- )  BEGIN KEYCHECK UNTIL ;

HEX
: WAITKEY   ( -- )
    FLUSHKEY                \ wait until no key pressed
    BEGIN
        PAUSE               \ Essential for Multi-tasking with Console
        CURS @              \ fetch 2 char cursor (space & _ )
        TMR@ 1FFF < IF >< THEN VPUT  \ swap cursor bytes & write
        KEYCHECK
    UNTIL ;

\ This new key waits faster but calls ROM kscan if key pressed
: NEWKEY  ( -- c)  WAITKEY KEY? ;

HERE SWAP - DECIMAL .  .( bytes)

\ test measure KEYCHECK using the 9901 timer
\ : TIMEIT  TMR@  KEYCHECK  TMR@ NIP - 2130 100 */ . ." uS"   ;