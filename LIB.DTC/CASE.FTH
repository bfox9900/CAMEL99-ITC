\ ANS-Forth CASE statement
\ Originalky by Chuck E. Eaker 9/80 FORTH DIMENSIONS II/3 PG 37
\ Ported to CAMEL99 Mar 7 2017

: CASE    ( -- 0 ) 0  ; IMMEDIATE

: OF      ( -- )
          POSTPONE OVER   POSTPONE =
          POSTPONE IF POSTPONE DROP   ; IMMEDIATE

\ Common Forth extension. Can use arbitrary compare operations
: ?OF    ( flag -- here )
          POSTPONE DUP
          POSTPONE IF POSTPONE DROP  ; IMMEDIATE

: ENDOF   ( -- )
          POSTPONE ELSE ; IMMEDIATE

: ENDCASE ( -- )
          POSTPONE DROP
          BEGIN ?DUP 
          WHILE POSTPONE THEN
          REPEAT ; IMMEDIATE

CR  .( 108 bytes)
