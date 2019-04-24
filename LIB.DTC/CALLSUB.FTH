\ N E S T E D   S U B - R O U T I N E   M A C R O
\ "Psuedo-instruction" to implements a CALL sub-routine mechanism on the
\ Forth return stack using the Branch & Link instruction.
\ You use CALL, exactly the same as you would use BL, but you can nest
\ sub-routine calls with CALL,

\ Return from CALL, is done with psuedo instruction RT, just like BL,

\ See Xassembler   : RT,    *R11 B, ;             \ 12 cycles

: CALL,  ( dst -- )
         R11 RPUSH,       \ save R11 on forth return stack
       ( addr) @@ BL,     \ branch & link saves the PC reg. in R11
         R11 RPOP, ;      \ compile code to old POP R11
         
         
\ R11 RPOP, is laid down by CALL, in the caller.
\ We have to lay it in the code after BL so
\ when we return from the Branch&link, R11 is
\ restored to the original value from the rstack
