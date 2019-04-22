#SOURCE CODE NOTES
Apr 22, 2-18
There are multiple versions of the system.

1. CAMEL99.FTH uses 122 CODE words and 193 Forth words. The compiler is built with Forth.
The source code has minimal comments to present a clean view of how CAMEL Forth is built.

2. CAMEL99G2.HSF uses the same 122 CODE words but has many of the compiler words written in CODE. Compile times are approximately 19% faster with this system.
Version G uses a control variable called USEFORTH. If set to true
more for Forth code is used for definitions. Set to false and CODE words are
used. (Forth Assembler) You can choose how to build the system.

3. CAM99DTC builds a direct thread system which on empty loops is 30% faster but in real world
applications it is not as significant and consumes 4 extra bytes for every Forth word, however it saves 2 bytes for every CODE word. If you application is to be written mostly in Forth Assembler, the DTC version is the way to go otherwise ITC is a better comprimise.
