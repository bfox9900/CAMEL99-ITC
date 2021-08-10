\ EXTERNS.FTH  CALL a sub-routine OR sub-program from Forth   2021  Fox
HEX
: EXTERN: ( addr -- ) \ create a word the does BL @addr
      CREATE      ,   \ compile addr into the word
      ;CODE C218 , \ *W W MOV,  \ Fetch address from Forth
            0698 , \ *W BL,     \ call external code
            NEXT,
      ENDCODE

: EXTERN-PROG: ( vector -- ) \ vector is (wkrsp,addr) data structure
     CREATE     ,  \ compile vector
     ;CODE  C218 , \ *W W MOV,  \ Fetch vector address from Forth
            0418 , \ *W BLWP,
            NEXT,
     ENDCODE

\ example for use with object loader DSK4.EA3LOADER
\ NEW.
\ OLOAD DSK4.CLS-OBJ
\ DEFS CLS  FORTH EXTERN: CLS
