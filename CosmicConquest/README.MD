# Cosmic Conquest

https://github.com/RickCarlino/Cosmic-Conquest-1982

This is a re-creation of a realtime strategy game published in BYTE Magazine in
1982. The original version of the game was distributed in printed form for
users to manually type into their Apple II computers. It is credited as one of
the first real-time strategy computer games. The game was authored in a flavor
of FIGForth for the Apple II, possibly FIGForth '78 by ALAN SARTORI-ANGUS
The exact platform is unknown at this time.

The original byte article is available here:
https://archive.org/details/byte-magazine-1982-12/page/n131/mode/1up?q=cosmic+conquest

The translation Harness for Camel99 Forth is the file MODERNISE.FTH. It was not
too difficult to make the adjustments to get Rick's GForth code to compile on
the old TI-99 under our version of Camel Forth.

The one big change was to move the data arrays into the 8K low RAM block of the
TI-99. Camel99 treats this as a HEAP. The data requires 7.3K and with the Forth
kernel using 8K of the 24K at HEX A000 to FFFF, it was a very tight fit.  This
change gives us a bit more room for enhancments.

There are a lot of optimizations that can be made in converting to ANS Forth,
re-moving the aliases. Further optimizations can be made by using native TI-99
methods including re-defining characters for the various planets and starts on
the galactic map.

One tantalizing change, that is possible with Camel99, would be to let the
computer play in the background as a separate task making the game truly
challenging. The TI-99 has multiple screen capability so potentially the
computer's screen would be updated independantly while you play. A key command
would allow you to check on the computer's progress anytime you needed to.
