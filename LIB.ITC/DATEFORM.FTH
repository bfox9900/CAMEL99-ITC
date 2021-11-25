\ DATEFORM.FTH    date formatting words    02MAR91  FOX
\ Ported to Camel99 Forth Nov 24 2021
DECIMAL
\ From Rosseta Code
\ Zeller's Congruence for Julian Calendar.
: ZELLER ( m -- days since march 1 )
  9 + 12 MOD 1-   26 10 */ 3 + ;

: WEEKDAY ( d m y -- 0..6 )   \ Monday..Sunday
  OVER 3 < IF 1- THEN
  DUP    4 /
  OVER 100 / -
  OVER 400 / +  +
  SWAP ZELLER + +
  1+ 7 MOD ;

\ compact string array. Uses count byte as link to next string.
: NTH$ ( $array n -- address len )
  0 DO  COUNT +  ALIGNED  LOOP COUNT ;

CREATE MONTHS
  S"  " S,    S" Jan" S,
  S" Feb" S,  S" Mar" S,
  S" Apr" S,  S" May" S,
  S" Jun" S,  S" Jul" S,
  S" Aug" S,  S" Sep" S,
  S" Oct" S,  S" Nov" S,
  S" Dec" S,  0 ,

: ]MONTH  ( n -- addr len)
  DUP 13 1 WITHIN ABORT" Bad month#"
  MONTHS SWAP NTH$ ;

CREATE DAYS
  S"  " S,
  S" Monday" S,
  S" Tuesday" S,
  S" Wednesday" S,
  S" Thursday" S,
  S" Friday" S,
  S" Saturday" S,
  S" Sunday" S,
  0 ,

: ]DAY ( n --) DAYS SWAP 1+ DUP 7 1 WITHIN ABORT" Bad day#"  NTH$ ;

: ##     BASE@ >R 0 <#   # #  #>   TYPE  R> BASE ! ;
: ####   BASE@ >R 0 <#  # # # # #> TYPE  R> BASE ! ;

: 3DUP    2 PICK 2 PICK 2 PICK ;

: .M/D/Y      ( dd mm yyyy -- ) >R  ## ." /" ## ." /"  R> #### ;
: .Y-M-D      ( dd mm yyyy -- ) #### ." -"  ## ." -" ## ;
: .D.M.Y      ( dd mm yyyy -- ) >R SWAP  ## ." ." ## ." ."  R> #### ;
: .USADATE    ( dd mm yyyy -- ) >R ]MONTH TYPE SPACE  ##  ." , " R> #### ;
: .FORTH-DATE ( dd mm yyyy -- ) >R SWAP ## ]MONTH TYPE R> ## ;

: .LONG-DATE ( dd mm yyyy -- )
  3DUP WEEKDAY ]DAY TYPE ." , " >R  ]MONTH TYPE SPACE ## ." , " R> .
;
