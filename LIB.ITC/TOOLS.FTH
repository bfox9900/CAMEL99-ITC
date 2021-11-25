CR .( Programmer Tools 2.2 Aug 2021)
NEEDS FORGET FROM DSK1.FORGET
NEEDS CASE   FROM DSK1.CASE
NEEDS DEFER  FROM DSK1.DEFER

\ From Neil Baud's Ugly Page. RIP Neil :(
\ Print HEX and Binary numbers unsigned
DECIMAL
: <.>    . ;
DEFER .

: (.)    ( n -- )
   CASE BASE @
    10 OF  DUP ABS 0 <# #S ROT SIGN #>                           ENDOF
    16 OF          0 <#  BEGIN  # #   2DUP OR WHILE REPEAT #>    ENDOF
     2 OF          0 <#  BEGIN  # # # #  2DUP OR WHILE REPEAT #> ENDOF
                   0 <#  #S #>
                   0
   ENDCASE  TYPE SPACE ;

: FAST#S    ['] <.> IS . ;
: SMART#S   ['] (.) IS . ;

SMART#S

DEFER MEM@
DEFER MEMC@

.( ..)
HEX
: ?      ( adr -- ) @ . ;
\ : DEPTH  ( -- n )   SP0 SP@ 2+ - 2/ ;

: .S        ( -- )
      ." |"
      DEPTH
      IF
         0 DEPTH 2-
         DO    I PICK  .    -1 +LOOP
      THEN ;
.( ..)

HEX
: ?BREAK  ( -- ) ?TERMINAL ABORT" *BREAK*" ;
: SPACEBAR ( -- ) KEY? BL = IF  KEY DROP  THEN ;
: .ID     ( NFAaddr --) COUNT 1F AND TYPE ;
.( ..)
: WORDS   ( -- )
           CR
           0 >R        ( word counter on rstack)
           CONTEXT @ @
           BEGIN DUP
           WHILE
              ?BREAK SPACEBAR
              DUP .ID SPACE
              R> 1+ >R
              NFA>LFA @
           REPEAT
           DROP
           CR R>
           BASE @ >R
           DECIMAL . SPACE ." words"
           R> BASE ! ;

.( ..)
: .####   ( n --) 0 <#  # # # #  #> TYPE ;

: .ASCII  ( adr n --)
          BOUNDS
          DO
            I MEMC@ DUP
            80 [ BL 1- ] LITERAL WITHIN ( ascii 127..31)
            IF DROP [CHAR] .
            THEN EMIT
          LOOP ;

DECIMAL
: ?80 ( -- 16 | 8)  C/L @ 80 = IF 16 ELSE 8 THEN ;
.( ..)
HEX
: (DUMP)   ( offset n -- )
         BASE @ >R
         HEX
         BOUNDS   ( -- endadr startadr)
         DO PAUSE
         CR  I  .####  [CHAR] : EMIT
             I  ?80  BOUNDS DO  SPACE I MEM@ .####  2 +LOOP SPACE
             I  ?80  .ASCII
             SPACEBAR
             ?BREAK
          ?80 +LOOP
          CR
          R> BASE ! ;

: DUMP    ['] @  IS MEM@    ['] C@  IS MEMC@   (DUMP) ;
: VDUMP   ['] V@ IS MEM@    ['] VC@ IS MEMC@  (DUMP) ;
\ : SDUMP   ['] @P IS MEM@    ['] C@P IS MEMC@  (DUMP) ;

.( ..)
: UNUSED   ( -- u) RP@ 20 +  HERE - ;   \ ANS Forth 94 word

: .FREE      BASE @ >R
             DECIMAL
             CR ." Free Mem"
             CR ." Low Heap :  " 3FFF H @  - U.
             CR ." Upper mem: " UNUSED U.
             CR ." VDP mem  : " VDPTOP  VP @ - .
             R> BASE ! ;
DECIMAL
.FREE
HEX
CR .( SMART#S formatting ON )
