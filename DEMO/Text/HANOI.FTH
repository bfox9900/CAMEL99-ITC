\ Towers of Hanoi from Rosetta Code Moddfied with a "moves" counter

VARIABLE MOVES

: LEFT   ." LEFT" ;
: RIGHT  ." RIGHT" ;
: MIDDLE ." MIDDLE" ;

: MOVE-DISK ( V T F N -- V T F )
     DUP 0= IF DROP EXIT THEN
     1- >R
     ROT SWAP R@ ( T V F N-1 ) RECURSE
     ROT SWAP
     2DUP CR ." Move disk from " EXECUTE ."  to " EXECUTE
     SWAP ROT R> ( F T V N-1 ) RECURSE
     SWAP ROT
     MOVES 1+! ;

: HANOI ( n -- )
     MOVES OFF
     1 MAX >R
     ['] RIGHT  ['] MIDDLE  ['] LEFT  ( xt1 xt2 xy3 --)
     R> MOVE-DISK
     DROP DROP DROP
     CR MOVES @ .  ." moves" ;

\  Usage:   3 HANOI
