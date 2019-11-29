\ Mini-OOF   Bernd Paysan                            12apr98py
\ a VERY small object oriented language extension 
\ https://www.complang.tuwien.ac.at/forth/gforth/Docs-html/Mini_002dOOF.html#Mini_002dOOF

\ : COMPILE, ( n -- ) , ;

: NOOP ; 

: METHOD ( m v "name" -- m' v )
         CREATE  OVER , SWAP CELL+ SWAP
         DOES> ( ... O -- ... )  @ OVER @ + @ EXECUTE ;

: VAR    ( m v size "name" -- m v' )
         CREATE  OVER , +
         DOES> ( O -- ADDR )  @ +  ;

: CLASS  ( class -- class methods vars ) DUP 2@ ;

: END-CLASS ( class methods vars "name" -- )
         CREATE  HERE >R , DUP , 2 CELLS
                 ?DO ['] NOOP , 1 CELLS +LOOP
                 CELL+ DUP CELL+ R> ROT @ 2 CELLS /STRING CMOVE ;

: DEFINES ( xt class "name" -- ) ' >BODY @ + ! ;

: NEW ( class -- O )  HERE OVER @ ALLOT SWAP OVER ! ;

: :: ( class "name" -- ) ' >BODY @ + @ COMPILE, ;

\ The "root" object". All new objects are a child of OBJECT
CREATE OBJECT  1 CELLS , 2 CELLS ,
