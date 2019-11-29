\ FASTKEY is better for multi-tasking

\ KSCAN in the system ROM uses internal delays for debounce.
\ It takes 1.2 mS to run even if no key is press!
\ This messes up cooperative multi-tasking by slowing down the context switch time.

NEEDS MOV, FROM DSK1.ASM9900

\ Source:
\ http://www.unige.ch/medecine/nouspikel/ti99/keyboard.htm#quick%20scan
\ *--------------------------------------------
\ * Quick-and-dirty check to see if a key is pressed.
\ * If not return in a hurry,
\ * Uses R1, R2 and R12.
\ *--------------------------------------------
HEX
CODE KCHECK  ( -- ?)  \ was any key pressed
       TOS PUSH,
       TOS CLR,           \ TOS=false
       R1 CLR,            \ Start with column 0
       BEGIN,
        R12 0024 LI,      \ R12-address for column selection
        R1  0003 LDCR,    \ Select a column
        R12 0006 LI,      \ R12-address to read rows
              R2 SETO,    \ Make sure all bits are 1
        R2  0008 STCR,    \ Get 8 row values
              R2 INV,     \ Since pressed keys read as 0
        NE IF,            \ A key was pressed
               TOS SETO,  \ TOS=true
               NEXT,      \ return to Forth
        ENDIF,
        R1 0100 AI,       \ Next column
        R1 0600 CI,       \ Are we done
       EQ UNTIL,
       NEXT,              \ No key pressed: return with TOS RESET
       ENDCODE

: TEST
      BEGIN
        KCHECK .
        ?TERMINAL ABORT" HALT"
      AGAIN ;