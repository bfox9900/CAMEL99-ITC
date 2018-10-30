\ TI LOGO GRAPHICS chars patterns from Sometimes99er
INCLUDE DSK1.GRAFIX

: TI.LOGO ( -- )
        CR 11 EMIT 12 EMIT 13 EMIT    \ print 3 characters
        CR 14 EMIT 15 EMIT 16 EMIT    \ print 3 characters
        CR 17 EMIT 18 EMIT 19 EMIT  ; \ print 3 characters

\ get a copy of the dictionary address
HERE

\ Now compile patterns into unused dictionary space
       0103 , 0303 , 0303 , 0303 ,
       FC04 , 0505 , 0406 , 020C ,
       0080 , 4040 , 8000 , 0C12 ,
       FF80 , C040 , 6038 , 1C0E ,
       1921 , 213D , 0505 , 05C4 ,
       BA8A , 8ABA , A1A1 , A122 ,
       0301 , 0000 , 0000 , 0000 ,
       E231 , 1018 , 0C07 , 0300 ,
       4C90 , 2040 , 4020 , E000 ,

\ write the data from HERE on stack,  to VDP memory
  DUP   11 ]PDT  4 CELLS 9 *  VWRITE

\ put the dictionary pointer back (reclaims the memory)
( here) DP !

PAGE  TI.LOGO
