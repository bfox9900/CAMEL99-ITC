\ Amstrad NC100 Z80 4.606Mhz	VolksForth CP/M (ITC)	Integer Calc	0:06.23
\ 8086 5Mhz	Laxen/Perry F83	                  Integer Calc        0:09.0
\ C64	DurexForth 1.6.1 (STC)                	Integer	Calc        0:37.0
\ Rockwell R1200-14, 2Mhz 65F12	RSC-Forth	    Integer Calc	      0:31.0
\ Amstrad 6128+ Z80A 4Mhz	Uniforth	          Integer Calc	      0:17.0
\ TI99 Camel99 Forth (ITC)                    Integer Calc        0:14.76
\  with inline optimizing                                         0:10.85 

\                    (DTC)                                        0:12.4
\    (DTC)   with inline next                                     0:11.90
\    (DTC)   with inline next & hispeed PRIMS                     0:11.76
\ MSP430FR5739, 8Mhz CamelForth	              Integer Calc 100x	02'45':10
\                                             Scaled to 1X        0:01.65

INCLUDE DSK1.ELAPSE

: BENCHME ( XT N -- ) 
  DUP >R 
  0 DO DUP EXECUTE LOOP 
  CR R> . ." ITERATIONS." CR \
;

DECIMAL
32000 CONSTANT INTMAX

VARIABLE INTRESULT

: DOINT
  1 DUP INTRESULT DUP >R !
  BEGIN
    DUP INTMAX <
  WHILE
    DUP NEGATE R@ +! 1+
    DUP R@ +! 1+
    R@ @ OVER * R@ ! 1+
    R@ @ OVER / R@ ! 1+
  REPEAT
  R> DROP DROP
;

\ ELAPSE DOINT

INCLUDE DSK1.INLINE

: DOINT2 
  INLINE[ 1 DUP INTRESULT DUP >R ! ]
  BEGIN
    INLINE[ DUP INTMAX < ]
  WHILE
    INLINE[ DUP NEGATE R@ +! 1+    DUP R@ +! 1+ ]
    INLINE[ R@ @ OVER ] *  INLINE[ R@ ! 1+ ]
    INLINE[ R@ @ OVER ] /  INLINE[ R@ ! 1+ ]
  REPEAT
  R> DROP DROP
;


