\ ED99CONFIG  is the configuration file for the ED99 editor

CR .( Initializing SAMS card...)
  SAMSINI

CR .( Loading Font...)
   S" DSK1.FONT0230" LOAD-FONT

\ For reference, here are the valid color names
\ TRANS   BLACK    GREEN   LTGRN
\ BLUE    LTBLUE   RED     CYAN
\ MEDRED  LTRED    YEL     LTYEL
\ DKGRN   MAGENTA  GRAY    WHITE

CR .( Set editor colors ...)
   GRAY  TO FG
   BLUE  TO BG

200 TO CSPEED  ( sets the repeating cursor speed)
