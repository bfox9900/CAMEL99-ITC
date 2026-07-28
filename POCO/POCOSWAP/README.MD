## POCO EDITOR with swap-file

This version of the POCO eidtor uses the Forth block file system as virtual memory,
A text file is read into the block file and a node list pointing to each string.

The key to making it work is to never allow an editor string to cross-over
a block boundary.  This is accomplished with the word VM.MALLOC in FILE2SWAP.FTH.

See the file POCODOCS  for the console commmands and key commands.

Of course the entire Camel99 Forth system is also at your finger tips.
