\ CALLCHAR FONT COMPILER  ~10 seconds to load font source code into RAM

: pdt[]  ( ascii -- Vaddr) 8* 800 + ;  \ Compute pattern address of ascii

: CHOP   ( addr len n -- addr len addr' len' )
          >R                  \ Rpush n
          2DUP DROP R@        \ dup $, do left$
          2SWAP               \ put original $ on top
          R> /STRING ;        \ cut remainder string

: >UINT32 ( addr len -- d )   \ fast hex string->unsigned 32 bit integer
          BASE @ >R
          HEX
          0 0 2SWAP >NUMBER ABORT" bad int"
          DROP
          R> BASE ! ;

\ Usage:  65 S" FFFFFFFFFFFFFFFF" CALLCHAR
: CALLCHAR ( char addr len -- addr)
         8 CHOP 2SWAP         \ chop the stack string into 2 strings
         HERE >R              \ save dictionary position "HERE"
         >UINT32 , ,          \ convert & compile 1st 2 integers
         >UINT32 , ,          \ convert & compile 2nd 2 integers
          R@ SWAP pdt[] 8 VWRITE   \ write data from HERE to PDT
          R> DP ! ;           \ restore dictionary position

\ Explanation for the Forth student:
\  CALLCHAR uses 8 bytes of dictionary space by invoking comma
\  but... it puts the dictionary pointer back when it is done. :-)