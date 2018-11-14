\ HEXQUOTE is an helper for defining characters

\ Use PATTERN: when you need to KEEP the character data in your program.
\ ie: when you are changing characters in the running program.

\ Use HEX"  to change characters but NOT keep the pattern data in the program
\ (with HEX" the pattern data goes directly into VDP at compile time)

INCLUDE DSK1.TOOLS.F
INCLUDE DSK1.GRAFIX.F

: )!  ( n addr ndx -- ) CELLS +  ! ;  \ store n at addr(ndx)

: HEX"    ( <text> -- addr)
         BASE @ >R                \ save the base
         HEX                      \ switch to HEX
         [CHAR] " PARSE           \ PARSE input as a string
         EVALUATE                 \ evaluate the numbers
         ( -- n1 n2 n3 n4 )       \ numbers are on data stack

\ use Forth PAD as a temporary array to hold converted HEX numbers
         PAD 3 )!          \ n4 to pad(3)
         PAD 2 )!          \ n3 to pad(2)
         PAD 1 )!          \ n2 to pad(1)
         PAD 0 )!          \ n1 to pad(0)
         PAD               \ put PAD addr on stack for CHARDEF
         R> BASE !         \ restore the previous base
;

\ Usage:

\ DECIMAL
\ HEX" F0F0 F0F0 F0F0 F0F0" 65 CHARDEF     ( 65 is ASCII A)

\ -or- use Forth's CHAR to get ASCII value
\ HEX" E0E0 E0E0 E0E0 E0E0" CHAR B CHARDEF

