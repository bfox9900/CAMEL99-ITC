# Cosmic Conquest

This project was originally put into the wild by Rick Carlino on Reddit r/Forth.

https://github.com/RickCarlino/Cosmic-Conquest-1982

"This is a re-creation of a realtime strategy game published in BYTE Magazine in
1982. The original version of the game was distributed in printed form for
users to manually type into their Apple II computers. It is credited as one of
the first real-time strategy computer games. The game was authored in a flavor
of FIGForth for the Apple II, possibly FIGForth '78 by ALAN SARTORI-ANGUS
The exact platform is unknown at this time."

The original byte article is available here:
https://archive.org/details/byte-magazine-1982-12/page/n131/mode/1up?q=cosmic+conquest

The translation Harness for Camel99 Forth is the file MODERNISE.FTH for CC_TI99.FTH.
This version is the first running version of the GForth code by Rick for Camel99 Forth.
It was not too difficult to make the adjustments to get Rick's GForth code to compile 
on the old TI-99 under Camel99 Forth. 

For COSMIC99.FTH is the verion that will use more TI-99 features, the harness file is 
HARNESS99.FTH .  The plan is to eventually retire HARNESS99 and use ANS Forth with
Camel99 TI-99 specific extensions.

### Memory Usage
The one big change made immediately was to move the data arrays (matrices actually) 
into the Camel99 HEAP.
Although the marketing tells us that TI-99 has a 32K RAM board, it fails to remind 
us that the memory is in two chunks. 8K at $2000 and 24K at $A000.
Camel99 treats the $2000 block as an unassigned HEAP. 
Cosmic Conquests data storage requires 7.3K so this little HEAP was a good fit.  
This change gives us lots more room for code enhancments.

There are a lot of optimizations that can be made in porting to TI-99:
- removing the FIG FORTH aliases and use ANS nomenclature
- re-defining characters for the various planets and stars on the galactic map.
- Using faster hardware specific screen I/O
- re-write in more idiomatic Forth 
  (Seems to be a BASIC influence on original code)
- Use TI-99 hardware support for mulitple screens to display help information and reports

One tantalizing change, that appears to be simple to do with Camel99, is to let 
the computer play in the background as a separate task making the game truly
real-time. 
