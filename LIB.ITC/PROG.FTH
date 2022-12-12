\ PROG.FTH creates ASM sub-routines in foreign workspace.
\ When a PROG is invoked it automatically BLWPs itself
\ You MUST define a 32 byte workspace to use with PROGS.
\ Different PROG:s then can use the same workspace because it is a parameter
\ at compile time.
: PROG: ( wksp -- )
   CREATE    ,  HERE CELL+ ,  !CSP
  ;CODE   0418 ,  ( *W BLWP, )  NEXT, ENDCODE

: ;PROG  ( -- ) ?CSP  ;  \ check stack position for junk left on it.

\ macro to give you Forth's TOS register from a foreign workspace
: [TOS]  ( -- ) ?EXEC  8  R13 () ; IMMEDIATE
