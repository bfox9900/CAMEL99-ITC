# Oregon Trail

This is old game was from the early years of computing.
This version was my attempt to make a game language in Forth
to simplify writing the logic and probability of things happening.

I used a version in BASIC by Majestix on Atariage.com as starting point
but I ad-libbed a lot of things as I went along.

The other experiment was TI-99 specific. With such a limied amount of
memory for program, and about 9K bytes of free memory attached to the Video
display peripheral (VDP) chip, it seemed like we could use that space for
all the text that a game like this requires.

The solution was to make the word PRINT."  which compiles text into VDP RAM
and also behaves like the BASIC PRINT statement and output the text on a new line.

The total amount of text in the is about 8.7Kbytes so putting in VDP RAM freed up a
lot program memory in TI-99 terms.


## Instructions for Use

Use the folders in the  bin/ folder as DSK1 and DSK3 on the Classic99 Emulator.
The Camel99 system disk must in in DSK1.
The disk with the three OREGON game files must be in DSK3.

Insert the EDITOR/ASSEMBLER CARTRIDGE into the TI-99.
Select menu option 5:  RUN PROGRAM FILE
At the prompt type:  DSK1.CAMEL99
Wait for Forth to start.
At the Forth console, type:  INCLUDE DSK3.OREGON
and follow the prompts.

The game takes about a minute to compile and will run when the compile if finished.
