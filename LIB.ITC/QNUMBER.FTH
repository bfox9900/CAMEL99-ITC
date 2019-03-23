\ smaller, faster ?number for CAMEL99 Forth

: ?NUMBER  ( $ -- n ?)  \ convert $ to single, return flag
             COUNT 
             OVER C@ [CHAR] - = 
             IF   TRUE >R  1 /STRING
             ELSE FALSE >R
             THEN 0 0  2SWAP >NUMBER NIP NIP 
             R> IF SWAP NEGATE SWAP THEN 0= ;

