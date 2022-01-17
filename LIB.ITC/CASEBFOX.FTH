\ CASEBFOX   uses EXIT to jump out as soon as match is found.
\ like a switch statment

INCLUDE DSK1.CASE
INCLUDE DSK1.ELAPSE

: :CASE  ( -- )
          POSTPONE OVER   POSTPONE =
          POSTPONE IF POSTPONE DROP   ; IMMEDIATE

: END ( -- ) POSTPONE EXIT  POSTPONE THEN ; IMMEDIATE

\ Justification tests
: FOX
        1 :CASE ." ONE"       END
        2 :CASE ." TWO"       END
        3 :CASE ." THREE"     END
        4 :CASE ." FOUR"      END
        5 :CASE ." FIVE"      END
        6 :CASE ." SIX"       END
        7 :CASE ." SEVEM"     END
        8 :CASE ." EIGHT"     END
        9 :CASE ." NINE"      END
        10 :CASE ." TEN"      END
        11 :CASE ." ELEVEN"   END
        12 :CASE ." TWELVE"   END
        13 :CASE ." THIRTEEN" END
        14 :CASE ." FOURTEEN" END
        15 :CASE ." FIFTEEN"  END
                 ." ???"   DROP
;

: EAKER  CASE
        1 OF ." ONE"       ENDOF
        2 OF ." TWO"       ENDOF
        3 OF ." THREE"     ENDOF
        4 OF ." FOUR"      ENDOF
        5 OF ." FIVE"      ENDOF
        6 OF ." SIX"       ENDOF
        7 OF ." SEVEM"     ENDOF
        8 OF ." EIGHT"     ENDOF
        9 OF ." NINE"      ENDOF
        10 OF ." TEN"      ENDOF
        11 OF ." ELEVEN"   ENDOF
        12 OF ." TWELVE"   ENDOF
        13 OF ." THIRTEEN" ENDOF
        14 OF ." FOURTEEN" ENDOF
        15 OF ." FIFTEEN"  ENDOF
                 ." ???"   DROP
      ENDCASE
;

: .TMR       TMR@ - SPACE . ;

: FOX1  TMR@  1 FOX .TMR ;  \ 124
: FOX15 TMR@  15 FOX .TMR ; \ 338

: EAKER1 TMR@ 1 EAKER .TMR ;  \ 126
: EAKER15 TMR@ 15 EAKER .TMR ; \ 340

\ Not worth the trouble :) 
