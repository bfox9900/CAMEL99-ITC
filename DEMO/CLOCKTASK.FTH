CR .( Clock based on the TI-99 Interrupt counter)
CR .( Updated 5JUL2022  B Fox)
CR .( Uses ISR and background task)

NEEDS FORK    FROM DSK1.MTASK99
NEEDS MALLOC  FROM DSK1.MALLOC
NEEDS INSTALL FROM DSK1.ISRSUPPORT

\ LOWTOOLS uses TRANSIENT/PERMANENT
INCLUDE DSK1.LOWTOOLS

\ isr routine increments the double integer FRAMES
CREATE FRAMES  0 , 0 ,

CODE FRAMES++ ( -- ) \ this is the ISR
        FRAMES 2+ @@ INC,
        OC IF,
           FRAMES @@ INC,
        ENDIF,
        RT,
ENDCODE

DECIMAL
: SEXTAL   6 BASE ! ;
: <:>     [CHAR] : HOLD ;
: ##:     DECIMAL # SEXTAL #  <:> ;

: .TIME   ( d -- )
          FRAMES 2@
          BASE @ >R
        \     frm sec min     hrs
          <#  ##: ##: ##: DECIMAL #S #> TYPE
          R> BASE ! ;

\ the background time printer task
DECIMAL
: CLOCK  ( -- )
         BEGIN
            100 MS
            28 0 AT-XY  .TIME
         AGAIN
;

DECIMAL
: TIME>D  ( hr min sec -- d)  \ convert time format to seconds as double int.
          -ROT SWAP
          60 * +  ( sec mins')  \ hrs->mins + mins
        3600  UM*  2>R          \ Mins to frames & push
          60  UM*               \ seconds to frames
          2R> D+  ;             \ frames + frames

: SETCLOCK  ( hr min sec -- ) TIME>D  FRAMES 2! ;

: COLD    0 INSTALL  COLD ;     \ disable counter before restarting

DETACH  \ removes tools & Assembler from low-memory

USIZE MALLOC CONSTANT BGCLOCK  \ allocate memory and name our task
BGCLOCK FORK                   \ duplicate Forth's user area into BGCLOCK

' CLOCK BGCLOCK ASSIGN         \ Assign execution token of CLOCK to our task

ISR' FRAMES++ INSTALL          \ start the counter
MULTI                          \ enable mutlti-tasker

CR .( Set clock with:  SETCLOCK )
CR .( Start clock with BGCLOCK WAKE )

PAGE
BGCLOCK WAKE

10 43 29 SETCLOCK
