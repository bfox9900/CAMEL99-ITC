CR .( Compile Tools in LOW RAM)
HEX
VARIABLE SAVEDP

 LATEST @ CONSTANT KEEP  \ remember latest name field address

CR .( Set up low ram compiling ...)
  HERE SAVEDP !      \ save the dictionary pointer.
  1E00 MALLOC DP !   \ get a big buffer, DP now points to the buffer

\ *INSIGHT*
\ SAVEDP holds the LINK field of the 1st new word we will create in HI RAM
  INCLUDE DSK1.ELAPSE
  INCLUDE DSK1.TOOLS
  INCLUDE DSK1.ASM9900

: REMOVE-TOOLS ( -- )
         KEEP SAVEDP @ !  \ relink the dictionary
         2000 H ! ;       \ init-the heap. (80 byte buffer is at >2000)

CR .( Dictionary end = ) HERE HEX  .
CR .( HEAP used = )  HERE HEX 2000 - DECIMAL .

HEX
CR .( Restore high ram compiling ...)
 HERE  H !        \ give back what we didn't use to the HEAP
 SAVEDP @ DP !    \ restore DP back to original address

: LOWTOOLS ;      \ DUMMY word to link to dictionary

.FREE
HEX
