\ nfa>cfa
\ algorythm:    
\ look backwards until you see a '0' or '40'
\ This puts you at the precedence bit field

HEX
: CFA>NFA ( cfa -- NFA | 0 )  \ kind of convoluted but it works.
    2-                \ min. real name length is 2 bytes (aligned)
    BEGIN
      DUP C@ 0FE AND  \ upper 7 bits always 0 in precedence field
    WHILE    
      1- 
    REPEAT
    1+
;
