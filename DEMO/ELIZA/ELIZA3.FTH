\ ELIZA in CAMEL99 Forth

\ This implementation uses the Forth dictionary as a big case statement
\ Eliza's KEYWORD phrases are converted to Forth words by removing the spaces.

\ Example:
\ "I CAN'T" becomes ICANT.  ICANT is a valid FORTH word so all
\ we need is a word in the dictionary called ICANT to make something
\ happen.

\ This allows synonyms to be created using a colon definition and adding
\ the new keyword to the KEYWORDS list.
\ Example:  : ICANT    ICANNOT  ;
\ The definition for ICANNOT will do the same thing as ICAN'T

 INCLUDE DSK1.TOOLS.F  \  for debugging


\ ======[ punctuation characters ]======
DECIMAL
CHAR ~ CONSTANT '~'   \ strings that end with '~' reflect the users input
CHAR , CONSTANT ','
CHAR . CONSTANT '.'

\ working memory for string processing
CREATE INPUT$  81 ALLOT  \ holds the "clean" reply from the patient

\ === string stack in HEAP ====
         VARIABLE SSP     \ the string stack pointer
     255 CONSTANT MXLEN   \ 255 bytes is longest string
MXLEN 1+ CONSTANT SSW     \ width of string stack items

SSW 10 * MALLOC CONSTANT $STAK  \ ten strings deep  (2.5 Kbytes!)

: NEW:     ( -- ) SSW SSP +! ;  \ bump string stack pointer by 256
: COLLAPSE ( -- ) SSP OFF  ;    \ reset string stack pointer to zero

: TOP$     ( -- $) SSP @ $STAK + ;

\ string stack helpers ====
: SPUSH    ( addr len -- top$ ) NEW: TOP$ DUP >R PLACE R> ;
: ?SSP     ( -- ) SSP @ 0= ABORT" Empty $ stack" ;
: DROP$    ( -- ) ?SSP MXLEN NEGATE SSP +! ;

: POS$  ( $1 $2 -- n )  \ return "position" $1 in $2
           DUP -ROT DUP -ROT    ( -- $2 $2 $1 $2)
           COUNT BOUNDS
           DO
             I OVER COUNT S=
             0= IF
                  NIP I SWAP
                  LEAVE
             THEN
           LOOP
           DROP - ABS ;
\
\ ---[ utility words ]---
\
: LEN      ( $ -- length)  C@ ;
: LASTCHAR ( $ -- c)  DUP LEN + C@ ;              \ get last char in a string
: BETWEEN  ( n min max -- ?)  1+ WITHIN ;         \ is n between or equal-to min/max
: FORALLCHARS ( $ -- end start) COUNT BOUNDS  ;   \ convert $ to 2 addresses for DO LOOP

: >=      ( n n -- ? ) 1- > ;
: <=      ( n n -- ? ) 1+ < ;
: $.      ( $ --) COUNT TYPE ;

\ text color definitions
HEX
: WHT/BLK ( -- ) F1 7 VWTR ;
: RED/BLK ( -- ) 91 7 VWTR ;
DECIMAL

\
\ ---[ case testers ]---
\
: LOWER?  ( char -- ?)  [CHAR] a [CHAR] z BETWEEN ;
: UPPER?  ( char -- ?)  [CHAR] A [CHAR] Z BETWEEN ;

\
\ ---[ case covertors ]---
\

HEX
: UPPER    ( c -- c ) DUP LOWER? IF  05F AND THEN ;
: LOWER    ( c -- c ) DUP UPPER? IF  020 OR  THEN ;

: TOUPPER ( addr len --  ) \  convert STACK$ to uppercase in place
          BOUNDS DO  I C@ UPPER I C!  LOOP ;

: TOLOWER ( addr len --  ) \  convert STACK$ to uppercase
          BOUNDS DO  I C@ LOWER I C!  LOOP ;

\ convert counted string copy
: UPPER$  ( $ -- $') COUNT SPUSH DUP COUNT TOUPPER ;
: LOWER$  ( $ -- $') COUNT SPUSH DUP COUNT TOLOWER ;

: LOWER.TYPE ( adr len -- )                     \ print string in lower case
           BOUNDS ?DO  I C@ LOWER EMIT  LOOP ;

\ ---[ string cleaner ]---

: MEMBER? ( addr len char -- ? ) SCAN NIP ; \ is char in string addr len

: APPEND-CHAR ( char $ -- )
              DUP >R        \ copy string address
              COUNT DUP 1+  \ addr,len, len+1
              R> C!         \ store new length
              + C! ;        \ put char at end of string

\ these stack strings are passed to STRIP$ (1st char is space)
: "NOISE" ( -- addr len) S"  ,.?!'@#$[]%^&*()_+-{}:<>" ;

\ Use: C" TEST 1 2 3" "BL" STRIP$
: STRIP$ ( $ addr len -- $)
            ROT
            NEW: TOP$ OFF
            FORALLCHARS
            DO
               2DUP I C@ MEMBER? 0=
               IF   I C@ TOP$ APPEND-CHAR
               THEN
            LOOP
            2DROP
            TOP$  ;
\
\ ---[ list words ]---
\
CREATE {NIL}   0 ,                      \ nil list

: {   ( -- ) ALIGN !CSP  ;    \ list starts with 0 in link-fld, record stack pos.
: }   ( -- ) ALIGN {NIL} @ , ?CSP ;     \ ends list, check stack


: "   ( -- )                 \ compile a linked-list string
      HERE 0 ,               \ make space for link
      [CHAR] " WORD DUP C@ 1+ ALLOT ALIGN
      HERE SWAP 2- ! DROP ;   \ fill in the link


\ : CAR  ( list -- next)  @ ;
\ : CDR  ( list -- addr) CELL+ ;

: {NEXT}   ( list -- list' )  @  ;  \ get next string in a list
: {$}     ( link -- $)  CELL+ ;

: {NTH}    ( list n -- $addr )  \ the nth string in a list
             0  ?DO  {NEXT}  LOOP ;

: {PRINT} ( link -- ) {$} COUNT CR TYPE ;

: {LEN}   ( list -- n )  \ count the no. of items in a list
          0 >R
          BEGIN
            {NEXT} DUP
            R> 1+ >R
          0= UNTIL
          DROP
          R> 1- ;

: {LIST} ( list -- )  \ for view
          CR
          0 >R
          BEGIN
             DUP @
          WHILE
            DUP {$} COUNT
            DUP 4 + C/L@ > IF  CR THEN TYPE ." , "
            {NEXT}
            R> 1+ >R
          REPEAT
          DROP
          R> CR . ." items" ;

\ USAGE:   KEYWORDS {WITH  TOUPPER  MAP}
: {WITH   STATE @
          IF   POSTPONE [']
          ELSE '
          THEN ;

\ xt must be a clean string function that leaves nothing on the stack
: MAP} ( list xt -- )  \ for view
          >R
          BEGIN
            DUP @
          WHILE
             DUP R@ EXECUTE
            {NEXT}
          REPEAT
          R> DROP
          DROP ;

VARIABLE MFLAG     \ simpler that stack juggling :-)
VARIABLE POSITION  \ ALSO record the position keyword in $
: {MEMBER}  ( $ {list} -- -1 | ndx )  \ is ANY member of {list} in $
          MFLAG ON                   \ -1 flag means not found
          SWAP COUNT NEW: TOP$ PLACE \ $ goes on string stack
          0 >R                       \ counter on rstack
          BEGIN
            DUP @
          WHILE
            DUP {$} TOP$ POS$ DUP POSITION !
            IF R@ MFLAG !
               DROP {NIL}      \ drop {list}, replace with {nil}
                               \ to end the loop
            ELSE
               {NEXT}
               R> 1+ >R        \ inc the counter
            THEN
          REPEAT
          DROP$                \ clean string stack
          DROP                 \ clean data stack
          R> DROP
          MFLAG @  ;           \ return the mflag value

\ ==============================================
\  --- REFLECTIONS ---
CREATE PHRASES
    { " I AM"      \ 0
      " I HAVE"    \ 1
      " I'VE"      \ 2
      " I'M"       \ 3
      " I WILL"    \ 4
      " I'D"       \ 5
      " I'LL"      \ 6
      " MINE"      \ 7
      " ARE"       \ 8
      " WERE"      \ 9
      " YOU"       \ 10
      " ME"        \ 11
      " YOUR"      \ 12
      " IS"        \ 13
      " MY"
      " I "
     }

\    S" I AM  I HAVE  I'VE  I'M  I WILL I'D I'LL "
\    S" MINE  ARE    WERE YOU ME YOUR IS MY  I "

CREATE CONJUGATIONS
    { " YOU ARE"    \ 0
      " YOU HAVE"     \ 1
      " YOU'VE"     \ 2
      " YOU'RE"     \ 4
      " YOU'LL"     \ 5
      " YOU WOULD"  \ 6
      " YOU WILL"   \ 7
      " YOURS"      \ 8
      " AM"         \ 9
      " WAS"        \ 9
      " ME"          \ 10
      " YOU"        \ 11
      " MY"         \ 12
      " BEING"      \ 13
      " YOUR"
      " YOU"
     }


CONJUGATIONS {LEN} CONSTANT #CONJUGATES

: ]PHRASE     ( n -- $) PHRASES SWAP {NTH} {$} ;
: ]CONJUGATE  ( n -- $) CONJUGATIONS SWAP {NTH} {$} ;


\ ---[ Traditional Eliza Banner Printer ]===
HEX
 : ]PDT ( char# -- 'pdt[n] )  8* 800 + ; \ character bit-map table

 VARIABLE LETTER
: BIG.TYPE ( addr len -- )
    8 0 DO  CR                       ( str len)
        2DUP BOUNDS ?DO
            I C@ DUP LETTER !
            ]PDT J +  VC@            \ PDT char, byte# J from VDP RAM
            2 7 DO                   \ from bit# 7 to 2
                DUP 1 I LSHIFT AND   \ mask out each bit
                IF    LETTER @ EMIT  \ if true emit a character
                ELSE  SPACE          \ else print space
                THEN
            -1 +LOOP
            DROP
        LOOP                         ( str len)
    LOOP
    2DROP ;


\ =========================[ ELIZA BEGINS ] ========================

\ ---[ KEYWORDS ]---
\
\ organize the keyword order to optimize responses

DECIMAL
CREATE KEYWORDS
    { " SHIT"      " SHUTUP"    
      " DICK"      " FUCK"      " ASS"  " BASTARD"
      " ROBOT"     " COMPUTER"
      " CONSOLE"   " SORRY"      " ALWAYS"
     
      " FRIEND"    " NIL "       " BYE"       " GOODBYE"
      " CAUSE"     " DREAM"      " HELLO"     " HELL" " ALIKE"
      " CAN YOU"   " CAN I"      " YOU ARE"   " NAME"

      " WHY DON'T YOU"   " WHY CAN'T I"

      " I DON'T"   " I FEEL"     " ARE YOU"   " I CAN'T"
      " I AM"      " I'M"
      " YOUR"      " I WANT"     " MY"        
      " HI "       " MAYBE"      " I NEED"
      " THINK"     " YOU "       " YES"
      " I HAVE"    " I'VE"       " REALLY"
      " WHAT"      " HOW"
      " WHO"       " WHERE"      " WHEN"      " WHY"
      " JE"        " ICH"
      " SPRECHEN"  " SPREKEN"    " HABLA"     " PARLEZ"
      " ITALIANO"  " ESPANOL "   " FRANCAIS"  
      " DEUTSCH"   " NEDERLANDS"  
      " NO"        " WE"         " OK"
}

\ count all the keywords at compile time
\ and assign the number to the constant #KEYS
\ KEYWORDS {LEN} CONSTANT #KEYS

: ]KEYWORD ( ndx -- $)
           DUP -1 =
           IF
             DROP {NIL}   ( return empty string)
           ELSE
              KEYWORDS SWAP {NTH} {$}
           THEN ;

\ convert keyword# into a FORTH word
\ output is a stack string for EVALUATE to use
: >ACTION  ( n -- addr len )
            DUP 0< ABORT" >ACTION ndx err"
            ]KEYWORD "NOISE" STRIP$ COUNT ;

\ ==============================================
\        --- REPLIES SUPPORT CODE ---

\ Replies create a FORTH word with a 2 CELL header structure
\ followed by a list of counted strings.

: LIST  HERE ;
: REPLY: ( LIST -- )   DUP {LEN} 1-  0 ROT CREATE ,  ,  ,   ;

\ given a reply address these words compute the offset of the fields


: ->USE#  ( replyaddr -- fld_addr) CELL+  ;
: ->CNT#  ( replyaddr -- fld_addr) 2 CELLS + ;
: ->LIST  ( replyaddr -- fld_addr) {NEXT} ;
: ->1ST$  ( replyaddr -- $ ) {NEXT} {$}  ; \ returns 1st string in list
: REPLY$  ( replyaddr -- $ ) DUP ->USE# @ SWAP ->LIST SWAP {NTH} {$} ;
: LASTREPLY?  ( replyaddr -- ) ->USE# 2@ = ;  \  compare CNT# & USE#.

: REPLY++  ( replyaddr -- ) \ circular increment USE#
           DUP LASTREPLY?
           IF   ->USE# OFF
           ELSE 1 SWAP ->USE# +!
           THEN ;

: {REPLY}  ( keyword# -- {list}) >ACTION EVALUATE ->LIST ;

VARIABLE ROGERIAN      \ set if Rogerian answer is needed

: PRINT.REPLY ( $ -- $ ) \ prints everthing up to the '~' char
              ROGERIAN OFF
              CR CR
              FORALLCHARS
              DO
                  I C@ DUP '~' =
                  IF  DROP
                      ROGERIAN ON
                      LEAVE
                  THEN EMIT
              LOOP SPACE  ;

\ dot reply prints the reply to "USE" and advances the '->USE#' or resets it to 1
: .REPLY  ( reply_addr -- )
           DUP REPLY$ PRINT.REPLY
           REPLY++ ;

\  =============================
\      === REPLY LISTS ===
\
LIST { " Don't you believe that i can~"
      " Perhaps you would like to be able to~"
      " You want me to be able to~"
     } REPLY: CANYOU

LIST { " Perhaps you don't want to~"
       " Do you want to be able to~"
     } REPLY: CANI

LIST { " What makes you think i am~"
       " Does it please you to believe that i am~"
       " Perhaps you would like to be~"
       " Do you sometimes wish you were~"
     } REPLY: YOUARE

\ anytime we need new keywords with the same replies
\ we just make a synonym Forth word.
     : YOURE  YOUARE ;

LIST { " I keep patient relationships professional."
       " There is no 'We' here. You are my patient."
       " No! We cannot~"
       " Hey! I am your doctor. Nothing more."
     } REPLY: WE


LIST { " You really don't~"
       " Why don't you~"
       " Me neither. Does that matter to you?."
     } REPLY: IDONT


LIST { " Does that trouble you?"
       " Tell me more about such feelings."
       " Do you often feel~"
       " Do you enjoy feeling~"
     } REPLY: IFEEL

LIST { " How long have you had~"
       " I think that's normal."
       " Many people have~"
     } REPLY: IHAVE

: I'VE   IHAVE ;

LIST { " Do you really believe i don't~"
       " Perhaps in good time i will~"
       " Do you want me to~"
       " Do you think you should be able to~"
     } REPLY: WHYDONTYOU

LIST { " I don't know, why can't you~"
       " Have you really tried to~"
       " You can. you just don't know it yet."
     } REPLY: WHYCANTI

LIST { " Why are you interested in whether or not i am~"
       " Would you prefer if i were not~"
       " Perhaps in your fantasies i am~"
     } REPLY: AREYOU

LIST { " How do you know you can't~"
       " Have you tried~"
       " Do you think everyone can~"
     } REPLY: ICANT

LIST { " Did you come to me because you are~"
       " How long have you been~"
       " Do you believe it is normal to be~"
       " Do you enjoy being~"
     } REPLY: IAM

: IM   IAM ;

LIST  { " Do you really need~"
        " In my experience everybody needs~"
        " What would it mean if you got~"
      } REPLY: INEED

LIST  { " We were discussing you -- not me."
        " Let's keep talking about your issues."
        " You're not really talking about me, are you?"
      } REPLY: YOU

LIST  { " What would it mean if you got~"
        " Why do you want~"
        " Suppose you soon got~"
        " What if you never got~"
        " Sometimes i think i want~"
        " Doesn't everybody?"
      } REPLY: IWANT

LIST { " Why do you ask?"
       " Does that question interest you?"
       " What answer would please you the most?"
       " What do you think?"
       " Are such questions on your mind often?"
       " What is it you really want to know?"
       " Have you asked anyone else this question?"
       " Have you asked such questions before?"
       " What else comes to mind when you ask that?"
     } REPLY: WHAT

\ all questions give the same answers
         : HOW    WHAT ;
         : WHO    WHAT ;
         : WHEN   WHAT ;
         : WHERE  WHAT ;
         : WHY    WHAT ;

LIST { " Names don't interest me."
       " I don't care about names. Go on."
     } REPLY: NAME

LIST { " Is that the real reason?"
       " Do any other reasons come to mind?"
       " Does that reason explain anything else?"
       " What other reason might there be?"
     } REPLY: CAUSE

LIST { " Please don't apologise."
       " Apologies are not necessary."
       " What feelings do you get when you apologise?"
       " Don't be so defensive!"
     } REPLY: SORRY

LIST { " What does that dream suggest to you?"
       " Do you dream often?"
       " What persons appear in your dreams?"
       " Are you disturbed by your dreams?"
     } REPLY: DREAM

LIST   { " How do you do ... Please state your problem."
         " Hello again :-)"
       } REPLY: HELLO
       : HI     HELLO ;
       : BONJOUR  HELLO ;

LIST  { " You don't seem quite certain."
         " Why the uncertain tone?"
         " Can't you be more positivE?"
         " You aren't sure?"
         " Don't you know?"
       } REPLY: MAYBE

LIST  { " Are you saying that just to be negative?"
         " You are being a bit negative."
         " Why not?"
         " Are you sure?"
         " Why not?"
       } REPLY: NO


LIST  { " Why are you concerned about my~"
         " What about your own~"
       } REPLY: YOUR


LIST  { " Can you think of a specific example?"
         " When?"
         " What are you thinking of?"
         " Really, always?"
         " Do you really think so?"
         " But are you sure you~"
         " Do you doubt you~"
       } REPLY: THINK


LIST   { " In what way?"
         " What resemblance do you see?"
         " What does the similarity suggest to you?"
         " What other connections do you see?"
         " Could there really be some connection?"
         " How?"
       } REPLY: ALIKE


LIST   { " You seem quite positive."
         " Are you sure?"
         " I see."
         " I understand."
       } REPLY: YES


LIST  { " Why do you bring up the topic of friends?"
         " Do your friends worry you?"
         " Do your friends pick on you?"
         " Are you sure you have any friends?"
         " Do you impose on your friends?"
         " Perhaps your love for friends worries you?"
         " Do computers worry you?"
         " Are you talking about me in particular?"
       } REPLY: FRIEND


LIST  { " Are you frightened by machines?"
         " Why do you mention computers?"
         " What do you think computers have to do with your problem?"
         " Don't you think computers can help people?"
         " What is it about machines that worries you?"
         " Say, do you have any psychological problems?"
       } REPLY: COMPUTER


LIST  { " Alright then. Tell me about your mother"
         " Is that all you have to say?"
         " You are just agreeing with me now"
       } REPLY: OK


LIST { " Are you over-generalizing?"
         " Don't you mean 'sometimes' ?"
         " Really? Always?"
       } REPLY: ALWAYS


LIST { " Hey now. we don't use that kind of language here."
         " I told you to watch your language!"
         " That's it. I don't have to listen to this!"
         "   "
       } REPLY: SHIT

\ all these words cause SHIT to happen :-)
    : FUCK     SHIT ;
    : ASS      SHIT ;
    : BASTARD  SHIT ;
    : HELL     SHIT ;
    : DICK     SHIT ;

LIST { " I only work in English."
       " Need I remind you to speak English"
       " Please use English"
     } REPLY: FRANCAIS

\ ALL these words respond the same
         : NEDERLANDS   FRANCAIS ;
         : DEUTSCH      FRANCAIS ;
         : ESPANOL      FRANCAIS ;
         : ITALIANO     FRANCAIS ;
         : JE           FRANCAIS ;
         : ICH          FRANCAIS ;
         : HABLA        FRANCAIS ;
         : PARLEZ       FRANCAIS ;
         : SPRECHEN     FRANCAIS ;
         : SPREKEN      FRANCAIS ;

LIST  { " I am not a ROBOT. I am a Phsychiatrist."
         " Do you have a ROBOT fetish?"
         " Does it matter if I am a ROBOT?"
       } REPLY: ROBOT


: ROBOTS  ROBOT ;

LIST { " Sounds serious. Tell me more."
         " I have no reason to be dishonest with you."
         " You don't trust me yet do you?"
       } REPLY: REALLY

LIST { " Tell me about your~"
         " How do you feel about your~"
         " Stop talking about your~"
       } REPLY: MY

LIST   { " What does that suggest to you?"
         " I see."
         " I'm not sure I understand you fully."
         " Topic shift: How is your love life?"
         " Can you expand on that a bit?"
         " That is quite interesting. Tell me more. "
         " Are you being honest?"
       } REPLY: TAPDANCE

: END_SESSION  TEXT  QUIT ;  \  can change this to BYE

: BYE    CR ." OK. Thanks for chatting."
         CR ." Bye bye!"  700 MS
         CR ." ...Oh and by the way..."
         1000 MS
         CR
         CR ." My bill is $400.00.
         CR ." (I accept Paypal) :-)"
         1500 MS
         END_SESSION ;

: GOODBYE   BYE ;

: SHUTUP    CR CR ." That's rude!"  1000 MS BYE ;

: CONSOLE   CR
            CR ." Exiting program..."
            CR ." CAMEL99 FORTH"
            CR  QUIT ;

\ ------------------[ replies end ]-----------------
\ /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\


: GREETING  ( -- )
            CR ." ==================================="
            CR
            CR ." Hi! My name is Eliza."
            CR ." Can I help you?" ;

: $ACCEPT ( $addr -- ) DUP  1+ 80 ACCEPT  SWAP C!  ;

: -TRAILING  ( adr len -- adr len') \ remove trailing blanks (spaces)
             BEGIN  2DUP + 1- C@  BL =
             WHILE  1-
             REPEAT ;

: TRIM     ( addr len -- addr' len')
            BL SKIP -TRAILING ;

: LISTEN   ( -- $ )
           BEGIN
             CR BEEP ." >"  INPUT$ DUP $ACCEPT
             LEN 0>
           UNTIL
           INPUT$  COUNT 2DUP TOUPPER TRIM
           INPUT$ PLACE 
           INPUT$ ;

\ cut INPUT$, return everything after the keyword phrase
 : /TAIL  ( keyword input$ -- adr len)   \ "cut tail"
           2DUP POS$ >R     \ -- key input
           SWAP LEN         \ -- input length
           R> +             \ -- input offset
           SWAP COUNT ROT /STRING ;


: 3RD  ( a b c -- a b c a ) 2 PICK ;

: SPLIT ( addr len char -- str1 len1 str2 len2)
         >R  2DUP  R> SCAN  2SWAP  3RD - ;

: /WORD ( addr len char --  1word len remainder len  )
        SPLIT 2SWAP 1 /STRING  ;

: EVEN#  ( n -- ?) DUP ALIGNED = ;

: CONJUGATE$ ( $ -- $ | $') \ check for PHRASES membership
         DUP CR ." Tail:" $. 
         DUP PHRASES {MEMBER}   DUP  CR ."  <" . SPACE POSITION @ .  ." > "
         DUP 0<                ( -- $ n)
         IF                    \ if not a member
             DROP              \ drop ndx, keep $
         ELSE
             NIP               \ remove $  ( -- n)
             ]CONJUGATE        \ replaced with conjugate
        THEN ;

: PRINT$     $.  COLLAPSE ;

: /CONJUGATE  ( addr len -- )
         TRIM
         BEGIN
           DUP 0> ( len>0 ?)
         WHILE 
            BL /WORD 2SWAP SPUSH            \ cut each word->string stack
            CONJUGATE$ LOWER$ PRINT$ SPACE  \ conjugate TOP$ & print lowcase
         REPEAT
\         ." ?"
         2DROP ;

DECIMAL

\ everthing is handled by {MEMBER} which scans $ for any MEMBER of the list
: ANALYZE   ( $ -- 0 | ndx) KEYWORDS {MEMBER} ;

: REPLY   ( n -- )  \ n= keyword index
           DUP -1 =
           IF  ( no matching keyword)
               DROP
               TAPDANCE .REPLY

           ELSE ( keywords found)
                DUP >ACTION EVALUATE .REPLY
                ROGERIAN @
                IF  ( n) ]KEYWORD INPUT$ /TAIL /CONJUGATE
                ELSE DROP
                THEN
           THEN ;

: ?BADWORDS  ( -- )
       SHIT ->USE# @ 3 =
       IF 2000 MS
          PAGE
          RED/BLK
          0 12 AT-XY ." DON'T LET THE DOOR HIT YOU"
          CR ." ON YOUR WAY OUT!"
          3000 MS
          END_SESSION
       THEN ;

DECIMAL
: ELIZA    ( -- )
        SHIT ->USE# OFF
        TEXT  WHT/BLK
        S" Eliza" BIG.TYPE CR
        GREETING
        BEGIN
          ?BADWORDS
           COLLAPSE  ( the string stack)
           LISTEN ( $)
           ANALYZE ( ndx)  \ DUP CR ." Key=" DUP . SPACE ]KEYWORD $.
           REPLY
       AGAIN ;


