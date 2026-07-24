\ POCOSCREEN.FTH   screen functions for POCO editor fEB 2026 BJF
\ line manipulation
: ?NEG
  GETXY
  DUP 0< IF BEEP PROMPT: ." #LINES < 0" 1000 MS THEN
  AT-XY ;

: #LINES+! ( n -- )    #LINES @ +  0 MAX #LINES ! ; \ can't go to 0
: LASTLINE ( -- n)     #LINES @ 1-  ?NEG ;

\ addresses in the buffer being edited
DECIMAL

\ manage 80 columns lines on 40 col. screen
DECIMAL
VARIABLE SOL    \ "start of line"

: SCRWIDTH ( -- n)  C/L@ 1- ;
: 80COL-CURSOR ( -- n)  CURPOS @  SOL @ +  80 MIN ;
: 'CURSOR   ( -- addr) 'TEXT  80COL-CURSOR  + ;

\ top 22 #LINES is the editor screen
  C/SCR @ C/L@ - CONSTANT SCRSIZE
  SCRSIZE C/L@ - CONSTANT BOTTOMLINE ( -- Vaddr)

\ -------------------------------------------
\ 40/80 column partial line displayer

\ fast type to VDP screen memory
: VTYPE  ( adr len  ) DUP>R VPOS SWAP VWRITE R> VCOL +! ;
: FITTED ( addr len -- addr' len') SOL @ /STRING 0 MAX SCRWIDTH MIN ;

DECIMAL
\ : VDP.TYPE BOUNDS ?DO I VC@ VPUT VCOL 1+! LOOP ;  \ slow version

\ * It is 3X faster to VREAD VDP string into RAM then VWRITE it to screen
CREATE TBUFF 82 ALLOT
: VDP.TYPE ( Vaddr len -- ) TUCK TBUFF SWAP VREAD  TBUFF SWAP VTYPE ;

: ]TYPELN ( line# -- ) ( TRUE means node is empty )
    DUP ]NODE @ TRUE = IF  DROP  [CHAR] ~ EMIT  RETURN;
    ]POOL$ FITTED VDP.TYPE
;

: (LIST)  ( start end -- ) SWAP DO  I ]TYPELN CR  LOOP ;
: LIST ( start --) DUP 23 +  (LIST) ; \ full page

: REMAINING ( line# -- n) 23 + ROW @ - 0 MAX ;
: PARTLIST ( startline ) DUP REMAINING (LIST) ;

\                     start          size
: CLS-BELOW ( -- ) ROW @ C/L@ *  C/SCR @ OVER -  BL VFILL ;

: REDRAW  ( -- ) PAGE  TOPLINE @ LIST ;

: AT-CURSOR ( -- ) CURPOS @ ROW @ AT-XY ;
: AT-LINE   ( -- ) 0 ROW @ AT-XY ;

: ?SIZE     DUP BUFFSIZE 1+ >  ABORT" VDP$ > BUFFSIZE" ;

\ compile RAM string into VDP $pool
: VS,  ( addr len -- ) VHERE OVER 1+ VALLOT VPLACE ;

: VDP$.GET   ( Vaddr len addr ) 2DUP C! 1+   SWAP ?SIZE VREAD ;
: ]VDP$.PUT  ( $addr len line# ) ]NODE @ VPLACE ;

: CLEAN       ( caddr -- ) DUP 1+ BUFFSIZE BL FILL  0 SWAP C! ;

: RELOAD-BUFFER
    EDIT-BUFFER CLEAN
    THELINE# ]POOL$  EDIT-BUFFER VDP$.GET ;
