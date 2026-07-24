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

: ]TYPELN ( line# -- ) ( TRUE means node is empty )
    DUP ]NODE @ TRUE = IF  DROP  [CHAR] ~ EMIT  RETURN;
    ]POOL$ FITTED VTYPE
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

: ?SIZE     DUP BUFFSIZE 1+ >  ABORT" POOL$ > BUFFSIZE" ;

\ : POOL$.GET   ( Vaddr len addr )  2DUP C! 1+  SAMS.GET ;
: ]POOL$.PUT  ( $addr len line# ) ]NODE @ VIRT>REAL PLACE  ;

\ : CLEAN       ( caddr -- )
\    DUP 1+ BUFFSIZE 1-  BL FILL
\    0 SWAP C! ;

: RELOAD-BUFFER
    EDIT-BUFFER BUFFSIZE ERASE
    THELINE# ]POOL$  EDIT-BUFFER PLACE ;
