\ POCO editor utility words

DECIMAL
: PURGE   NEW-$POOL NEW-NODES  #LINES OFF ;
: >=   1- > ;
: GETXY   ( -- col row) VROW 2@ ;
: BETWEEN ( n lo hi -- ? ) 1+ WITHIN ;
: CLIP    ( n lo hi -- n') ROT MIN MAX  ;
: SCREEN ( u --) 7 VWTR ;
: RETURN;   POSTPONE EXIT  POSTPONE THEN ; IMMEDIATE

\ decrement variable by 'n' but never go below zero
: SAFE-! ( n addr -- ) DUP>R @ SWAP - 0 MAX R> ! ;

\ Syntax sugar
: LEN    ( addr -- c)  C@ ;
: VLEN  ( Vaddr -- c) VC@ ;
