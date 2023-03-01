\ convert long text string to 16 bit HEX numbers and
\ compile each number into memory sequentially

: HEX#, ( addr len  --)
        BASE @ >R        \ save radix
        HEX              \ converting string to hex numbers
        BEGIN DUP
        WHILE            \ while len<>0
           OVER 4        \ used 4 digits from left end of string
           NUMBER? ?ERR  \ convert string to number
           ,             \ compile the integer into memory
           4 /STRING     \ cut 4 digits off left side of string
        REPEAT           \ keep going until string is exhausted
        2DROP
        R> BASE !        \ restore radix
;

\ Usage:
\ DECIMAL
\ CREATE ASTEROIDS
\ S" 000F191032434964504C23100C0700000000C020501098CC1272941CF0000000" HEX#,