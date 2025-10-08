\ MORSE CODE GENERATOR for Rosetta Code   Brian Fox, Feb 2016
\ Ported to Camel99 Forth May 2020
\ Updated with wordlist and lower case ability   Nov 2020

\ NEEDS TOOLS FROM DSK1.TOOLS
NEEDS VALUE FROM DSK1.VALUES
NEEDS SOUND FROM DSK1.SOUND
NEEDS MARKER FROM DSK1.MARKER
NEEDS WORDLIST FROM DSK1.WORDLISTS

ONLY FORTH DEFINITIONS

MARKER /MORSE

HEX
CODE 0LIMI   0300 , 0000 ,  NEXT, ENDCODE

: LOWER?  ( c -- c ?) DUP [CHAR] a [CHAR] z 1+  WITHIN ;
: TOUPPER ( c -- c') LOWER? IF  5F AND  THEN ;
: $UPPER  ( addr len -- ) BOUNDS ?DO  I C@ TOUPPER  I C!   LOOP ;

DECIMAL
   800 VALUE FREQ    \ 1500 Hz will be the tone freq.
   400 VALUE ADIT    \ duration of one "dit" for ~10 words per minute

: WPM  ( n -- ) 500 SWAP / 30 MAX 2* TO ADIT ;

\ Compute all durations based on ADIT
: DIT_DUR      ADIT MS ;
: DAH_DUR      ADIT 3 * MS ;
: WORDGAP      ADIT 5 * MS ;
: OFF_DUR      ADIT 2/  MS ;
: LETTERGAP    DAH_DUR ;   \ space between letters is commonly a DAH.

: TONE ( -- ) FREQ HZ  0 DB  ;

: MORSE-EMIT  ( char -- )
        DUP  BL =  IF  DROP WORDGAP  EXIT THEN  \ check for space character
        PAD C!                    \ write char to buffer
        0LIMI  \ makes more accurate timing with no interrupts
        PAD 1 EVALUATE            \ evaluate 1 character string
        LETTERGAP
;

: TRANSMIT ( ADDR LEN -- )
           2DUP $UPPER                 \ convert string, leave a copy
           CR                          \ newline,
           BOUNDS                      \ convert loop indices to address ranges
           DO
              I C@ DUP (EMIT)         \ dup and send char to console
              MORSE-EMIT              \ send the morse code
              ?TERMINAL ABORT" Transmission halted"
           LOOP ;

\ **** new namespace stops conflict with FORTH words and numbers ***
VOCABULARY MORSE  ALSO MORSE DEFINITIONS

\ dit and dah define all the rest
: .   ( -- ) TONE  DIT_DUR  MUTE  OFF_DUR ;
: -   ( -- ) TONE  DAH_DUR  MUTE  OFF_DUR ;

\ define morse letters as Forth words. They transmit when executed
: A  . -  ;     : B  - . . . ;   : C  - . - . ;    : D  - . . ;
: E  . ;        : F  . . - . ;   : G  - - . ;      : H  . . . . ;
: I  . . ;      : J  . - - - ;   : K  - . - ;      : L  . - . . ;
: M  - - ;      : N  - . ;       : O  - - - ;      : P  . - - . ;
: Q  - - . - ;  : R  . - . ;     : S  . . . ;      : T  - ;
: U  . . - ;    : V  . . . - ;   : W  . - - ;      : X  - . . - ;
: Y  - . - - ;  : Z  - - . . ;

: 0  - - - - - ;     : 1  . - - - - ;
: 2  . . - - - ;     : 3  . . . - - ;
: 4  . . . . - ;     : 5  . . . . . ;
: 6  - . . . . ;     : 7  - - . . . ;
: 8  - - - . . ;     : 9  - - - - . ;

: '  - . . - . ;
: \  . - - - . ;
: !  . - . - . ;

: ?  . . - - . . ;
: ,  - - . . - - ;
: /  . . . - . - ;  ( SK means end of transmission in int'l Morse code)
: .  . - . - . - ;

FORTH DEFINITIONS
( ~ 10 words per minute )
: TEST
   PAGE  ." Morse Code Transmitter Demo"
   CR
   5 WPM
   CR S" Let's try 5 WPM." 2DUP TYPE
   1000 MS
   CR MORSE TRANSMIT
   CR
   CR ." Now something more appropriate:"  500 MS
   CR ." at 15 WPM"

   800 TO FREQ
   15 WPM
   CR S" CQ CQ CQ DE VE3CFW / K " MORSE TRANSMIT

   950 TO FREQ
   14 WPM S" VE3CFW DE WB6LLA WB6LLA R R" TRANSMIT
   S" U R  5 BY 9 OM HERE IN CALIFORNIA" TRANSMIT
   S" QTH  SAN DIEGO  SAN DIEGO USA." TRANSMIT
   6 WPM S" K " TRANSMIT
;

CR .( Type TEST to run DEMO)
