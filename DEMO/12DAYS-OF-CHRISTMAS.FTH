\ 12 DAYS OF CHRISTMAS from Rossetta Code
\ Modified for Camel99 Forth  Brian Fox

INCLUDE DSK1.TOOLS

: {  0 , ;
: }  0 , ;

CREATE ORDINALS
  { S" first" S,  S" second" S,  S" third"    S,  S" fourth"  S,
    S" fifth" S,  S" sixth"  S,  S" seventh"  S,  S" eighth"  S,
    S" ninth" S,  S" tenth"  S,  S" eleventh" S,  S" twelfth" S, }


: NTH  ( addr n -- addr' len) 0 ?DO  COUNT + ALIGNED  LOOP ;

: .ORDINAL  ( n -- n)  ORDINALS OVER NTH COUNT TYPE ;

CREATE GIFTS
  { S" A partridge in a pear tree." S,
    S" Two turtle doves and" S,
    S" Three French hens," S,
    S" Four calling birds," S,
    S" Five gold rings, (DUM DA DUM DUM!)" S,
    S" Six geese a-laying," S,
    S" Seven swans a-swimming," S,
    S" Eight maids a-milking," S,
    S" Nine ladies dancing," S,
    S" Ten lords a-leaping," S,
    S" Eleven pipers piping," S,
    S" Twelve drummers drumming," S, }


: .GIFT    ( n -- addr len)  GIFTS SWAP NTH COUNT TYPE ;
: STUFF... ( n --) 0 SWAP DO  I .GIFT CR  1000 MS   -1 +LOOP ;

: DAY ( n --)
  CR ." On the " .ORDINAL ."  day of Christmas,"
  CR ." my true love sent to me:" 400 MS
  CR
  CR STUFF...
  CR
  CR ." ..."
;

: MAIN   13 1 DO  I DAY  LOOP  ;

\ MAIN