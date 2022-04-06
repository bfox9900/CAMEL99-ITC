\ there was an old lady, in ANS Forth,  from Rosetta Code
\ ported to CAMEL99 Forth V2.

\ store a stack string at HERE , with a count
: STRING, ( c-addr u -- ) DUP C, HERE SWAP DUP ALLOT CMOVE ;

\ create doubly linked list in the Forth dictionary:
\ structure:  0|prev, 0|next, aside?, $tring animal; $tring aside

\ Note:  make ASIDE? field true if the aside is always displayed.
VARIABLE SWALLOWED
VARIABLE FIRST

: >NEXT   ( swallow-addr -- swallow-addr' ) CELL+ @ ;
: >ASIDE? ( swallow-addr -- f )        2 CELLS + @ ;
: >ANIMAL ( swallow-addr -- c-addr u ) 3 CELLS + COUNT ;
: >ASIDE  ( swallow-addr -- c-addr u ) >ANIMAL + COUNT ;

\ create a new entry in the list
: SWALLOW ( "animal" -- )
        ALIGN SWALLOWED @
        IF    HERE SWALLOWED @ CELL+ !
        ELSE  HERE FIRST !
        THEN  HERE SWALLOWED @ , SWALLOWED !
        0 , 0 , BL PARSE-WORD STRING, ; \ data structure still needs the aside

\ set the ASIDE? field of last-defined SWALLOW to true
: ALWAYS ( -- ) SWALLOWED @ 2 CELLS + ON ;

\ compile the string for the "ASIDE" portion of the song
: ASIDE ( "aside" -- ) 0 PARSE STRING, ;

\ write/compile the data base
SWALLOW fly    ALWAYS ASIDE But I don't know why she swallowed a fly,
SWALLOW spider ALWAYS ASIDE That wriggled and jiggled and tickled inside her;
SWALLOW bird   ASIDE Quite absurd, she swallowed a bird;
SWALLOW cat    ASIDE Fancy that, she swallowed a cat;
SWALLOW dog    ASIDE What a hog, she swallowed a dog;
SWALLOW pig    ASIDE Her mouth was so big, she swallowed a pig;
SWALLOW goat   ASIDE She just opened her throat, and swallowed a goat;
SWALLOW cow    ASIDE I don't know how, she swallowed a cow;
SWALLOW donkey ASIDE It was rather wonky, she swallowed a donkey;

: ?ASIDE ( swallow-addr -- )  \ print aside if aside? is true
         DUP >ASIDE?
         IF  >ASIDE CR TYPE
         ELSE DROP
         THEN ;

DECIMAL
: REASONS ( swallow-addr -- )  \ print reasons she swallowed something
          BEGIN
            DUP @
          WHILE
            DUP CR ." She swallowed the " >ANIMAL TYPE ."  to catch the "
            @ DUP >ANIMAL TYPE ." ," DUP ?ASIDE
            500 MS
          REPEAT DROP ;

: VERSE ( swallow-addr -- )
        CR ." There was an old lady who swallowed a " DUP >ANIMAL TYPE ." ," 
        1000 MS
        DUP >ASIDE CR TYPE  1000 MS
        REASONS
        CR ." Perhaps she'll die!"
        CR ." -------------------"
        1500 MS  ;

: SONG ( -- )
       PAGE
       FIRST @ BEGIN DUP VERSE CR >NEXT DUP 0= UNTIL DROP
       CR ." There was an old lady who swallowed a"
       CR ." horse..."  1000 MS
       CR
       CR ." SHE'S DEAD, OF COURSE!" ;
