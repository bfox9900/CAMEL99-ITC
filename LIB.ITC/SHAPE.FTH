\ shape.fth  as written in artiage August 16, 2018 by TheBF
\ character pattern definer than changes the pattern of an character.

NEEDS PDT FROM DSK1.GRAFIX

: CHOP   ( addr len n -- addr len addr' len' )
          >R                  \ Rpush n
          2DUP DROP R@        \ dup $, do left$  ** see footnote:
          2SWAP               \ put original $ on top
          R> /STRING ;        \ cut remainder string

: >UINT32 ( addr len -- d )   \ hex string->unsigned 32 bit integer
          BASE @ >R
          HEX
          0 0 2SWAP >NUMBER ABORT" bad int"
          DROP
          R> BASE ! ;


: SHAPE: ( addr len -- addr)
\ COMPILE TIME behavioue
         CREATE               \ create a name in dictionary
         8 CHOP 2SWAP         \ chop the stack string into 2 strings
         >UINT32 , ,          \ convert & compile 1st 2 integers
         >UINT32 , ,          \ convert & compile 2nd 2 integers

\ RUNTIME behavior
         DOES> ( char DataAddr -- )   \ CHAR X ASQUARE changes X to a square
            SWAP ]PDT 8 VWRITE ;  \ compute PDT address of char
                                  \ write 8 bytes to VDP

\ Compile Usage: S" FFFFFFFFFFFFFFFF" SHAPE: ASQUARE
\ Run time Usage:   129 ASQUARE ( 129 changes to ASQUARE)