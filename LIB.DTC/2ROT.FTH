\ part of ANS Forth Core wordset

: 2ROT   ( d d2 d3 - d2 d3 d) 2R> 2SWAP 2R> 2SWAP ;
