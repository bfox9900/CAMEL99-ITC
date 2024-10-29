\ Quotations: Minimal Implementation for Camel99 Forth ITC
\ *Does not work*

VARIABLE OLD>IN
CREATE OLDSOURCE 0 , 0 ,

: SAVE-DEFINITION-STATE
       SOURCE OLDSOURCE 2!
       >IN @ OLD>IN !  ;

: RESTORE-DEFINITION-STATE
       OLD>IN @ >IN !
       OLDSOURCE 2@  'SOURCE 2!  ;

: [: ( c: -- quotation-sys colon-sys )
     POSTPONE AHEAD SAVE-DEFINITION-STATE :NONAME ; IMMEDIATE

: ;] ( c: quotation-sys colon-sys -- ) ( s: -- xt )
     POSTPONE ; >R  RESTORE-DEFINITION-STATE
     POSTPONE THEN  R> POSTPONE LITERAL ; IMMEDIATE
