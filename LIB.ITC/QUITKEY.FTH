\ QUIT key enable/disable
HEX
: QUIT-OFF ( -- ) 83C2 DUP C@ 70 AND 10 OR SWAP  C! ;
: QUIT-ON  ( -- ) 83C2 DUP C@ 60 AND SWAP C! ;