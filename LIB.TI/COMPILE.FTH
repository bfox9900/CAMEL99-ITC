\ 6.2.0945 COMPILE,      compile comma
\ for compatibility

: COMPILE, ( n -- ) S" ," EVALUATE ; IMMEDIATE
