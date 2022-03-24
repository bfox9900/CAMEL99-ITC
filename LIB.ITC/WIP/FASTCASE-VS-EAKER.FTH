\ vector table FASTCASE.FTH vs EAKER case   Mar 24 2022
\ Load this file. Results will print on the screen
\ Conclusion: Use for case statements with more than 4 selections

\  FASTCASE is:
\  3% faster on 1st item
\  1.2X faster on 4th item
\  1.4X faster on 8th item
\  1.6X faster for 15th item
\

INCLUDE DSK1.CASE
INCLUDE DSK1.FASTCASE

: ONE    ." ONE"       ;
: TWO    ." TWO"       ;
: THREE  ." THREE"     ;
: FOUR   ." FOUR"      ;
: FIVE   ." FIVE"      ;
: SIX    ." SIX"       ;
: SEVEN  ." SEVEM"     ;
: EIGHT  ." EIGHT"     ;
: NINE   ." NINE"      ;
: TEN    ." TEN"       ;
: ELEVEN ." ELEVEN"    ;
: TWELVE ." TWELVE"     ;
: THIRTEEN ." THIRTEEN" ;
: FOURTEEN ." FOURTEEN" ;
: FIFTEEN  ." FIFTEEN"  ;


\ Justification tests
CASE: FAST
  | PAUSE  |  ONE    |  TWO    |  THREE     |  FOUR
  |  FIVE  |  SIX    |  SEVEN  |  EIGHT    |  NINE
  |  TEN   |  ELEVEN |  TWELVE |  THIRTEEN |  FOURTEEN
  |  FIFTEEN  | PAUSE
;CASE

: EAKER  ( n -- )
     CASE
        1  OF  ONE       ENDOF
        2  OF  TWO       ENDOF
        3  OF  THREE     ENDOF
        4  OF  FOUR      ENDOF
        5  OF  FIVE      ENDOF
        6  OF  SIX       ENDOF
        7  OF  SEVEN     ENDOF
        8  OF  EIGHT     ENDOF
        9  OF  NINE      ENDOF
        10 OF  TEN      ENDOF
        11 OF  ELEVEN   ENDOF
        12 OF  TWELVE   ENDOF
        13 OF  THIRTEEN ENDOF
        14 OF  FOURTEEN ENDOF
        15 OF  FIFTEEN  ENDOF
             ." ???"   DROP
      ENDCASE
;


: TMR-       TMR@ -  ;
: .uS     TMR-  213 10 */   4 SPACES  . ." uS" CR  ;

: FAST1   TMR@   1 FAST .uS ; \ 128
: FAST4   TMR@   4 FAST .uS ; \ 145
: FAST8   TMR@   8 FAST .uS ; \ 202
: FAST15  TMR@  15 FAST .uS ; \ 202


: EAKER1  TMR@   1 EAKER .uS ; \ 131
: EAKER4  TMR@   4 EAKER .uS ; \ 131
: EAKER8  TMR@   8 EAKER .uS ; \ 131
: EAKER15 TMR@  15 EAKER .uS ; \ 333

PAGE
CR FAST1 FAST4 FAST8 FAST15
CR
CR EAKER1 EAKER4 EAKER8 EAKER15
