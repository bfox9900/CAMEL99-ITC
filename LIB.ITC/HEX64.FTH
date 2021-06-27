\ HEX64.FTH converts string to 64bit integer

: CHOP   ( addr len n -- addr len addr' len' )
          >R                  \ Rpush n
          2DUP DROP R@        \ dup $, do left$
          2SWAP               \ put original $ on top
          R> /STRING ;        \ cut remainder string

: >UINT32 ( addr len -- d )   \ fast hex string->unsigned 32 bit integer
          BASE @ >R
          HEX
          0 0 2SWAP >NUMBER  ABORT" bad int"
          DROP
          R> BASE ! ;

\ Usage: S" FFFFFFFFFFFFFFFF" HEX64 65 CHARDEF
: >HEX64 ( addr len -- addr)
         8 CHOP 2SWAP         \ chop the stack string into 2 strings
         HERE >R              \ save dictionary position "HERE"
         PAD DP !             \ set DP to PAD location
         >UINT32 , ,          \ convert & compile 1st 2 integers
         >UINT32 , ,          \ convert & compile 2nd 2 integers
         R> DP !              \ restore dictionary position
         PAD ;                \ return the PAD address

\ Explanation for the Forth student:
\ Moves the dictionary pointer to PAD location to use comma
\ but... it puts the dictionary pointer back when it is done. :-)
