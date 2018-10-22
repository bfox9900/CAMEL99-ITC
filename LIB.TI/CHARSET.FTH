\ CHARSET restores TI-99 default characters from GROM
 
NEEDS ]PDT  FROM DSK1.GRAFIX
 
\ Dependandcies: un-comment  ]PDT if GRAFIX is NOT compile in your system
 
\ GROM Character Sets           Address  ASCII Codes  Bytes/Char
\ --------------------------------------- -------  -----------  ----------
\ Standard large caps                    04B4h   32  95    8
\ Small Capitals (capitals used by Basic)  06B4h   32  95    7
\ Lowercase (actually, small caps)     087Bh   96  126    7
 
HEX
\ 9800 CONSTANT GRMRD ( GROM base)   \ GROM read byte
\ 9802 CONSTANT GRMRA                \ GROM set read address
 
\ 9C00 CONSTANT GRMWD                \ GROM write byte
\ 9C02 CONSTANT GRMWA                \ GROM set write address
 
: GROM  ( addr -- ) SPLIT 9C02 C! 9C02 C! ; \ set the GROM address
: GC@+   ( -- c)    9800 C@ ;        \ read & auto-increment address
 
\ CODE GC@+    TOS PUSH,             \ fast by 8 bytes vs 4 in Forth
\              9800 @@ TOS MOVB,
\              TOS 8 SRL,
\              NEXT,
\              END-CODE
 
: ]PDT   ( char# -- 'pdt[n] )  8* 800 + ; \ VDP pattern Descriptor table
: ]GFONT ( ascii -- grom_adr) BL -  7 * 6B4 + ; \ GROM array of TIFont data
 
\ transfer directly from GROM to VDP
: GVMOVE  ( grom_addr vdp_addr cnt -- )
          ROT GROM   BOUNDS DO  GC@+ I VC!  LOOP ;
 
: CHARSET ( -- )
        [CHAR] ~ 1+  BL                \ all ASCII chars
        DO
           I ]GFONT                     \ get GROM address for char I
           I ]PDT                       \ get PDT address for char I
           0 OVER VC!                   \ store 1st zero in VDP
           1+                           \ inc PDT address
           7 GVMOVE                     \ write 7 bytes GROM->VDP
        LOOP ;
 
\ BONUS WORD: loads the TITLE screen font from GROM
: BIGCAPS  ( -- ) 4B4 900 200 GVMOVE ;  \ TI title page fonts
 
\ move data from GROM to CPU RAM
\ : GCMOVE  ( grom addr cnt -- ) ROT GROM  BOUNDS DO  GC@+ I C!  LOOP  ;

 
