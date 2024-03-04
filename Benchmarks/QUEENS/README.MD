# Eight Queens Problem

These files demonstrate two different solutions to this classic problem. 

These files were found online with attributions in the files. 

The file 8queens-FDmag.fth is from Rosetta code and demonstrates code from Forth Dimensions Magazine, written by competetant Forth coder.

The file Queens-fast.fth uses binary logic to solve the problem
about 10 times faster than the Forth Dimensions version. 

## Use the Libary Files
In 8queens-Camel99.fth we substitute the Forth arrays with the ARRAYS libary from Camel99 and the speed inproves by 27%. This shows how just a small amount of machine code or Assembler can make a big difference.

In 8queens-assembler.fth we use the ;CODE ENDCODE structure and the Assembler to improve the speed of the original array creator as well as a using other special features of Camel99 Forth. 

The file Queens-faster.fth uses the words 3RD and 4TH from the libary to speed up stack accesses deeper in the stack resulting in a 24% speed. 