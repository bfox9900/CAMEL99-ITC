CR .( Compile Tools in LOW RAM)
NEEDS MALLOC FROM DSK1.MALLOC
HEX
VARIABLE SAVEDP
VARIABLE KEEP

CR .( Set up low ram compiling ...)
\ *INSIGHT*
\ SAVEDP holds the LINK field of the 1st new word we will create in HI RAM
\ Usage  2050 LATEST @ TRANSIENT
: TRANSIENT ( addr latest  -- )
                KEEP !
           HERE SAVEDP !     \ save the dictionary pointer.
           DP ! ;            \ Point DP to transient memory

CR .( Restore high ram compiling ...)
: PERMANENT ( -- )
           HERE H !          \ give back what we didn't use to the HEAP
           SAVEDP @ DP ! ;   \ restore DP back to original address

: ERADICATE ( -- )
          KEEP @ SAVEDP @ !  \ relink the dictionary
          2050 H ! ;         \ init-the heap. (INCLUDE buffer is at >2000)
