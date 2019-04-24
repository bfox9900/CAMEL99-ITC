\  >QPAD   from the Wil Baden toolbox

DECIMAL
: CHARS ;

CREATE  QHEAD  0 ,
CREATE  QBUF  1 CELLS ,  1024 CHARS ALLOT

: QPAD          ( -- addr )
        QHEAD @  896 AND CHARS  QBUF  DUP @ +  + ;

: >QPAD         ( addr n -- addr )
    128 QHEAD +!  QPAD  DUP >R  PLACE  R> ;
