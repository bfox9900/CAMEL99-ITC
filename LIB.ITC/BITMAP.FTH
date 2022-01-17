\ Bitmap mode
\ The VDP register setting could be the following:
\ VR0 >02 Bitmap mode on
\ VR1 >C0 16K, screen on
\ VR2 >08 Screen image at >1800
\ (we can't have it at >0000 since either the
\  pattern or the color table must be there)
\ VR3 >FF  Color table at >2000, address mask = >1FFF
\ (full size table: 3 times >800 bytes)
\ VR4 >03   Pattern table at >0000, address mask = >1FFF
\ (full size table: 3 times >800 bytes)

HEX
CREATE 40COL
\      VR0   VR1   VR2   VR3   VR4   VR5   VR6   VR7
       00 C, F0 C, 00 C, 0E C, 01 C, 06 C, 02 C, 17 C, ALIGN

: VDPMODE ( Caddr  -- ) 8 0 DO  COUNT I VWTR  LOOP DROP ;

: .REGS    ( Caddr  -- ) 8 0 DO  CR COUNT . LOOP DROP ;

: TEXT   ( -- )
         40COL VDPMODE
         2 VMODE !  \ record the mode we are in
         28 C/L!    \ Set 40 chars/line, which also re-calcs the screen vars
         0 VTOP !
         F0 83D4 C!  \ TI KSCAN re-writes VReg1 with whatever is in this byte.
         PAGE ;

 CREATE BITTAB
        02 C,   \ VR0 = 02 Bitmap mode on
        C0 C,   \ VR1 = C0 16K ram, screen on
        08 C,   \ VR2 = 08 Screen image at >1800
        FF C,   \ VR3 = FF Color table at >2000, address mask = >1FFF
        03 C,   \ VR4 = 03 Pattern table at >0000, address mask = >1FFF
        00 C,   \ N/A
        00 C,   \ N/A
        00 C,   \
        ALIGN

: BITMAP
          BITTAB VDPMODE
          1300 VTOP !
          C0 83D4 C!
;

: SEQFILL ( addr n ) 0 DO I OVER I +  VC! LOOP DROP ;

HEX
: TEST
   BITMAP
   2000 1800 AA VFILL \ fill the color table
   100 MS
   1800 100 SEQFILL   \ fill screen table with sequential chars
   1900 100 SEQFILL
   1A00 100 SEQFILL
   400 MS
   0000 1800 AA VFILL
   300 MS
   COLD ;
