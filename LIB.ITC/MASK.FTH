\ mask.fth  creates fast masking words              Dec 2021 Fox
\ usages:
\ 7 MASK: 7AND

HEX
: MASK:  CREATE INVERT ,
         ;CODE
             4118 ,  \ *W TOS SZC,
             NEXT,
          ENDCODE
