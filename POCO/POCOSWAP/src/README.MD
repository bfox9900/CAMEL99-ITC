## POCO EDITOR with swap-file

This version uses the Forth block file system as virtual memory,
A text file is read into the block file and a node list pointing to each string.

The key to making it work is to never allow an editor string to cross-over
a block boundary.  This is accomplished with the word VM.MALLOC in FILE2SWAP.FTH.
