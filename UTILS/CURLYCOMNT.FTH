\ CURLYCOMNT.FTH  extend across many lines Dec 25 2023

\ INCLUDE DSK1.TOOLS 

\ *NON* standard for Camel Forth
DECIMAL
: REFILL ( -- ?) \ len=0 means no input
  TIB DUP        \ read input into terminal input buffer 
  SOURCE-ID @
  IF   2 FILEOP ?FILERR FGET ( addr len)
  ELSE 80 ACCEPT ( addr len)
  THEN 
  DUP IF  
       'SOURCE 2!  >IN OFF  TRUE  
        EXIT  
  THEN NIP 
;


: {
    BEGIN
      1 PARSE-WORD [CHAR] } SCAN NIP 0= 
    WHILE 
      REFILL DROP 
    REPEAT 
;  IMMEDIATE


{  This is a test of the Pascal style multi-line comment.

If it works correctly all of this text should be ignored.

If it does not work, we will abort with an error when
this file is included 

}    

