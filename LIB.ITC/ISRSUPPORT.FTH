\ User-define ISR lexicon for CAMEL99 Forth   12 Feb 2018 BJF

\ http://www.unige.ch/medecine/nouspikel/ti99/ints.htm#hook

\ The TI-99 interrup service routine (ISR_ checks the word at >83C4
\ (the interrupt hook). If it contains a non-zero value the ISR uses this
\ value as a pointer to a user-defined routine. It branches to this routine
\ via a BL instruction, with >83E0 as the workspace.
\         ***  YOU MUST EXIT THE ISR ROUTINE WITH RT, ***

\ We can install an ISR of our own by placing its address in address >83C4.

\ Example of a simple ISR than increments a variable continuously
 INCLUDE DSK1.LOWTOOLS

 VARIABLE t       \ Fetch 't' to get a time
 CODE timer ( -- )
    t @@ INC,
    RT,
    ENDCODE

: ?CODE ( cfa -- ) DUP @ 2- - ABORT" Not code word" ;

\ API
: ISR'  ( -- code-address)
        ?EXEC
        BL WORD  FIND  0= ABORT" ISR not found"
        DUP ?CODE >BODY ; IMMEDIATE
HEX
: INSTALL ( isr-addr -- ) 83C4 ! ;
\ Usage:
  ISR' timer INSTALL

DETACH
