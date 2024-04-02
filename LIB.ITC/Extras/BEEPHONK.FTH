\ the most basic sounds  TMS9919 chip
\ For reference. These words are in the Camel99 Kernel
\ This code shows how you could make your own sounds. 

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
