## INLINE Code
Dec 5 2017

XFCC99 gives you the ability to write inline Assembly language inside of a colon definition. 
This requires that you understand some internals of how CAMEL99 goes together but the system 
also provides you with some MACROS to make the job a little easier.

See:  /DOCS/Camel99 for TI-Basic Programmers  
Chapter:  The Assembler

An example always helps to explain things:

: DUP@.  ( adr – adr n)  ASM[ TOS PUSH,  *TOS TOS MOV,  ]ASM  . ;

The example above is a COLON definition but it uses ASM[    ]ASM to jump into machine code inside the definition. 
It Pushes a copy of the top of stack register (TOS), fetches the contents and prints the number to the screen.  Notice 
how we entered Assembly language then exited back to Forth to use the “dot” word to print the number from the TOS.
Once inside ASM[  we use the cross-assembler, re-named registers and an assembler Macro to PUSH a copy of the top of 
stack register (TOS) onto the stack.  This is just like using the word DUP in Forth. Then we fetch the contents of the 
register into the TOS using indirect addressing.

Compare the code above to the source code for DUP and @ from the CAMEL99 Forth source code:
CODE: DUP    ( w -- w w )  TOS PUSH,       NEXT, END-CODE
CODE: @      ( a -- w )   *TOS TOS MOV,    NEXT, END-CODE

Notice they are the same code. Also notice that at the end of each CODE: definition there is the MACRO “NEXT,” .  
This is the Forth “inner interpreter” and although it is pretty fast at only 3 instructions it still takes 19 micro-seconds to run.  The code for @ only takes 6 uS so it is spending 75% of its time running NEXT.  So for a time critical routine our DUP@ word would be 2X faster.

### Stealing Code
Another way to do the same thing is to create a new "CODE:"  word and “steal” the machine code from the Forth system.  We can do this with the word  CODE[  .   CODE[ finds the machine code for any ASM word in the Forth system and copies it in a new location.  If we needed our DUP@ word in many places it would be better to give it a name and code it like this :
CODE:  DUP@  CODE[ DUP @ ]  NEXT,  END-CODE

### INLINE CODE 
And the third way we could do this is to use INLINE[ .  INLINE[ works just like CODE[ but it knows how to leave a threaded code word , enter the ASM code and return back to the Forth threaded word.  There is a small speed penalty at each end of this process so use INLINE[ wisely.  It also increases the size of your code GREATLY because it is literally making a copy of the machine code of each Forth word that you put INLINE[   ].
: DUP@ INLINE[ DUP @ ] . ;