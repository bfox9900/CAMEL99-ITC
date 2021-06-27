\ Forth versions. Assembler versions are in the kernel
: 2! ( n1 n2 adr -- )   ROT OVER 2+ !  ! ;
: 2@ ( adr -- n1 n2 )   DUP 2+ @ SWAP @ ;
