\ Calling a user-define ISR ported to CAMEL99 Forth 12 Feb 2018 BJF

\ http://www.unige.ch/medecine/nouspikel/ti99/ints.htm#hook

\ The ISR checks the word at >83C4 (the interrupt hook), if it contains a
\ non-zero value the ISR uses this value as a pointer to a user-defined routine. 
\ It branches to this routine via a BL instruction, with >83E0 as the workspace.

\ *****************************************************
\ * This means you MUST exit the ISR routine with RT, *
\ *****************************************************

\ This means that we can install an ISR of our own by placing its address in
\ address >83C4.

\ You could first check whether another program has already hooked the ISR
\ before installing your hook. This way you could chain the call to the other
\ program and not disturb anything. 
( BF thinks you should only have one routine hooked)

\ Four bits in byte >83C2 are used to enable/disable the first 3 functions:
\ If the first bit (weight >80) is set, the ISR jumps directly to point 4.
\ If the second bit (>40) is set, the ISR won't handle sprites.
\ If the third bit (>20) is set, the ISR won't process the sound list.
\ If the fourth bit (>10) is set, the ISR won't test the <quit> key.


\ simple counter example
NEEDS DUMP FROM DSK1.TOOLS
NEEDS MOV, FROM DSK1.ASM9900

\ example ISR
VARIABLE X

CODE COUNTER ( -- )
     X @@ INC,
     RT,
     ENDCODE

CREATE TIME32 0 , 0 ,

CODE DOUBLECOUNT
         TIME32 CELL+ @@ INC,
         OC IF,
              TIME32 @@ INC,
         ENDIF,
         RT,
         ENDCODE


: ?CODE ( cfa -- ) DUP @ 2- - ABORT" Not code word" ;

\ API
: ISR'  ( -- code-address)
        BL WORD  FIND  0= ABORT" ISR not found"
        DUP ?CODE >BODY ;


: INSTALL   83C4 ! ;

\ Usage:   ISR' COUNTER INSTALL
