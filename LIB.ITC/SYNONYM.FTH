\ synonym for NON-CODE words   BJF Sept 27, 2018

: SYNONYM   ( <newname>  <oldword> )
           CREATE   '  ,  DOES> @ EXECUTE ;

\ From "reference implementation". Used by VFX Forth
\ : SYNONYM \ "newname" "oldname" --
\ Create a new definition which redirects to an existing one.
\   CREATE IMMEDIATE
\     HIDE ' , REVEAL
\   DOES>
\     @ STATE @ 0= OVER IMMEDIATE? OR
\     IF EXECUTE ELSE COMPILE, THEN
\ ;
