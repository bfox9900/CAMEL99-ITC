\ SUBPROG.FTH    create ASM sub-routines that are called from Forth
NEEDS BLWP,  FROM DSK1.ASM9900


: PROG: ( wksp -- )
       CREATE
         ( wksp) ,  HERE CELL+ ,
         !CSP
      ;CODE *W BLWP,
               NEXT,
            ENDCODE

: ;PROG  ( -- ) ?CSP  ;  \ check stack position for junk left on it.
