\ synonym for NON-CODE words   BJF Sept 27, 2018
\ Create a new definition which redirects to an existing one.

\ Concept "reference implementation". Used by VFX Forth
\ This version does not correct work with IMMEDIATE words

 : SYNONYM \ "newname" "oldname" --
   CREATE     IMMEDIATE
     HIDE ' , REVEAL
   DOES>
    @ STATE @ IF COMPILE,  EXIT THEN
    EXECUTE
;
