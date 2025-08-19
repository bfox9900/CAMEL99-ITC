\ greenball.fth  using trig.fth  optical illusion demo         2022  Brian Fox

\ NEEDS DUMP   FROM DSK1.TOOLS
NEEDS SIN    FROM DSK1.TRIG
NEEDS SPRITE FROM DSK1.DIRSPRIT

DECIMAL
  01 CONSTANT invisible   14 CONSTANT magenta    15 CONSTANT gray
  92 CONSTANT Xbias      122 CONSTANT Ybias     130 CONSTANT Scale
 128 CONSTANT BALL

: SIN() ( n -- x) 30 * SIN  Scale / Xbias + ;
: COS() ( n -- y) 30 * COS  Scale / Ybias + ;
: CIRCLE  12 0 DO  BALL magenta  I COS()  I SIN()  I SPRITE  LOOP ;
: BLINKER 12 0 DO  invisible I SP.COLOR  120 MS   magenta I SP.COLOR  LOOP ;

: .INSTRUCTIONS
    PAGE
    CR ." RESIDUAL IMAGE OPTICAL ILLUSION"
    CR
    CR
    CR ." Stare at the cross in the"
    CR ." centre of the screen"
    CR
    CR ." A green ball will appear"
    CR ." There is no green ball!"
    CR
    CR
    CR ." Hold your gaze on the cross and"
    CR ." you may see the magenta balls"
    CR
    CR ."          DISAPPEAR!"
    CR
    6 23 AT-XY ." Press a key to begin"
    KEY DROP
    PAGE ;

: RUN
  GRAPHICS
  gray SCREEN
  .INSTRUCTIONS

  S" 00071F3F3F7F7F7F7F7F3F3F1F07000000E0F8FCFCFEFEFEFEFEFCFCF8E00000"
  BALL CALLCHAR

  2 MAGNIFY
  16 12 AT-XY ." +"
  CIRCLE
  BEGIN
    BLINKER
    ?TERMINAL
  UNTIL
  TEXT ;

CR .( Type RUN to run this program)
