# Cosmic Conquest

https://github.com/RickCarlino/Cosmic-Conquest-1982

This is a re-creation of a real-time strategy game published in BYTE Magazine in
1982. The original version of the game was distributed in printed form for
users to manually type into their Apple II computers. It is credited as one of
the first real-time strategy computer games. The game was authored in a flavor
of FIGForth for the Apple II, possibly FIGForth '78 by ALAN SARTORI-ANGUS
The exact platform is unknown at this time.

The original byte article is available here:
https://archive.org/details/byte-magazine-1982-12/page/n131/mode/1up?q=cosmic+conquest

## TI-99 Version 

The translation Harness for Camel99 Forth has been removed and replaced with
definitions in the COSMIC99.FTH source file. It was not too difficult to make
the adjustments to get Rick's GForth code to compile on the old TI-99 under our
version of Camel Forth.

The one big change was to move the data arrays into the 8K low RAM block of the
TI-99. Camel99 treats this as a HEAP. The data requires 7.3K and with the Forth
kernel using 8K of the 24K at HEX A000 to FFFF, it was a very tight fit.  This
change gives us a lot more room for future enhancements.

There are a lot of optimizations have been made in converting to ANS Forth,
using more of the special operators available in Forth and re-writing the 
program in a more Forth appropriate style.

This list is extracted from the top of COMSIC99.FTH.

- Replaced all ROT ROT  with -ROT for speed and 20 bytes space saving
- Replaced 0 FILL  with ERASE
- Replace all 1 -   with 1-  save  14 bytes
- Create names/syntax for accessing data rather than numbers
- Removed Apple character configuration code
- Replaced all 2 *  with CELLS
- Replaced all 2 /  with 2/
- Replaced all 4 *  with 4* (Camel99 code word)
- Replaced all 8 *  with 8* (Camel99 code word)
- Replaced ARRAY with MATRIX: (ARRAY is 1 dimension in Forth by convention)
- Added new mapped characters to charset for "space" graphics
- Added border characters to create a box on play screen
- Wrote new INKEY.  7 bit output, uppercase ALPHA
- re-factored extremely long words into smaller words
- replaced a lot of code for variable updates with +! operator

In the case of +! I think the original author did not know about it. (?)
It reduces expressions like:
```
    X @ Y @ +  Y ! 
to
    X @ Y +! 
```


One tantalizing change, that is possible with Camel99, would be to let the
computer play in the background as a separate task making the game truly
challenging. This requires re-entrant code and we are in the process of removing
temporary variables and replacing them with stack operations.  

The TI-99 also has multiple screen capability so potentially the computer's screen
could be updated independantly while you play. A key command would allow you to
check on the computer's progress anytime you needed to.
