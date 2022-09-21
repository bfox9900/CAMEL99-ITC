\ CASEBFOX.FTH   uses EXIT to jump out as soon as match is found.
\ like a switch statment

\ INCLUDE DSK1.TOOLS

\  
\ : :CASE  ( -- )
\          POSTPONE OVER   POSTPONE =
\          POSTPONE IF POSTPONE DROP   ; IMMEDIATE

\ faster version & uses less space per case
HEX
CODE  (OF)
 6116 ,                \ *SP TOS CMP, ( OVER = )
 04C4 ,                \     TOS CLR,
 1601 ,                \ EQ IF,
 0704 ,                \     TOS SETO,
                       \ ENDIF,
 0460 , ' ?BRANCH @ ,  \ ' ?BRANCH @ @@ B, 
ENDCODE

: :CASE  ( n --)  POSTPONE (OF) ; IMMEDIATE 
: BREAK; ( -- )   POSTPONE EXIT  POSTPONE THEN ; IMMEDIATE

\ : TEST
\        1 :CASE ." ONE"   BREAK;
\        2 :CASE ." TWO"   BREAK;
\        3 :CASE ." THREE" BREAK;
\                ." ???"   DROP ; ( default condition)
