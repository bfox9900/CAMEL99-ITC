\ T I - 9 9   T E X T   M O D E   C O N T R O L
TARGET-COMPILING

: TEXT    ( -- )
             F0 DUP 83D4 C!
       ( -- F0) 01 VWTR
              0  2 VWTR  \ set VDP screen page
               VTOP OFF  \ topline VDP offset
               VPG  OFF  \ VDP screen page offset
             12  7 VWTR  \ sets FG & BG color
             28 C/L!
             0 0 AT-XY
             2 VMODE !   \ 2=ID for 40 column "TEXT" mode
             PAGE
;
