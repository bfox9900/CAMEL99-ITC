\ INIT: Set Workspace, copy code to scratch pad, set stacks, run BOOT

[cc] HEX

TARGET-COMPILING
CODE COLD
              WRKSP0 LWPI,
              R0 HSprims LI,   \ source
              R1 HSstart LI,   \ destination
              BEGIN,           \ Copy hi-speed routines to fast RAM
                *R0+ *R1+ MOV,
                 R1 HSend CMPI,
              EQ UNTIL,
              SP  SP0  LI,     \ data stack
              RP  RP0  LI,     \ return stack
              R10 NEXT2 LI,    \ inner interpreter
              IP  BOOT  LI,    \ load interpreter pointer with boot word
             *R10 B,           \ run Forth (inner interpreter)
              ENDCODE

\ *G MOVED TO DSK1.SYSTEM ** loads on Forth startup
\ *G : CODE      ( -- )  HEADER  HERE 2+ , !CSP ;
\ *G : NEXT,     ( -- )  045A , ;  \ B *R10
\ *G : ENDCODE   ( -- )  ?CSP  ;
\ *G ;CODE is moved to DSK1.SYSTEM ***

\ *new* Added VER string for easy updates
: VER  TS" 2.68G" ;

[CC] HEX
\ ======================================================================
\ B O O T   U P   C O D E
TARGET-COMPILING
: WARM       ( -- )
\ *G restarts Forth but does not load DSK1.START
              80 83C2 C!                    \ disable user interrupts
              26 TPAD !                     \ HERE + 38 bytes for root task PAD
              1000 VP !                     \ reset VDP memory manager
              2000  H !                     \ reset HEAP, +16 bytes for DSRLINK
              3FFF TMR!                     \ start 9901, enable interrupts too
              VDPTOP ^PAB !                 \ reset PAB stack in VDP RAM
            t['] <INTERP> 'IV !             \ PATCH interpreter vector
            t['] <FIND>   'FIND !           \ set find action
              ORGDP @ DP !                  \ restore dictionary
              ORGLAST @ LATEST !            \ restore last word pointer
              LATEST DUP CONTEXT ! CURRENT !  \ FORTH DEFINITIONS
              FLOOR ON
              TEXT                          \ VDP start screen
              T." CAMEL99 Forth " VER TYPE
              DECIMAL                       \ default to base 10
;

: LOADSYS        WARM
\ *G performs WARM start includes DSK1.START and runs ABORT
              TS" DSK1.START" INCLUDED
              ABORT ;
