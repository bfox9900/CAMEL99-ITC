\ PROG.FTH creates ASM sub-routines in foreign workspace. Called from Forth
: PROG: ( wksp -- )
   CREATE    ,  HERE CELL+ ,  !CSP
   ;CODE   0418 ,  ( *W BLWP, )  NEXT, ENDCODE
: ;PROG  ( -- ) ?CSP  ;  \ check stack position for junk left on it.
\ macro to give you Forth's TOS register from a foreign workspace
: [TOS]  ( -- ) ?EXEC  8  R13 () ; IMMEDIATE

