\ Rossetta Code posting by BF.  Strip comments from a string

\ Modern Forth advocates the use of stack strings. Stack strings are
\ manipulated as an address and a length on the Forth DATA stack.
\ As such they do not require memory copying for many forms of string functions 
\ making them fast. 

\ Using stack strings and concatenating functions means Forth does this task 
\ with no REGEX required. 

\ SCAN is not a standard function but is part of the CAMEL99 KERNEL.

: LASTCHAR ( addr len -- addr len c) 2DUP + C@ ;
: COMMENT? ( char -- ? )  S" #;"  ROT SCAN NIP ;    \ test char for "#;" 
: -LEADING ( addr len -- addr' len') 2DUP BL SKIP ; \ remove leading space characters
 
: -COMMENT   ( addr len -- addr len') \ removes # or ; comments
            1-
            BEGIN
              LASTCHAR COMMENT? 0=
            WHILE                     \ while not a comment char...
                1-                    \ reduce length by 1
            REPEAT
            1-  ;                     \ remove 1 more (the comment char)

: -TRAILING  ( adr len -- adr len')   \ remove trailing spaces
             1-
             BEGIN
               LASTCHAR BL =
             WHILE                    \ while lastchar = blank
               1-                     \ reduce length by 1
             REPEAT  
             1+ ;

: COMMENT-STRIP ( addr len -- addr 'len) -LEADING -COMMENT -TRAILING  ;

S"      X=X+1 # This is the comment"  COMMENT-STRIP CR CR TYPE CR
S"      MOV AX,BX  ; assembly language comment" COMMENT-STRIP CR CR TYPE CR