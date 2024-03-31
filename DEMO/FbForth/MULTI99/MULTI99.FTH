\ MULTI99.FTH for FbFORTH                27 APR2021 Brian Fox
\ Derived from COOPTASK.MAX for MaxForth 68HC11  B Fox 1992
\ Forth multi-tasker using a single workspace with separate
\ data stack, return stack and user area for each task.

21 LOAD   \ needs the Assembler

FORTH DEFINITIONS

 1 CONSTANT TRUE
 0 CONSTANT FALSE

\ PID (process I.D.) is the base address of a user area
\  orignal name was MYSElf. Already used in FigForth
ASM: ME   ( -- PID)    SP DECT,  UP *SP MOV,   ;ASM
ASM: UP!  ( addr -- )  *SP+ UP MOV,   ;ASM

ME CONSTANT USER0    \ USER0 is the primary Forth task

\  add these user variables to FbFORTH
HEX
 6E USER RSAVE    \ temp storage for RP register
 70 USER TFLAG    \ flag for awake or asleep
 72 USER TLINK    \ link to next task
 74 USER JOB      \ copy of running XT

( ***  CALL INIT-MULTI ONCE before multi-tasking  ***)
: INIT-MULTI ( -- )
     USER0 UP!         \ reset root user-pointer register
     ME TLINK !        \ round robin links to ME
     TRUE TFLAG !  ;   \ mark my task flag as AWAKE

\ Coventional Forth context switcher
ASM: YIELD  ( -- )
     RP DECT,  SP *RP MOV, \ Rpush SP
     RP DECT,  IP *RP MOV, \ Rpush IP
     RP  6E @(UP) MOV,     \ RP -> LOCAL RSAVE

     BEGIN,
        72 @(UP) UP MOV,   \ switch context
        70 @(UP) R0 MOV,   \ test this tflag for zero
     NE UNTIL,             \ until a task is awake

     6E @(UP) RP MOV,      \ restore RP this task
     RP *+ IP MOV,         \ pop this task's IP
     RP *+ SP MOV,         \ pop this task's SP
;ASM                       \ run NEXT

\ 833A CONSTANT 'NEXT        \ for patching SINGLE

HEX
 80 CONSTANT USTACKS          \ 20 cells per stack per task
 USTACKS 2 * CONSTANT USIZE   \ FbForth USER area + STACKS

DECIMAL
\ compute address of a USER variable in any PID
\ Editors note: LOCAL is clever. Comes from early Forth
\ multi-tasking systems. Usage:  TASK1 RSAVE LOCAL @
: LOCAL   ( PID uvar -- addr) ME -  + ;

: SLEEP  ( PID -- )  FALSE SWAP TFLAG LOCAL ! ;
: WAKE   ( PID -- )  TRUE  SWAP TFLAG LOCAL ! ;

HEX
\ compute base address of the local stacks in a PID
: TASK-SP0  ( PID -- addr) USIZE +  40 - ;
: TASK-RP0  ( PID -- addr) USIZE +   2-  ;

\  used to push values onto a local return stack
: TASK-RP-- ( PID -- ) -2 SWAP RSAVE LOCAL +! ;
: TASK>R  ( n PID -- ) DUP TASK-RP--  RSAVE LOCAL @  ! ;

: INIT-USER  ( PID -- PID)
     DUP USIZE FF FILL  \ init whole user area for debugging
     USER0 OVER 80 CMOVE ;  \ copy USER0's user variables

: SET-RP0  ( PID -- PID)  DUP TASK-RP0 OVER RSAVE LOCAL ! ;
: SET-SP0  ( PID -- PID)  DUP TASK-SP0 OVER TASK>R ;

\ add PID to round-robin list
: LINK-TASK  ( PID -- PID)
     TLINK @         ( -- pid previous)
     OVER TLINK !    ( -- pid )
     OVER TLINK LOCAL !
;

: FORK  ( PID -- )
        INIT-USER  \ copy USER0 into a new task
        SET-RP0    \ set this RP0
        LINK-TASK  \ insert into round robin
        SET-SP0    \ set this SP0
        SLEEP      \ don't wake me up yet :)
;

: ASSIGN ( XT PID -- )
       OVER OVER JOB LOCAL !  \ keep a copy for restarting
       TASK>R ;               \ push PFA onto local rstack

DECIMAL
INIT-MULTI  ( setup the USER0 for mult-tasking)
