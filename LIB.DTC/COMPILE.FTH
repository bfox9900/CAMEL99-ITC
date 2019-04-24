
\ 6.2.0945 COMPILE,      compile comma
\ for ANS compatibility. Same as comma in CAMEL99

: COMPILE, ( n -- ) S" ," EVALUATE ; IMMEDIATE

