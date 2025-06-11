\ mapfile.fth  for single file processing jobs  Brian Fox June 2025

\ NEEDS .S        FROM DSK1.TOOLS

\ These words normally part of big Forth systems.
\ TI-99 limited memory so they are only compiled when needed
NEEDS OPEN-FILE FROM DSK1.ANSFILES

VARIABLE maphndl
: MAPFILE ( $addr len XT -- )
        >R
        DV80 R/W OPEN-FILE ?FILERR maphndl !
        BEGIN
          PAD DUP 80 maphndl @ READ-LINE NIP 0= ( $adr len ? )
        WHILE
          ( addr len) R@ EXECUTE
        REPEAT
        maphndl @ CLOSE-FILE DROP
        R> DROP
;

\
\ COUNT words in a file
\

DECIMAL
: WORDCOUNTER ( addr len -- n)
    0 >R                  \ counter on rstack
    BEGIN
        BL SKIP           \ skip leading blanks
    DUP WHILE
        R> 1+ >R          \ bump counter
        BL SCAN           \ advance to next blank
    REPEAT
    2DROP                 \ remove input string
    R>                    \ put counter on data stack
;

\
\ count words in a file
\
VARIABLE #WORDS
: WORDS++    ( addr len -- )  WORDCOUNTER #WORDS +! ;
: COUNTWORDS ( $addr len -- n ) #WORDS OFF   ['] WORDS++ MAPFILE  #WORDS @ ;

\
\ count lines in a file
\
: LINES++  ( addr len --)  2DROP LINES 1+! ;
: COUNTLINES  LINES OFF  ['] LINES++ MAPFILE  LINES @ ;

\
\ view a file
\
: ?KEYPRESS  KEY? IF KEY DROP THEN ;
: PRINTLN ( addr len -- )  CR ?KEYPRESS TYPE ;
: VIEW    ( addr len --) ['] PRINTLN  MAPFILE ;

\
\ count non-white characters in a file
\
VARIABLE #CHARS
: ASCII? ( char -- ?) [CHAR] ! [CHAR] ~ 1+ WITHIN ;
: #ASCII  ( addr len -- n)
    0 -ROT  BOUNDS DO  I C@ ASCII? IF 1+ THEN  LOOP   #CHARS +! ;

: COUNTCHARS  #CHARS OFF  ['] #ASCII MAPFILE  #CHARS @ ;
