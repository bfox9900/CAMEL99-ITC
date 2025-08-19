\ VDPSTRING DEMO code
\ create string variables (the text is compiled one after the other)
 DECIMAL
 80 VDIM A$
 80 VDIM B$
 80 VDIM C$    C$ :=" 1234"

\ create string literals (cannot change these)
 : Q$       V" The single quote creates a string literal in VDP memory" ;
 : DIRTY$   V"                    <<CORE>>                            " ;

\ assigning vdp string variables with V$! ("string store")
 S" Now is the time for all good men "    A$ V$!
 S" to come to the aid of their country." B$ V$!

 : TEST
         10 0 DO
            A$ VPRINT
            B$ VPRINT
            Q$ VPRINT
         LOOP ;

: COMPTEST    10 0 DO   Q$ Q$ =V$  .    LOOP ;
: TRIMTEST    10 0 DO  DIRTY$ BL VTRIM CR VDPTYPE  LOOP ;
: SKIPTEST    10 0 DO  DIRTY$ BL VSKIP CR VDPTYPE  LOOP ;
: CLEANTEST   10 0 DO  DIRTY$ BL VSKIP  V-TRAILING CR VDPTYPE  LOOP ;

: SCANTEST
    CR
    10 0 DO
        CR A$ 2DUP VDPTYPE
        CR [CHAR] g VSCAN  VDPTYPE
        CR
    LOOP ;
