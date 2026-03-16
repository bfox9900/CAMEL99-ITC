# Bit Map Mode on TI-99

This folder contains GRAPHICS2.0.FTH that switches the TI-99 into bitmap mode
written in Forth and then a set of files that slowly improved the performance
of the PLOT routine by using the Forth Assembler.

GRAPHICS2.1  simplied PIXPOS for 10-15% speed up
GRAPHICS2.7  .. GRAPHICS2.B add more code words for incremental speed ups.

For the Forth student this can give you some ideas of how to incrmentally
add Assembler to your programs to improve speed.

The demo program FLOGO2 creates a simple "Turtle graphic" system that
draws a number of shapes that you can use to see the speed changes.

FLOGO3 is the same DEMO but it uses VALUE instead of VARIABLE for a marked speedup.
