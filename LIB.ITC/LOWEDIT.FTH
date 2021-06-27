CR .( Compile Tools in LOW RAM)
NEEDS MALLOC FROM DSK1.MALLOC
HEX
VARIABLE SAVEDP

 LATEST @ CONSTANT KEEP  \ remember latest name field address

CR .( Set up low ram compiling ...)
  HERE SAVEDP !      \ save the dictionary pointer.
  1E00 MALLOC DP !   \ get a buffer in low ram, Point DP to the buffer

\ *INSIGHT*
\ SAVEDP holds the LINK field of the 1st new word we will create in HI RAM
  INCLUDE DSK3.ED99LOW

: REMOVE-TOOLS ( -- )
         KEEP SAVEDP @ !  \ relink the dictionary
         2050 H ! ;       \ init-the heap. (80 byte buffer is at >2000)

CR .( Restore high ram compiling ...)
 HERE H !          \ give back what we didn't use to the HEAP
 SAVEDP @ DP !     \ restore DP back to original address

: ED99 ;    \ DUMMY word to link to dictionary
HEX
