# Eight Queens Problem

These files demonstrate three very different solutions to this classic problem. 

These files were found online with attributions in the files. 
The file 8QUEENS.FTH seems to be an example of writing the solution by using another language as the starting point. It is large and inefficient. 

I tried to speed it up using the inline optimizer in 8QUEENSOPTIMIZED.FTH but the algorythm is the problem. 

The file 8queens-FDmag.fth is from Rosetta code and demonstrates code from Forth Dimensions Magazine, written by competetant Forth coder.

The file Queens-fast.fth uses binary logic to solve the problem
10 times faster than the Forth Dimensions version. 

The file Queens-faster.fth uses the words 3RD and 4TH from the libary to speed up stack accesses deeper in the stack. 