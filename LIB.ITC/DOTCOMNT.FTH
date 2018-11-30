\ talking comment   3.4.1 Parsing,  A.6.2.0200
\ moved to \LIB to save space in the kernel

: .(    ( <text> -- ) ?EXEC  [CHAR] ) PARSE TYPE ; XIMMEDIATE