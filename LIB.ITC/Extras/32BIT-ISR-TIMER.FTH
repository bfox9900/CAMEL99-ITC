\ 32bit isr accumulating timer using 9901          Feb 2022 Brian Fox

\ Idea: In Camel99 Forth the 9901 timer runs continously.
\ The 9901 timer is independant of the CPU.
\ In the program we make an ISR that reads the 9901 timer every 1/60 
\ of second. The timer difference between the last sample and the 
\ current sample is added to the 32bit variable T32. 

NEEDS ELAPSE  FROM DSK1.ELAPSE
NEEDS .S      FROM DSK1.TOOLS

NEEDS MOV,    FROM DSK1.ASM9900
NEEDS ISR'    FROM DSK1.ISRSUPPORT

CREATE T32 0 , 0 ,
VARIABLE T
VARIABLE OLDT

CODE TIMERISR
\ read the timer, which runs continuously in Camel99 Forth
          TOS PUSH,
\ read 9901 timer
       R12 2 LI,
          -1 SBO,
      TOS 14 STCR,
          -1 SBZ,
\ compute change in timer since last interrupt
        TOS T @@ MOV,  \ new timer to T
   OLDT @@ TOS SUB,  \ get difference from last timer
           TOS ABS,  \ must be positive
   T @@ OLDT @@ MOV,  \ update old timer value

\ add difference to the 32 bit accumulator
         TOS  T32 2+  @@ ADD,
         OC IF,
            T32 @@ INC,
         ENDIF,

         TOS POP,
         RT,
ENDCODE

0 0 T32 2!
ISR' TIMERISR INSTALL

: TEST    T32 2@  T32 2@ UD. ;

: SHOW   BEGIN  10 10 AT-XY  T32 2@ UD.  ?TERMINAL UNTIL ;
