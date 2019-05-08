\ the most basic sounds  TMS9919 chip
HEX

: ms  ( n --) 0 ?DO  8 0 DO PAUSE LOOP LOOP ; \ n ~= milliseconds

: SND!   ( c -- )  8400 C! ;  \ 4 bytes, 277 uS

: BEEP     ( -- )
            80 SND! 5 SND!                 \ precalulated values for OSC1 1328Hz
            91 SND!                        \ turn on OSC1 at -2 dB level
            AA ms                          \ Delay ~ 170 mS
            9F SND! ;                      \ turn off OSC1

\ We use the HONK sound for ABORT like TI-BASIC does on errors
: HONK     ( -- )
            81 SND! 20 SND!                \ precalculated values for OSC1 218Hz
            90 SND!                        \ turn on OSC1 at 0 dB level
            AA ms                          \ Delay ~ 170 mS
            9F SND! ;                      \ turn off OSC1
