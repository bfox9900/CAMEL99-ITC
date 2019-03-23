#SOURCE CODE NOTES
As of Nov 30, 2018 there are two versions of the system.
An indirect threaded system and a direct threaded system for demonstration.
In performance tests the direct threaded system is about 10..15% faster but
consumers more space for every Forth word defined.  
On the TI-99 it is probably not worth the extra complexity because memory is at
at premium

# Mar 23 2019
Version G now uses a control variable called USEFORTH. If set to true
more for Forth code is used for definitions. Set to false and CODE words are
used. (Forth Assembler)  The Forth versions save about 36 bytes in the kernel
but compile times are about 6% slower. You can choose how to build the system.
