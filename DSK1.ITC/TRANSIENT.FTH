\ transient compilation                         Jan 2022 Brian Fox
CR .( Compile code into another RAM location and remove it later)
\ SEE: DSK1.LOWTOOLS DSK1.SUPERTOOLS for demo code

INCLUDE DSK1.TOOLS

HEX
VARIABLE SAVEDP
VARIABLE OLDNFA  \ LINK field of the 1st new word we will create in HI RAM
VARIABLE OLDH    \ where the HEAP (low RAM) was in the beginning

: ?TWICE   SAVEDP @ ABORT" Can't do twice"  ;

: CFA>NFA ( cfa -- nfa | 0 ) 2- BEGIN   1- DUP C@ 0FE AND  0= UNTIL 1+  ;
: >LINK   ( cfa -- lfa) CFA>NFA NFA>LFA ;

: RELINK ( CFA1 CFA2 -- )
        SWAP CFA>NFA
        SWAP >LINK  ! ;

: PERMANENT ( -- ) ( Restores high ram compiling )
           HERE 4000 < IF  HERE H ! THEN  \ set H if in LOW RAM
           SAVEDP @ DP !     \ restore DP back to original address
         \ built a dummy word as the link to the permanent dictionary
          S" PERM" HEADER, COMPILE DOCON  HERE ,  COMPILE EXIT
;

: ERADICATE ( -- ) ( removes TRANSIENT dictionary code)
          SAVEDP @ 0= ABORT" Nothing to eradicate"
          OLDNFA @  LATEST !  \ relink the dictionary
          SAVEDP OFF
          OLDH @ H ! ;          \ init-the heap.

: TRANSIENT ( NEWDP -- ) \ Usage   HEX 2000 TRANSIENT
           ?TWICE
           H @ OLDH !
           LATEST @ OLDNFA !
           HERE SAVEDP !     \ save the dictionary pointer.
           DP !              \ Point DP to transient memory
          S" TRANS" HEADER, COMPILE DOCON  HERE ,  COMPILE EXIT
;

HEX 2000 TRANSIENT
: TRANS1 ;
: TRANS2 ;

INCLUDE DSK1.ASM9900

PERMANENT

: PERM1 ;
: PERM2 ;
