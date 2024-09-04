
\ scan keyword array for addr,len string 
\ -1 means not found 
: KEYWORD? ( addr len -- -1 | n)
      #KEYWORDS @ KWORD# ! \ search from bottom to top 
      BEGIN 
         KWORD# @ -1 >  
      WHILE 
         2DUP KEYWORD$ COUNT COMPARE 
      WHILE    
         KWORD# 1-! 
      REPEAT
      THEN 
      2DROP
      KWORD# @ ;
;

: PARSE-FOR-KEY ( addr len -- ?)
      TRIM 
      BEGIN
         DUP 0> ( len>0)
      WHILE
         1WORD KEYWORD? DUP 
      TRUE = WHILE 
         DROP 
      REPEAT

      THEN 
;

