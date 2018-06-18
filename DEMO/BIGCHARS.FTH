\ BIG chars from GROM with no Assembler
\ this program reads the character shapes from Graphics ROM (GROM)
\ that are used in the TI-99 title screen.

INCLUDE DSK1.GRAFIX.F

: GROM  ( addr -- ) SPLIT 9C02 C! 9C02 C! ; \ set the first address in GROM

: GC@+   ( -- char)  9800 C@ ;  \ read byte from GROM & auto-increment address

: GVMOVE  ( grom_addr vdp_addr cnt -- ) \ GROM->VDP move
          ROT GROM
          BOUNDS DO  GC@+  I VC!  LOOP ;

\ big caps are in GROM as 8 bytes per char so we just move the bytes
\ to PDT array (pattern descritptor table) that is in VDP memory
: BIGCAPS  ( -- ) 4B4  20 ]PDT   200 GVMOVE  ;

\ these words move the TI BASIC font into VDP memory.
\ its more complicated because these characters are stored in GROM
\ 7 bytes per character. This saves space because the 1st byte is always 0.
\ But this means we have to put the 0 into PDT manually
: GCMOVE  ( grom addr cnt -- ) ROT GROM  BOUNDS DO  GC@+ I C!  LOOP ;

: ]GFONT ( ascii -- grom_adr) BL -  7 * 6B4 + ;  \ GROM array of TI Font data

: CHARSET ( -- )
        [CHAR] ~ 1+ BL                  \ all ASCII chars
        DO
           I ]GFONT                     \ get GROM address for char I
           I ]PDT ( -- grom pdt)        \ get PDT address for char I
           0 OVER VC!                   \ store 1st zero in VDP
           1+                           \ inc PDT address
           7 GVMOVE                     \ write 7 bytes GROM->VDP
        LOOP ;

DECIMAL

: WAIT  ( -- ) BEGIN KEY? UNTIL ;


: (c)   10 EMIT ;

: TEST  
        GRAPHICS
        8 9 AT-XY     ." TEXAS INSTRUMENTS"
       10 11 AT-XY       ." HOME COMPUTER"
        2 16 AT-XY     ." READY-PRESS ANY KEY TO BEGIN"
        4 22 AT-XY (c) ." 1981  TEXAS INSTRUMENTS"

        0 0 AT-XY ." Press ^C to exit"

        BEGIN
          BIGCAPS
          CHARSET
          ?TERMINAL
        UNTIL
        BYE  ;


