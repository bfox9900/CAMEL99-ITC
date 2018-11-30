\ Bitmap text mode

\ This is the mode TI forgot to tell us about. It works just like standard bitmap
\ mode, except that the screen is now 40 columns and that only two colors are
\ available.

\ This mode is set as follows:
\ R0  bit 7=true
\ R1  Bit 4=true
\ VR0: 1
\ VR1: 0 1
\ The screen is now divided in three, each third is 8 lines high and thus
\ occupies >140 bytes in the screen image table (8*40=320).
\ The colors are taken from VR7, just like in regular text mode. There is no color table,
\ and the contents \of VR3 is irrelevant. Just like in standard bitmap mode, 
\ there can be upto 3 pattern tables, located either at >0000 or at >2000. 
\ You can use the address mask bits in VR4 to determine which third of the screen 
\ uses which table.
\ The main difference is that the color address mask is not used to fill-in 
\ the patten address mask:
\ >07 is always used instead. No character grouping to worry about, then! 
\ This mode comes handy for black-and-white drawings.

\ The VDP register setting could be the following:
\ VR0 >02 Bitmap mode on
\ VR1 >C0 16K, screen on
\ VR2 >08 Screen image at >1800
\        (we can't have it at >0000 since either the pattern or the color table must be there)
\ VR3 >FF Color table at >2000, address mask = >1FFF (full size table: 3 times >800 bytes)
\ VR4 >03 Pattern table at >0000, address mask = >1FFF (full size table: 3 times >800 bytes)

HEX

CREATE 40COL
\     CNT     0     1     2     3     4     5     6     7
       08 C, 00 C, F0 C, 00 C, 0E C, 01 C, 06 C, 02 C, 1B C, 00 C,


: VREGS    ( addr len -- ) 0 DO  DUP I + C@  I VWTR  LOOP DROP ;

: .REGS    ( addr len -- ) 0 DO  CR DUP I + C@ . LOOP DROP ;

: TEXT     ( -- )
           40COL COUNT VREGS
            2 VMODE !            \ record the mode we are in
             28 C/L!              \ Set 40 chars/line, which also re-calcs the screen variables
             F0 KTP C!            \ TI KSCAN re-writes VReg1 with whatever is in this byte.
             PAGE ;               \ "CALL CLEAR" ;-)
;

 CREATE BITTAB
\      CNT       0     1     2     3     4     5     6     7
        08 C,   02 C, C0 C, 08 C, FF C, 03 C, 00 C, 00 C, 02 C, 00 C,
        

: BITMAP
          BITTAB COUNT VREGS
          1300 VTOP !
          2 KTP C!
           ;


: TEST    BITMAP  5000 MS  TEXT ;
