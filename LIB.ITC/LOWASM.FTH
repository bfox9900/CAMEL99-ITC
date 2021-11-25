CR .( Compile ASM9900
HEX
VARIABLE SAVEDP
LATEST @ CONSTANT KEEP  \ remember latest name field address

CR .( Set up low ram compiling ...)
  HERE SAVEDP !      \ save the dictionary pointer.
  H @  DP !

  INCLUDE DSK1.ASM9900

HEX
CR .( Restore high ram compiling ...)
 HERE  H !        \ give back what we didn't use to the HEAP
 SAVEDP @ DP !    \ restore DP back to original address

: REMOVE-ASM ( -- )
         KEEP SAVEDP @ !  \ relink the dictionary
         2000 H ! ;
DECIMAL
