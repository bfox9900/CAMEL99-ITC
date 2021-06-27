\ ti-99 sepcific equates

\ keeping EQUates in the cross-compiler vocabulary
\ makes them accessible to Xassembler and TARGET

 CROSS-COMPILING

\ ===================================================================
\ M E M O R Y   M A P P E D   D E V I C E S
ALSO XASSEMBLER DEFINITIONS

HEX
8800 equ VDPRD               \ vdp ram read data
8802 equ VDPSTS              \ vdp status
8C00 equ VDPWD               \ vdp ram write data
8C02 equ VDPWA               \ vdp ram read/write address
83D4 equ vr1cpy              \ copy of vdp register 1 - see e/a manual pg. 248
\ 8400 equ _sndport          \ moved to TMS9919.hsf

\ Meet the GROM ports
9800 equ GRMRD ( GROM base)   \ GROM read byte
9802 equ GRMRA                \ GROM set read address
9C00 equ GRMWD                \ GROM write byte
9C02 equ GRMWA                \ GROM set write address


DECIMAL
\ 32 equ COLS                  \ # of chars in a LINE on TI-99 screen
24 equ _L/SCR

\ ===================================================================
\ T I - 9 9   R O M   U T I L I T Y   E Q U A T E S

HEX
000E equ KSCAN                   \ pointer to address of the ROM keyboard scanning routine


\ ===================================================================
\ * W O R K  S P A C E  R E G I S T E R S
\ *
HEX
8300 equ wrksp0                 \ workspace 0 for program use
83E0 equ GPLWS                  \ GPL interpreter's registers live here.

\ ===================================================================
\ GPL addresses
8374 equ keyunit                \ keyboard layout code. CALL KEY( unit#, ...)see docs
8375 equ keyval                 \ location of ascii key pressed (via KSCAN)
837C equ status                 \ gpl status byte

834A equ fac                    \ FAC as in What the FAC is this?
83C4 equ ISR                    \ address of isr hook
837B equ VDPSTS                 \ copy of VDP status byte
837D equ inbuff                 \ VDP character input buffer


\ CAMEL99 screen control variables steals GPL floating point argument space
\ These are user variable locations in V2
\ We must define them here so the 9900FAST.HSF file needs these addresses
8348 equ _OUT                   \
834A equ _VROW                  \ re-defined as a user variable in CAMEL2.hsf
834C equ _VCOL                  \ re-defined as a user variable in CAMEL2.hsf
834E equ _C/L
8350 equ _C/SCR
836E equ _spr#                  \ sprite count for automotion.
                                \ basic use byte:837A, too slow in Forth

83D6 equ SCRTO                  \ screen time out timer
83A0 equ GSTK                   \ steal the GPL stack for Forth?
8EBE equ GRSTK                  \ steal the GPL stack for Forth?
83D4 equ VDPR1                  \ copy of VDP Register 1
