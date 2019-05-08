\ set text mode
: TEXT      ( -- )
             F0 DUP KTP C!  \ TI KSCAN re-writes VReg1 with whatever is in this byte.
       ( -- F0) 01 VWTR     \ VDP register 1: bit3 = 1 sets the TEXT Mode
             00  2 VWTR     ( DEFAULTS FROM EDITOR ASSEMBLER)
             0E  3 VWTR
             01  4 VWTR
             06  5 VWTR
              1  6 VWTR   \ sprite descriptor table is set
             20  7 VWTR   \ VDP register 7. color: med. green on transparent screen
 ;