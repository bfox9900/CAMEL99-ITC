## SOUND LISTS IN VDP RAM
The files in this folder that begin with VDP are meant to be played with the
ISRSOUND library player in DSK1.ITC
(The source code for the player is also in PC format in the LIB.ITC folder)

### To play a file on TI-99
You will need to convert the .FTH file to a DV80 TI-99 file and move that DV80
file to your TI-99 disk system however you do that normally.
(Examples: TIPI drive, HDX drive, over RS232)

1. INCLUDE DSK1.ISRSOUND  to compile the player
2. INCLUDE DSK?.???????   where ? is the disk drive and filename that your
   move to your TI-99 disk.

If you moved the CHIME.FTH sound list then type this at the Forth console:

CHIME ISRPLAY

The sound will play.
Notice that while the sound is playing Forth is still active.
This is because the Interrupt Service Routine (ISR) is playing sound list in
the background every 16mS and not interfering with Forth.
