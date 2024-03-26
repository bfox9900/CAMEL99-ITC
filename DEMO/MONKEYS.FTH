\ monkeys.fth
\ TESTED with verison 2.70

\ NEEDS .S  FROM DSK1.TOOLS  \ DEBUGGING ONLY 
NEEDS RND FROM DSK1.RANDOM

DECIMAL
VARIABLE WORD_LEN
VARIABLE CHARSOUT
VARIABLE WORDSOUT

HEX 7FFF CONSTANT 32K

\ : 1+!  ( addr -- ) 1 SWAP +! ; ( THIS IS IN KERNEL VERSION F and up)
: CLIP  ( n min max -- n') ROT MIN MAX ;

: Vowels       S" AEIOU" ;
: Consonants   S" BCDFGHJKLMNPQRSTVWXYZ" ;

: BETWEEN ( n min max -- ? )  1+ WITHIN ;
: UALPHA? ( c -- ?)  [CHAR] A [CHAR] Z BETWEEN ;
: LOWER?  ( c -- ?)  [CHAR] a [CHAR] z BETWEEN ;
: TOUPPER ( c -- c) DUP LOWER? IF 05F AND THEN ;

DECIMAL
: MEMBER? ( char addr len -- ? ) ROT SCAN NIP 0> ;
: VOWEL?  ( char -- ? )    TOUPPER Vowels MEMBER? ;
: CONSONANT? ( char -- ? ) TOUPPER Consonants MEMBER? ;

VARIABLE PREVIOUS-CHAR
\ PREVIOUS VALUES: -1=VOWEL, 0=UNDEFINED,  1=CONSONANT

-1 CONSTANT AVOWEL
 1 CONSTANT ACONST

VARIABLE CONSONANTS
VARIABLE VOWELS

: NEW-WORD  ( -- ) CONSONANTS OFF   VOWELS OFF   PREVIOUS-CHAR OFF ;

: MONKEY-FINGER ( -- char)
                BEGIN
                  26 RND [CHAR] A +
                  DUP UALPHA?
                UNTIL
                CHARSOUT 1+! ;

: REMEMBER ( char -- )
          DUP VOWEL?
          IF
             AVOWEL  PREVIOUS-CHAR !
             VOWELS 1+!
             CONSONANTS OFF
          ELSE
             ACONST  PREVIOUS-CHAR !
             CONSONANTS 1+!
             VOWELS OFF
          THEN ;

: KILL|KEEP ( char ? -- char | ?)  IF  DROP FALSE  ELSE TRUE THEN ;

: GETVOWEL ( -- vowel-char)
          BEGIN
            MONKEY-FINGER DUP CONSONANT? KILL|KEEP
          UNTIL ;

: GETCONST ( -- consonant-char)
          BEGIN
            MONKEY-FINGER DUP VOWEL? KILL|KEEP
          UNTIL ;

: CONSONANTS? ( char n -- ?)
         CONSONANTS @ =    PREVIOUS-CHAR @ ACONST = AND ;

: VOWELS?     ( char n -- ?)
         VOWELS @     =    PREVIOUS-CHAR @ AVOWEL =  AND ;
\ Rules:
\ never more than 2 vowels in a row
\ never more than 1 consonants in a row
: RULES   ( CHAR -- CHAR )
           1 CONSONANTS?  IF  DROP    GETVOWEL  THEN
           2 VOWELS?      IF  DROP    GETCONST  THEN
           REMEMBER ;

\ 1 random key stroke, remember it and check rules , count char
: TYPE-WRITER ( -- char) MONKEY-FINGER  RULES ;

: MONKEY-WORD ( -- )
         NEW-WORD
         WORD_LEN @ RND 1+ 0
         ?DO
            TYPE-WRITER EMIT
         LOOP
         WORDSOUT 1+!
        SPACE ;

: WAITKEYUP  ( -- ) BEGIN KEY? 0= UNTIL ;
: WAITKEY    ( -- ) KEY? IF KEY DROP THEN ;

: TAB        ( n --) VCOL @ 8 MOD SPACES  ;

DECIMAL
: MONKEY-LINE  ( -- )
          CR   MONKEY-WORD  13 TAB  MONKEY-WORD  26 TAB MONKEY-WORD ;

: TITLE PAGE
  CR 2 TAB ." IF..."
  CR
  CR 2 TAB ." an infinite number of monkeys, with"
  CR 2 TAB ." an infinite number of typewriters,"
  CR 2 TAB ." type for an infinite amount of time,"
  CR 2 TAB ." they will type the complete works"
  CR 2 TAB ." of Shakespeare."
  CR
  CR 29 TAB ." Anonymous"

  10 23 AT-XY  ." Press a key to begin..." KEY DROP ;

: MONKEYS  ( -- )
         27 7 VWTR
         TITLE PAGE
         CHARSOUT OFF
         WORDSOUT OFF
         8 WORD_LEN !
         CR ." Max word length = " WORD_LEN @ .
         BEGIN
           WAITKEY
           MONKEY-LINE
          ?TERMINAL
         UNTIL
         WAITKEYUP
         CR
         CR ." The monkeys typed " CHARSOUT @ U.  ." characters
         CR ." in " WORDSOUT @ . ." words." ;
