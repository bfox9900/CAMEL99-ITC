\ JOYST.FTH  from http://www.unige.ch/medecine/nouspikel/ti99/joystick.htm

\ The keyboard column selector is controled by CRU bits 18-20
\ (put >0024 in R12) in the CRU address space of the TMS9901.
\ The joysticks read back at bits 3 to 7 (CRU address >0006).

\ Column:     Joyst1  Joyst2
\ R12 address    6      7
\ ---------------------------
\ >0006        Fire    Fire
\ >0008        Left    Left
\ >000A        Right   Right
\ >000C        Down    Down
\ >000E        Up      Up

NEEDS  LDCR,  FROM DSK1.ASM9900

\ JOYST ( joystick# -- value )
\ ; Scans the joystick returning the direction value
\      _joyst  mov *stack,r1               ; get unit number
\              ai r1,6                     ; use keyboard select 6 for #0, 7 for #1
\              swpb r1
\              li r12,36
\              ldcr r1,3
\              li r12,6
\              stcr r1,5
\              swpb r1
\              inv r1
\              andi r1,>001f
\              mov r1,*stack
\              li r12,_next
\              mov r12,@>83d6              ; defeat auto screen blanking
\              mov @bank1_,@retbnk         ; return to bank 1 if interrupts should fire
\              limi 2                      ; briefly enable interrupts
\              limi 0                      ; and turn 'em off again
\              b @retb0                    ; return to caller in bank 0


\ JOYST ( joystick# -- value ) adapted from turbo FORTH
\ Scans the joystick returning the direction value
CODE JOYST ( joystick# -- value ) \ from turbo FORTH
DECIMAL  TOS R1 MOV,    \ get unit number to R1
            TOS CLR,    \ clear TOS for output later
         R1   6 AI,     \ use keyboard select 6 for #0, 7 for #1
             R1 SWPB,
            R12 RPUSH,  \ save R12 in case we using TTY1
         R12 36 LI,     \ joystick i/o address
         R1   3 LDCR,   \ write 3 bits to enable joysticks
         R12  6 LI,     \ select column 6
         TOS  5 STCR,   \ get 5 bits from joystick
            TOS SWPB,   \ swap byte
            TOS INV,    \ change to positive logic
HEX    TOS 001F ANDI,   \ mask off the junk
           83D6 CLR,    \ reset auto screen blanking
            R12 RPOP,   \ restore R12
       NEXT,
       ENDCODE
