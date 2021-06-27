\ MUSER99.HSF for CAMEL99                       16AUG2020 Brian Fox
\ Multi-user system for SAMS Memory Card

\ NEEDS DUMP  FROM DSK1.TOOLS
NEEDS MOV,   FROM DSK1.ASM9900
NEEDS MALLOC FROM DSK1.MALLOC

\ Each task has a Process ID (PID)
\ In this system we use the workspace address as the PID
\ Each task swaps out HEX B000..FFFF for a task
HEX
CODE MYSELF  ( -- pid)
     0646 , \    *SP DECT,  ( make room on stack)
     C584 , \ TOS *SP MOV,  ( push TOS reg.)
     02A4 , \    TOS STWP,  (fetch the cpu WP register to Forth TOS)
     NEXT,
    ENDCODE

MYSELF CONSTANT USER0    \ USER0 is the main Forth task workspace (>8300)

\ Extended "workspace" is 256 BYTES (>100)
\ Each workspace includes registers, user variables
\ the data stack & return stack.
HEX 100 CONSTANT USIZE

DECIMAL
\ name the CPU register addresses in a task's workspace
  12 USER 'SP             \ the task's Forth SP register ( R6)
  14 USER 'RP             \ the task's Forth RP register ( R7)
  18 USER 'IP             \ the task's Forth IP register ( R8)
  20 USER 'R10            \ address of R10 (holds the NEXT routine)

\ rename registers 13,14,15, used by RTWP to change context
  26 USER TLINK           \ R13 = next task's wksp
  28 USER TPC             \ R14 = next task's program counter
  30 USER TST             \ R15 = next task's status register
HEX

\ SAMS memory manager starts at page >FF. allocation decrements
VARIABLE MP  8000  MP !  \ 1st SAMS page = >80, 500Kb

\ Compile next SAMS page into array, decrement Memory pointer MP
: SAMS,    MP @ DUP ,   0100 + MP !  ;

\ create map arrays for 3 users
CREATE MAP0  0B00 , 0C00 , 0D00 , 0E00 , 0F00 , \ pass through values
CREATE MAP1  SAMS,  SAMS,  SAMS,  SAMS,  SAMS,  \ MAP array for USER1
CREATE MAP2  SAMS,  SAMS,  SAMS,  SAMS,  SAMS,  \ MAP array for USER2

\ each user has a variable that points to their MAP array
  6E USER MEM      MAP0 MEM !   \ pass thru pages are default

HEX
CODE YIELD \ *this is the context switcher
\ Address of TSTAT is loaded into R14 of every task. ie program counter)
     BEGIN,
         RTWP,                \ change tasks! 1 instruction
( TSTAT) R1 STWP,             \ get our workspace -> R1
         20 R1 () R0 MOV,     \ fetch TFLAG->R0
     NE UNTIL,               \ if tflag=0 jmp to RTWP

     6E R1 ()  R2 MOV,       \ get MEM map array -> R2
     R12 1E00  LI,      \ MAPPER CODE
     0 SBO,             \ card on
     R0  4016  LI,      \ HI ram SAMS register for B000
     R2 *+  R0 *+ MOV,  \ MAP B000
     R2 *+  R0 *+ MOV,  \ MAP C000
     R2 *+  R0 *+ MOV,  \ MAP D000
     R2 *+  R0 *+ MOV,  \ MAP E000
     R2 *+  R0 ** MOV,  \ MAP F000
     0 SBZ,             \ card off
     NEXT,              \ run Forth
ENDCODE

' YIELD >BODY    CONSTANT 'YIELD
'YIELD 1 CELLS + CONSTANT 'TSTAT       \ entry address of tstat
'YIELD 8 CELLS + CONSTANT 'MAPPER   \ entry address of MAPPER

CODE MAPPER  ( map[] -- )
          TOS R0 MOV,
          TOS POP,
          'MAPPER @@ B,
          ENDCODE

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
        MYSELF TLINK !    \ Set my TLINK to my own Workspace
       'TSTAT TPC !       \ set my task PC register to TSTAT
        MYSELF WAKE  ;    \ mark myself awake

\ FORK
\ - copy the the calling task's USER area into a new workspace.
\ - SET both stack addresses to the proper registers in the user area,
\ - insert PID into the round-robin list
\ - your program needs to allocate USIZE bytes in heap
\ - the address of your memory block will become the PID.

: FORK ( PID -- )
       DUP >R                               \ copy PID to RSTACK
      ( PID) USIZE 0 FILL                   \ erase new task block
       MYSELF R@ USIZE CMOVE                \ copy myself to the new task

       R@ USIZE +  ( addr )                 \ calc. end of task block
       DUP R@ 'RP LOCAL !                   \ dup & store in local RP
     ( RPaddr) 22 CELLS -                   \ calc. Pstack addr
       R@ 'SP LOCAL !                       \ store in local SP register

\ insert this task into round-robin list of tasks
       TLINK @                 ( -- link)   \ get round-robin link
       R@ TLINK !                           \ replace with addr of new task
       R@ TLINK LOCAL !                     \ store copy in new task's tlink
       R> SLEEP ;                           \ mark this new task as asleep

.( ..)
: JOB->IP ( xt pid -- xt pid)     \ XT -> task's IP register
       DUP JOB LOCAL  OVER 'IP LOCAL ! ;

: ASSIGN ( xt pid -- )
       JOB->IP  JOB LOCAL ! ; \ store the XT in the PID's JOB user var.

: RESTART ( pid -- )
       JOB->IP
       DUP USIZE +  OVER 'RP LOCAL !  \ reset local Rstack
       WAKE ;                         \ pid wake

\ overwrite these commands for mulit-tasking
: COLD  ( -- ) SINGLE  COLD ;  \ stop multi-tasker before quitting Forth
: BYE   ( -- ) SINGLE  BYE ;

HEX
: PROCESS: ( map[] -- )
          USIZE MALLOC  ( -- workspace )
          DUP FORK                 \ copy current workspace
          TUCK MEM LOCAL !         \ set local MEM to map array
          B000 OVER DP LOCAL !     \ set local dictionary pointer to B000
          CONSTANT ;               \ name this workspace

INIT-MULTI
CR .( Multi-tasker initialized)

HEX
