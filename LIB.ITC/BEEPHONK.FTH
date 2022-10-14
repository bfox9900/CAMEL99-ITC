\ From kernel. Make sounds with SND! and the TMS9919 chip

HEX
: BEEP     ( -- )
            80 SND! 5 SND!                 \ precalulated values for OSC1 1328Hz
            91 SND!                        \ turn on OSC1 at -2 dB level
            AA MS                          \ Delay ~ 170 mS
            9F SND! ;                      \ turn off OSC1

\ We use the HONK sound for ABORT like TI-BASIC does on errors
: HONK     ( -- )
            81 SND! 20 SND!                \ precalculated values for OSC1 218Hz
            90 SND!                        \ turn on OSC1 at 0 dB level
            AA MS                          \ Delay ~ 170 mS
            9F SND! ;                      \ turn off OSC1
