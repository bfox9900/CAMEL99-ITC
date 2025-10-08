\ CASEBFOX   uses EXIT to jump out as soon as match is found.
\ like a switch statement

\ INCLUDE DSK1.TOOLS
\ hi level Forth
\ : :CASE   POSTPONE OVER  POSTPONE =  POSTPONE IF  POSTPONE DROP ; IMMEDIATE

: :CASE  ( n --) POSTPONE OVER=  POSTPONE IF  POSTPONE DROP ; IMMEDIATE
: BREAK; ( -- )  POSTPONE EXIT  POSTPONE THEN ; IMMEDIATE

: TEST
        1 :CASE ." ONE"   BREAK;
        2 :CASE ." TWO"   BREAK;
        3 :CASE ." THREE" BREAK;
                ." ???"   DROP ;
