\ VDP STRING LIB DEMO code

NEEDS VDIM FROM DSK1.VDPSTRINGS 

\ create string variables. Assignment at compile time
DECIMAL
 80 VDIM A$    A$ :=" This is A$ in VDP RAM :-)"
 80 VDIM B$    B$ :=" This B$ IN VDP RAM"
 80 VDIM C$    C$ :="             1234                  "
 80 VDIM D$
 80 VDIM E$

\ create string literals (cannot change these)
 : Q$       V" The Vquote word creates a string literal in VDP memory" ;
 : DIRTY$   V"                    <<CORE>>                           " ;

\ You can also assign Forth strings to VDP strings with V$!
 S" Now is the time for all good men "    D$ V$!
 S" to come to the aid of their country." E$ V$!

 : PRINT-TEST
         10 0 DO
            A$ VPRINT
            B$ VPRINT
            Q$ VPRINT
         LOOP ;

: .EQ/NE   ( ? --) IF ." EQUAL " ELSE  ." Not equal "  THEN ;

: =TEST     100 0 DO  Q$ Q$     =V$  .EQ/NE  LOOP ;
: <>TEST    100 0 DO  DIRTY$ Q$ =V$  .EQ/NE  LOOP ;

: TRIMTEST  100 0 DO  DIRTY$ BL VTRIM 2DROP  LOOP  DIRTY$ BL VTRIM VPRINT ;
: SKIPTEST  100 0 DO  DIRTY$ BL VSKIP 2DROP  LOOP  DIRTY$ BL VSKIP VPRINT ;

: CLEANTEST 100 0 DO  DIRTY$ BL VSKIP  BL VTRIM 2DROP  LOOP
                      DIRTY$ BL VSKIP  BL VTRIM VPRINT ;

: CONCAT-TEST 100 0 DO  D$ E$ &  2DROP  LOOP  D$ E$ & VPRINT ;
