\ ELIZA in CAMEL99 Forth

\ This implementation uses the Forth dictionary as a big case statement
\ Eliza's KEYWORD phrases are converted to Forth words by removing the spaces
\ and puncutation.

\ Example:
\ "I CAN'T" becomes ICANT.  ICANT is a FORTH word so all we need is a word 
\ in the dictionary called ICANT to make something happen.

\ INCLUDE DSK1.TOOLS.F   \ for debugging

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
: TOP$     ( -- $) SSP @ $STAK + ; \ string stack in dictionary

\ string stack helpers ====
: SPUSH    ( addr len -- top$ ) NEW: TOP$ DUP >R PLACE R> ;
: ?SSP     ( -- ) SSP @ 0= ABORT" Empty $ stack" ;
: DROP$    ( -- ) ?SSP MXLEN NEGATE SSP +! ;

: $=    ( $1 $2 -- ?) S= 0= ;

: POS$  ( $1 $2 -- n )  \ return "position" $1 in $2
           DUP -ROT DUP -ROT    ( -- $2 $2 $1 $2)
           COUNT BOUNDS
           DO
             I OVER COUNT $=
             IF
               NIP I SWAP
               LEAVE
             THEN
           LOOP
           DROP - ABS ;
           
\ special case that checks for trailing space after matched word
: MATCH$  ( $1 $2 -- n )  \ return "position" $1 in $2
           DUP -ROT DUP -ROT    ( -- $2 $2 $1 $2)
           COUNT BOUNDS
           DO
             I OVER COUNT        \ ( -- addr caddr len )
             DUP I + C@ BL = >R  \ check for space, rpush result
             $=  R> AND          \ if match AND a trailing space
             IF
                  NIP I SWAP
                  LEAVE
             THEN
           LOOP
           DROP - ABS ;
\
\ ---[ utility words ]---
\
: LEN      ( $ -- length)  C@ ;
: LASTCHAR ( $ -- c)  DUP LEN + C@ ;             \ get last char in a string
: BETWEEN  ( n min max -- ?)  1+ WITHIN ;        \ is n between or equal-to min/max
: FORALLCHARS ( $ -- end start) COUNT BOUNDS  ;  \ for DO LOOP on strings

: >=      ( n n -- ? ) 1- > ;
: <=      ( n n -- ? ) 1+ < ;
: $.      ( $ --) COUNT TYPE ;

\ text color definitions
HEX
: WHT/BLK ( -- ) F1 7 VWTR ;
DECIMAL

\ ---[ string support ]---
: MEMBER? ( addr len char -- ? )
          SCAN NIP ;        \  is char in stack string addr,len

: APPEND-CHAR ( char $ -- )
              DUP >R        \ copy string address
              COUNT DUP 1+  \ addr,len, len+1
              R> C!         \ store new length
              + C! ;        \ put char at end of string

\ --------[ STRIP$ ]--------
\ passed to STRIP$. 1st char is blank. Rest is punctutation
: "NOISE" ( -- addr len) S"  ,.?!'@#$[]%^&*()_+-{}:<>" ;

: STRIP$ ( $ addr len -- $)  \ Use: C" TEST 1 2 3" "BL" STRIP$
            ROT
            NEW: TOP$ OFF                \ set TOP$ to empty
            FORALLCHARS
            DO
               2DUP I C@ MEMBER? 0=
               IF   I C@ TOP$ APPEND-CHAR  \ build new string
               THEN
            LOOP
            2DROP
            TOP$  ;

\
\ ---[ case testers ]---
\
: LOWER?  ( char -- ?)  [CHAR] a [CHAR] z BETWEEN ;
: UPPER?  ( char -- ?)  [CHAR] A [CHAR] Z BETWEEN ;

\
\ ---[ Forth stack string words ]---
\
: -TRAILING  ( adr len -- adr len') \ remove trailing blanks (spaces)
             BEGIN  2DUP + 1- C@  BL =
             WHILE  1-
             REPEAT ;

: TRIM     ( addr len -- addr' len')
            BL SKIP -TRAILING ;

: +CHAR    ( addr len char -- addr len')
            >R             \ save the char
            2DUP +         \ calc end address+1
            R> SWAP C!     \ store character
            1+ ;           \ inc length
\
\ ---[ case covertors ]---
\
HEX
: UPPER    ( c -- c ) DUP LOWER? IF  05F AND THEN ;
: LOWER    ( c -- c ) DUP UPPER? IF  020 OR  THEN ;

: TOUPPER ( addr len -- addr len ) \  convert STACK$ to uppercase in place
          2DUP BOUNDS DO  I C@ UPPER I C!  LOOP ;

: TOLOWER ( addr len -- addr len ) \  convert STACK$ to uppercase
          2DUP BOUNDS DO  I C@ LOWER I C!  LOOP ;

: LOWER.TYPE ( adr len -- ) \ cleaning leading space, print in lower case
              BOUNDS ?DO  I C@ LOWER EMIT  LOOP ;

\ ---[ list words ]---
\
CREATE {NIL}   0 ,                      \ nil list

: {   ( -- ) ALIGN !CSP  ;              \  record stack pos.
: }   ( -- ) ALIGN {NIL} @ , ?CSP ;     \ ends list, check stack
: '{  ( -- addr) HERE { ;               \ start a new list, address on stack


: "   ( -- )                 \ compile a linked-list string
      HERE 0 ,               \ make space for link
      [CHAR] " WORD DUP C@ 1+ ALLOT ALIGN
      HERE SWAP 2- ! DROP ;  \ fill in the link

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

: {PRINT} ( list -- )  \ for viewing a list when debugging
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

VARIABLE MFLAG     \ simpler that stack juggling :-)
VARIABLE POSITION  \ ALSO record the position keyword in $

: {MEMBER}  ( $ {list} -- -1 | ndx )  \ is ANY member of {list} in $
          MFLAG ON                   \ -1 flag means not found
          SWAP COUNT NEW: TOP$ PLACE \ $ goes on string stack
          0 >R                       \ counter on rstack
          BEGIN
            DUP @                    \ CAR the list
          WHILE
            DUP {$} TOP$ MATCH$ DUP POSITION !
            IF R@ MFLAG !
               DROP {NIL}      \ drop {list}, replace with {nil}
            ELSE
               {NEXT}
               R> 1+ >R        \ inc the counter
            THEN                   \ to end the loop
          REPEAT
          DROP$                \ clean string stack
          DROP                 \ clean data stack
          R> DROP
          MFLAG @  ;           \ return the mflag value
          

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
      " ME"        \ 11
      " YOUR"      \ 12
      " IS"        \ 13
      " MY"
      " I"
      " YOU"
     }

CREATE CONJUGATIONS  \ trailing space needed for correct printing
    { " YOU ARE "    \ 0
      " YOU'VE "     \ 1
      " YOU'VE "     \ 2
      " YOU'RE "     \ 4
      " YOU'LL "     \ 5
      " YOU WOULD "  \ 6
      " YOU WILL "   \ 7
      " YOURS "      \ 8
      " AM "         \ 9
      " WAS "        \ 9
      " YOU "        \ 11
      " MY "         \ 12
      " BEING "      \ 13
      " YOUR "
      " YOU "
      " I "
     }

CONJUGATIONS {LEN} CONSTANT #CONJUGATES

: ]PHRASE     ( n -- $) PHRASES SWAP {NTH} {$} ;
: ]CONJUGATE  ( n -- $) CONJUGATIONS SWAP {NTH} {$} ;

\ ---[ KEYWORDS ]---
\
DECIMAL
CREATE KEYWORDS   \ original Eliza keywords
    {
      " COMPUTER"          " NAME"          " SORRY"        " I REMEMBER"
      " DO YOU REMEMBER"   " I DREAMT"      " DREAM ABOUT"  " DREAM"
      " MY MOTHER"         " MY FATHER"     " I WANT"       " I AM GLAD"
      " I AM SAD"          " ARE LIKE"      " IS LIKE"      " ALIKE"
      " I WAS"             " WAS I"         " I AM"         " AM I"
      " AM"                " ARE YOU"       " YOU ARE"      " BECAUSE"
      " WERE YOU"          " I FEEL"        " I FELT"       " WHY DON'T YOU"
      " YES"               " NO"            " SOMEONE"      " EVERYONE"
      " ALWAYS"            " WHAT"          " PERHAPS"      " ARE"
      " BYE"               " CONSOLE"
     }

: ]KEYWORD ( ndx -- $) \ keyword indexed array with protection
           DUP 0<
           IF
             DROP {NIL}   ( return empty string)
           ELSE
              KEYWORDS SWAP {NTH} {$}
           THEN ;

\ convert keyword# into a FORTH word by removing spaces and NOISE.
\ Output is a stack string for EVALUATE to use
: >ACTION  ( n -- addr len )
            DUP 0< ABORT" >ACTION ndx err"
            ]KEYWORD "NOISE" STRIP$ COUNT ;

\ ==============================================
\        --- REPLIES SUPPORT CODE ---

: REPLY: ( list -- )
         DUP {LEN}        \ count the strings in the list
          1-              \ 1 less is the last string in the list
          0               \ 0 is the first string to use
          ROT             \ put the list address on top
         CREATE           \ create a Forth name for the list
             ,            \ compile list addres
             ,            \ compile the string to use as reply
             ,   ;        \ compile the list length

\ given a reply address these words compute the offset of the fields
: ->USE#  ( replyaddr -- fld_addr) CELL+  ;
: ->CNT#  ( replyaddr -- fld_addr) 2 CELLS + ;
: ->LIST  ( replyaddr -- fld_addr) {NEXT} ;
: ->1ST$  ( replyaddr -- $ ) {NEXT} {$}  ;    \ returns 1st string in list
: REPLY$  ( replyaddr -- $ ) DUP ->USE# @ SWAP ->LIST SWAP {NTH} {$} ;
: LASTREPLY?  ( replyaddr -- ) ->USE# 2@ = ;  \  compare CNT# & USE#.

: REPLY++  ( replyaddr -- ) \ circular increment USE#
           DUP LASTREPLY?
           IF   ->USE# OFF
           ELSE 1 SWAP ->USE# +!
           THEN ;

: {REPLY}  ( keyword# -- {list}) >ACTION EVALUATE ->LIST ;

VARIABLE ROGERIAN        \ set if Rogerian answer is needed

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
              LOOP
              SPACE ;

\ dot reply prints the reply to "USE" and advances the '->USE#' or resets it to 1
: .REPLY  ( reply_addr -- )
           DUP REPLY$ PRINT.REPLY
           REPLY++ ;

\  =============================
\      === REPLY LISTS ===
\
'{ " Are you frightened by machines?"
   " Are you talking about me in particular?"
   " What do you think computers have to do with your problem?"
   " Don't you think computers can help people?"
   " What is it about machines that worries you?"
 } REPLY: COMPUTER

'{ " Names don't interest me."
   " I don't care about names. Go on."
 } REPLY: NAME

'{ " Please don't apologize."
   " Apologies are not necessary."
   " What feelings do you get when you apologize?"
 } REPLY: SORRY

'{ " Do you often think of~"
   " Does thinking of this bring anything else to mind~"
   " What else do you remember?"
   " Why do you recall this right now?"
   " What in the present situation reminds you of~"
   " What is the connection between me and~"
 } REPLY: IREMEMBER

'{  " Did you think I would forget~"
    " Why do you think I should recall~"   \ now
    " What about~"
    " You mentioned!"        \ this should bring back word from Remember
    " Do you really think its likely that~"
    " Do you wish that~"
    " What do you think about~"
    " Really-- if!"
 } REPLY: DOYOUREMEMBER

'{ " Really--~"
   " Have you ever fantasized about this while you were awake?"
   " Have you dreamt about this before?"
 } REPLY: IDREAMT

'{ " In reality, how do you feel about~"
 } REPLY: DREAMABOUT

'{ " What does this dream suggest to you?"
   " Do you dream often?"
   " What persons appear in your dreams?"
   " Don't you believe that dream has to do with your problem?"
 } REPLY: DREAM

'{ " Who else in your family~"
   " Tell me more about your family"
 } REPLY: MYMOTHER

'{ " Your father~"
   " Does he influence you strongly?"
   " What else comes to mind when you think of your father?"
 } REPLY: MYFATHER


'{ " What would it mean if you got~"
   " Why do you want~"
   " Suppose you soon got~"
   " What if you never got~"
 } REPLY: IWANT

'{ " How have I helped you to be~"
   " What makes you happy just now?"
   " Can you explain why you are suddenly~"
 } REPLY: IAMGLAD

'{ " I am sorry to hear you are depressed"
   " I'm sure its not pleasant to be saD"
 } REPLY: IAMSAD
     
\ (((?* ?x) are like (?* ?y))   NEED TO ADD THIS CAPABILITY

'{ " What resemblance do you see between them?" } REPLY: ARELIKE

\ (((?* ?x) is like (?* ?y))   NEED TO ADD THIS CAPABILITY

'{ " In what way is it that the two are alike?"
   " What resemblance do you see?"
   " Could there really be some connection?"
   " How?"
 } REPLY: ISLIKE

'{ " In what way?"
   " What simililarities do you see?"
   " How?"
 } REPLY: ALIKE
       
'{ " Were you really?"
   " Perhaps I already knew you were~"
   " Why are you telling you were~"
 } REPLY: IWAS

'{ " What if you were~"
   " Do you think you were~"
   " What would it mean if you were~"
 } REPLY: WASI

'{ " In what way are you~"
   " Do you want to be~"
 } REPLY: IAM

'{ " Do you believe you are~"
   " Would you want to be~"
   " You wish I would tell you you are~"
   " What would it mean if you were~"
 } REPLY: AMI

'{ " Why do you say 'AM?'"
   " I don't understand that."
 } REPLY: AM

'{ " Why are you interested in whether or not i am~"
   " Would you prefer if i were not~"
   " Perhaps in your fantasies i am~"
 } REPLY: AREYOU

'{ " What makes you think i am~" } REPLY: YOUARE

'{ " Is that the real reason?"
   " Do any other reasons come to mind?"
   " Does that reason explain anything else?"
 } REPLY: BECAUSE

'{ " Perhaps I was~"
   " What do you think?"
   " What if I had been~"
 } REPLY: WEREYOU

'{ " Maybe NOW you could~"
   " What if you could~"
 } REPLY: ICANT

'{ " How often do you feel~"
   " Do you enjoy feeling~"
 } REPLY: IFEEL

'{ " What other feelings do you have?" } REPLY: IFELT

\    (((?* ?x) I (?* ?y) you (?* ?z))    COOL ONE! Need to do this
\    (Perhaps in your fantasy we ?y each other))

'{ " Why don't you~" } REPLY: WHYDONTYOU

'{ " You seem quite positive."
   " Are you sure?"
   " I understand."
 } REPLY: YES

'{ " Are you saying 'NO' just to be negative?"
   " You are being a bit negative."
   " Why not?"
 } REPLY: NO

'{ " Can you be more specific?" } REPLY: SOMEONE

'{ " Surely not everyone"
   " Can you think of anyone in particular?"
   " Who for example?"
   " Are youe thinking of a special person"
 } REPLY: EVERYONE

'{ " Can you think of a specific example"
   " When?"
   " What incident are you thinking of?"
   " Really-- always?"
 } REPLY: ALWAYS

'{ " Why do you ask?"
   " Does that question interest you?"
   " What is it you really want to know?"
   " What do you think?"
   " What else comes to mind when you ask that?"
 } REPLY: WHAT

'{ " You do not seem quite certain" } REPLY: PERHAPS

'{ " Did you think they might not be~"
   " Possibly they are~"
 } REPLY: ARE

: END_SESSION  TEXT  QUIT ;  \  can change this to BYE

: BYE    CR ." OK. Thanks for chatting."
         CR ." Bye bye!"  700 MS
         1500 MS
         END_SESSION ;

'{ " What does that suggest to you?"
   " I see."
   " I'm not sure I understand you fully."
   " Can we get back to the topic of your mental health?"
   " Can you expand on that a bit?"
   " That is quite interesting. Tell me more. "
   " Are you being honest?"
 } REPLY: TAPDANCE

: CONSOLE   CR
            CR ." Exiting program..."
            CR ." CAMEL99 FORTH"
            CR  QUIT ;

\ ===========[ END OF REPLYS ] ============


\ ------------------[ replies end ]-----------------
\ /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\


: GREETING  ( -- )
            CR ." ==================================="
            CR
            CR ." Hi! My name is Eliza."
            CR ." Can I help you?" ;


: $ACCEPT ( $addr -- ) DUP  1+ 80 ACCEPT  SWAP C!  ;

: READLINE ( $ -- addr len  )   \ **returns a stack string **
           CR BEEP ." >" $ACCEPT ;

: LISTEN   ( -- $ )
           BEGIN
             PAD DUP READLINE
             LEN 0>
           UNTIL
           PAD COUNT  TRIM TOUPPER  BL +CHAR INPUT$ PLACE
           INPUT$ ;

\ "cut tail" of INPUT$
\ return everything after the keyword phrase as stack string
 : /TAIL  ( keyword input$ -- adr len)   \ "cut tail"
           2DUP POS$ >R     \ -- key input
           SWAP LEN         \ -- input length
           R> +             \ -- input offset
           SWAP COUNT ROT /STRING ;

: 3RD  ( a b c -- a b c a ) 2 PICK ;

: SPLIT ( addr len char -- str1 len1 str2 len2)
         >R  2DUP  R> SCAN  2SWAP  3RD - ;

: /WORD ( addr len char --  1word len remainder len)
        SPLIT 1+            ( add one to include the trailing space)
        2SWAP 1 /STRING  ;

: CONJUGATE$ ( $ -- $ | $') \ check for PHRASES membership
         DUP PHRASES {MEMBER} 
         DUP 0<                \ ( -- $ ndx ?)
         IF                    \ not a member
             DROP              \ drop ndx, keep original $
         ELSE
             NIP               \ remove original $, keep ndx
             ]CONJUGATE        \ replaced with conjugate
        THEN ;

: /CONJUGATE  ( addr len -- )
         TRIM
         BEGIN
           DUP 0> ( len>0 ?)
         WHILE
            BL /WORD 2SWAP SPUSH            \ cut each word->string stack
            CONJUGATE$ COUNT LOWER.TYPE
            COLLAPSE  ( string stack)
         REPEAT
         2DROP ;

DECIMAL
\ keywords are found by {MEMBER} which scans $ for any MEMBER of the list
: ANALYZE   ( $ -- 0 | ndx)
            KEYWORDS {MEMBER} ;

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
           THEN  ;

DECIMAL
: ELIZA    ( -- )
        TEXT WHT/BLK
        COLLAPSE  ( reset string stack)
        S" Eliza" BIG.TYPE CR
        GREETING
        BEGIN
          LISTEN  ANALYZE  REPLY
        AGAIN ;


