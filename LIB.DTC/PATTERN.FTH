\ PATTERN: lets us define a named character patterns

\ usage: 
\  HEX 3C42 A581 A599 423C PATTERN: HAPPY_FACE
\      3C42 A581 99A5 423C PATTERN: SAD_FACE

\ DECIMAL
\ SAD_FACE  159 CHARDEF

: PATTERN: ( u u u u  -- )
           CREATE
           >R >R >R              \ push 3 values so we can reverse order
           ,  R> , R> , R> ,     \ compile 4 ints in VDP useable order
;
