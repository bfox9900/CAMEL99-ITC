\ Mini-OOF   Bernd Paysan                            12apr98py

\ INCLUDE INLIN99.FTH 

: COMPILE, ( n -- ) , ;  \ not in CAMEL99 Kernel

: NOOP ; 

: METHOD ( m v "name" -- m' v )
         CREATE  OVER , SWAP CELL+ SWAP
         DOES> ( ... O -- ... ) INLINE[ @ OVER @ + @ ] EXECUTE ;

: VAR    ( m v size "name" -- m v' )
         CREATE  OVER , +
         DOES> ( O -- ADDR ) INLINE[ @ + ]  ;

: CLASS  ( class -- class methods vars ) DUP 2@ ;

: END-CLASS ( class methods vars "name" -- )
         CREATE  HERE >R , DUP , 2 CELLS
                 ?DO ['] NOOP , 1 CELLS +LOOP
                 CELL+ DUP CELL+ R> ROT @ 2 CELLS /STRING CMOVE ;

: DEFINES ( xt class "name" -- ) ' >BODY @ + ! ;

: NEW ( class -- O )  HERE OVER @ ALLOT SWAP OVER ! ;

: :: ( class "name" -- ) ' >BODY @ + @ COMPILE, ;

CREATE OBJECT  1 CELLS , 2 CELLS ,
