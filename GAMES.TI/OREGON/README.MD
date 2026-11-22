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
