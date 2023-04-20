\ define target comment words
TARGET-COMPILING
: (         T[CHAR] ) PARSE 2DROP ; XIMMEDIATE
: \                 1 PARSE 2DROP ; XIMMEDIATE

[CC]
\ =====================================================================
\ TARGET Colon, :NONAME and Semi-colon  definitions
\ X: ;X are aliases for the cross-compiler : and ;

TARGET-COMPILING
 X: :         !CSP  HEADER (:NONAME)  ;X

 X: :NONAME   HERE  !CSP   (:NONAME)  ;X

 X: ;        [  REVEAL COMPILE EXIT ?CSP ;X  XIMMEDIATE

[CC]
