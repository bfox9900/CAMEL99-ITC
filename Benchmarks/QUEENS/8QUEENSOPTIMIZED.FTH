\ ********************
\ Eight queens problem
\ ********************
\ Taken from SP-Forth 4 - samples\bench\queens.f
\ Al.Chepyzhenko

NEEDS CARRAY FROM DSK1.ARRAYS
NEEDS INLINE[ FROM DSK1.INLINE
NEEDS ELAPSE FROM DSK1.ELAPSE

DECIMAL
8  CARRAY Gori
8  CARRAY Verti
15 CARRAY Dio1
15 CARRAY Dio2

: Clear ( -- )
   8 0 DO 0 I Verti C! LOOP
  15 0 DO 0 I Dio1  C! LOOP
  15 0 DO 0 I Dio2  C! LOOP ;


: Check ( n -- f )
  Clear
  TRUE
  SWAP 1+ 0
  DO
      I Gori C@
      DUP Verti INLINE[ DUP C@ ]
      IF
        INLINE[ DROP DROP DROP FALSE ]
      ELSE
          INLINE[ TRUE SWAP C! ]
          INLINE[ DUP I + ] Dio1 INLINE[ DUP C@ ]
          IF
            INLINE[ DROP DROP DROP FALSE ]
          ELSE
            INLINE[ TRUE SWAP C! ]
            INLINE[ DUP 7 + I - ] Dio2 INLINE[ DUP C@ ]
              IF
                INLINE[ DROP DROP DROP FALSE ]
              ELSE
                INLINE[ TRUE SWAP C! DROP TRUE AND ]
              THEN
          THEN
      THEN
  LOOP ;

: Print ( -- )
  8 0
  DO
   I Gori C@ .
  LOOP CR ;

: TRYTO ( n )
  8 0
  DO
      INLINE[ I OVER ] Gori C!
      DUP Check
      IF
          INLINE[ DUP 7 ] <
          IF INLINE[ DUP 1+ ] RECURSE  THEN
      THEN
  LOOP
  DROP
  ;

1 CONSTANT /QUEENS

: $QUEENS$      \ --
  CR ." Eight Queens Problem"
  /QUEENS 0 DO  0 TRYTO  LOOP  /QUEENS
;

\ Tests are for 1 iteration because it's so slow.
\  CAMEL269  4:48.28  (Unoptimized 5:30.35)
