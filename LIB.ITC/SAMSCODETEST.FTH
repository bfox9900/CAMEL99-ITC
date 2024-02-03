\ nesting forth words across multiple SAMS pages 
NEEDS FAR: FROM DSK1.SAMSCODE 

DECIMAL
240 CODEPAGE
FAR: HELLO   CR ." Hello SAMS World!"  ;FAR

\ INCLUDE DSK1.DEFER

241 CODEPAGE 
FAR: NESTED1  ." Nesting 1," ;FAR

242 CODEPAGE 
FAR: NESTED2  NESTED1  ." 2,"  ;FAR

243 CODEPAGE 
FAR: NESTED3  NESTED2  ." 3 :-)"  ;FAR

\ This word is CPU RAM 
: TEST  
  CR ." Press a key to startp "
  CR ." Press BREAK key to stop  "
  CR
  BEGIN 
     CR NESTED3  
     ?TERMINAL 
  UNTIL ;

  