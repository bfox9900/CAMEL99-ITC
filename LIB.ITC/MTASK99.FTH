
\ MTASK99.HSF for CAMEL99                              06JAN2017 Brian Fox
\ SEE: Manual "CAMEL99 for TI-BASIC Programmers" for full explanation

\ May 15 2017  RE-wrote for use with new Kernel that includes USER variables
\ Jan 31 2018 -big cleanup. Simplified stack location code. 
\             - USIZE now 152 bytes
\             -RESTART command now POPs local Rstack. It was overflowing
\             -with repeated RESTARTs.
\ Apr 2018    Ported to V2 and used machine code. No need for assember
\ May 17, 2018  fixed RESTART, BYE, COLD.
\ Jun  8. 2018  replaced assembler with machine code to ease of use.

\ INCLUDE DSK1.ASM9900.F
\ INCLUDE DSK1.TOOLS.F

' CODE  DROP   \ test if we have CODE ENDCODE

\ Each task has a Process ID (PID)
\ In this system we use the workspace address as the PID
HEX
CODE MYSELF  ( -- pid)
             0646 , \    *SP DECT,  ( make room on stack)
             C584 , \ TOS *SP MOV,  ( push TOS reg.)
             02A4 , \    TOS STWP,  (fetch the cpu WP register to Forth TOS)
             NEXT,
             ENDCODE

MYSELF CONSTANT USER0      \ USER0 is the main Forth task workspace (>8300)

\ calc. size of task memory block (152 bytes)
DECIMAL                                                        
     16 CELLS              \ register space
     40 CELLS +            \ 40 USER VARIABLE spaces
     20 CELLS +            \ 20 cells for parameter stack
     20 CELLS +            \ 20 cells return stack
     CONSTANT USIZE        \ "user area" size

\ name the CPU register addresses in a task's USER VARIABLE space
  12 USER 'SP             \ the task's Forth SP register ( R6)
  14 USER 'RP             \ the task's Forth RP register ( R7)
  18 USER 'IP             \ the task's Forth IP register ( R8)
  20 USER 'R10            \ address of R10 (holds the NEXT routine)

\ rename registers 13,14&15, used by RTWP to change context
  26 USER TLINK           \ R13 = next task's wksp
  28 USER TPC             \ R14 = next task's program counter
  30 USER TST             \ R15 = next task's status register

\ tricky machine code version so you don't need to
\ load the assembler
\ use CREATE cuz we just need the address
HEX
CREATE 'YIELD \ *this is the entire context switcher
      0380 ,         \ RTWP,                \ change tasks! :-)
HERE  02A1 ,         \ R1 STWP,             \ HERE on stack for later
      C021 , 20 ,    \ HEX 20 (R1) R0 MOV,  \ fetch TFLAG->R0
      13FB ,         \ -8 $$+ JEQ,          \ if tflag=0 jmp to RTWP
      NEXT,          \ run Forth
 ( -- addr) CONSTANT 'TSTAT  \ record tstat address as constant

 'R10 @ CONSTANT 'NEXT      \ R10 has the address of Forth NEXT

.( ..)
 DECIMAL
\ PID = process ID.  It is the address of the task's user area memory block
: LOCAL    ( PID uvar -- addr' ) MYSELF - + ;     \ get a task's user var.
: SLEEP    ( PID -- ) FALSE SWAP TFLAG LOCAL ! ;  \ put PID to sleep
: WAKE     ( PID -- ) TRUE  SWAP TFLAG LOCAL ! ;  \ wake up PID

\ turn multi-tasking on or off by changing the CODE address in PAUSE
: SINGLE   ( -- ) 'NEXT  ['] PAUSE ! ;  \ disable multi-tasking
: MULTI    ( -- ) 'YIELD ['] PAUSE ! ;  \ enable multi-tasking.

( *** YOU  M U S T  use INIT-MULTI before multi-tasking ***)
: INIT-MULTI ( -- )
                MYSELF TLINK !    \ Set my TLINK to my own WKSP
                'TSTAT TPC !      \ set my task PC reg. to TSTAT
                MYSELF WAKE  ;    \ mark myself awake

\ FORK
\ - copy the the calling task's USER area into a new workspace.
\ - SET both stack addresses to the proper registers in the user area,
\ - insert PID into the round-robin list
\ - your program needs allot USIZE (176) bytes somewhere.
\ - the address of your memory block will become the PID.

\          *** THESE ARE VERY SMALL TASK BLOCKS ***
\ 20 stack items is the theoretical minimum for a Forth process
: FORK ( PID -- )
       DUP >R                               \ copy PID to RSTACK
      ( PID) USIZE 0 FILL                   \ erase new task block
       MYSELF R@ USIZE CMOVE                \ copy myself to the new task

       R@ USIZE +  ( addr )                 \ calc. end of task block
       DUP R@ 'RP LOCAL !                   \ dup & store in local RP
     ( RPaddr) 20 CELLS -                   \ calc. Pstack addr
       R@ 'SP LOCAL !                       \ store in local SP register

\ insert this task into round-robin list of tasks
       TLINK @                 ( -- link)   \ get round-robin link
       R@ TLINK !                           \ replace with addr of new task
       R@ TLINK LOCAL !                     \ store copy in new task's tlink
       R> SLEEP ;                           \ mark this new task as asleep

.( ..)

: JOB->IP ( xt pid -- xt pid)  \ local JOB->local IP register
           DUP JOB LOCAL  OVER 'IP LOCAL ! ;

: ASSIGN ( xt pid -- )
           JOB->IP  JOB LOCAL ! ; \ store the XT in the PID's JOB user var.

: RESTART ( pid -- )
           JOB->IP
           DUP USIZE +  OVER 'RP LOCAL !  \ reset local Rstack
           WAKE ;                         \ pid wake

: COLD  ( -- ) SINGLE  COLD ;  \ gotta stop multi-tasker before quitting Forth
: BYE   ( -- ) SINGLE  BYE ;

INIT-MULTI
CR .( Multi-tasker initialized)

HEX

