CR .( Compile code into another RAM location and remove it later)
\ SEE: DSK1.LOWTOOLS DSK1.SUPERTOOLS for demo code
HEX
VARIABLE SAVEDP
VARIABLE OLDNFA  \ LINK field of the 1st new word we will create in HI RAM

: TRANSIENT ( NEWDP -- ) \ Usage   HEX 2000 TRANSIENT
           LATEST @ OLDNFA !
           HERE SAVEDP !     \ save the dictionary pointer.
           DP ! ;            \ Point DP to transient memory

: PERMANENT ( -- ) ( Restores high ram compiling )
           HERE H !          \ give back what we didn't use to the HEAP
           SAVEDP @ DP !     \ restore DP back to original address

         \ built a dummy word as the link to the permanent dictionary
          S" $$$$" HEADER, COMPILE DOCON  HERE ,  COMPILE EXIT
;

: ERADICATE ( -- ) ( removes TRANSIENT dictionary code)
          OLDNFA @  LATEST !  \ relink the dictionary
          2000 H ! ;          \ init-the heap.
