\  HEADLESS.FTH

NEEDS DUMP   FROM DSK1.TOOLS
NEEDS MALLOC FROM DSK1.MALLOC


DECIMAL
1024 MALLOC CONSTANT []HEADS

\ Head space memory managers
DECIMAL
VARIABLE HDP  []HEADS  HDP !
: HDHERE    HDP @ ;
: HDALLOT    HDP +! ;
: HD,       HDHERE !  2 HDALLOT ;
: HDC,      HDHERE C!  1 HDALLOT ;
: HEAD$,    ( c-addr u -- ) HDHERE OVER 1+ HDALLOT PLACE  ;

: HEADLESS, ( addr len --)
      ALIGN
      CURRENT @  DUP>R   \ Fetch CURRENT wid, make a copy for later
\ === compile the header fields ===
      @ DUP ,  HD,       \ fetch the NFA & compile in real dictionary and headless
      0 C,               \ compile the precedence byte (immediate flag)
      0 C,               \ compile empty name length real dictionary
      HDHERE DUP LATEST !  \ HERE is now a new NFA, store NFA in LATEST
      R>  !               \ & also in the current 'WID' we saved earlier
      HEAD$, ;            \ compile name in headless dictionary

: CONS  ( n --)  PARSE-NAME HEADLESS,   COMPILE DOCON   COMPILE, ;
