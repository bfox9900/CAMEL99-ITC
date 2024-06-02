\ ELIZA in CAMEL99 Forth  simplified  May 24 2024

\ **********************************************************************
\ V2.0  replaces "list" data structures with simpler counted strings.
\ **********************************************************************

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

NEEDS DUMP      FROM DSK1.TOOLS
NEEDS -TRAILING FROM DSK1.TRAILING
NEEDS S=        FROM DSK1.COMPARE
NEEDS SEARCH    FROM DSK1.SEARCH 
NEEDS MARKER    FROM DSK1.MARKER

MARKER PREAMBLE

\ ======[ punctuation characters ]======
DECIMAL
CHAR ~ CONSTANT '~'   \ strings that end with '~' reflect the users input
CHAR , CONSTANT ','
CHAR . CONSTANT '.'

\ working memory for string processing
CREATE INPUT$  81 ALLOT  \ holds the "clean" reply from the patient

CREATE TEMP$   81 ALLOT 

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
: LASTCHAR ( $ -- c)  COUNT + 1- C@ ;            \ get last char in a string
: BETWEEN  ( n min max -- ?)  1+ WITHIN ;        \ is n between or equal-to mix
: FORALLCHARS ( $ -- end start) COUNT BOUNDS ;   \ convert $ to 2 addresses foP
: +PLACE      ( addr n $ -- ) 2DUP 2>R  COUNT +  SWAP MOVE 2R> C+! ;

: >=      ( n n -- ? ) 1- > ;
: <=      ( n n -- ? ) 1+ < ;
: $.      ( $ --) COUNT TYPE ;

\ text color definitions
: SCREEN  ( fg bg ) SWAP 4 LSHIFT SWAP +  7 VWTR ;

 1 CONSTANT BLK 
15 CONSTANT WHT 
 9 CONSTANT RED 

: WHT/BLK ( -- ) WHT BLK SCREEN ;
: RED/BLK ( -- ) RED BLK SCREEN ;

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

: LOWER.TYPE ( adr len -- )                     \ print string in lower case
           BOUNDS ?DO  I C@ LOWER EMIT  LOOP ;
.( .)
\ ---[ string cleaner ]---
: MEMBER? ( addr len char -- ? ) SCAN NIP ; \ is char in string addr len
: APPEND-CHAR ( char $ -- ) TUCK COUNT + C!  1 SWAP C+! ;
 
\ these stack strings are passed to STRIP$ (1st char is space)
: "NOISE" ( -- addr len) S"  ,.?!'@#$[]%^&*()_+-{}:<>" ;

: STRIP  ( source len noise len -- PAD len)
        PAD OFF 
        2SWAP BOUNDS 
        DO   
           2DUP I C@ MEMBER? 0=  
           IF I C@ PAD  APPEND-CHAR THEN
        LOOP 
        2DROP 
        PAD COUNT ; 

\ S"  This $is %a @ noisy %&*#$@ string!#@$!"  "NOISE"  STRIP CR TYPE 

\
\ =========================
\ string arrays indexed by byte count, with index protection 

\ started a counted string array  
: ${   ( -- addr ) HERE  0 , !CSP ;  

\ end a counted string array 
: }$   ( addr -- addr ) 0 ,  ?CSP ; 

\ compile a string and count it in 'addr' 
: $, ( addr -- addr)  S, ALIGN DUP 1+! ; 
: $"   [CHAR] " PARSE  $, ; 

: NEXT$     COUNT + ALIGNED ; 
: NTH$   ( addr n)  0 ?DO  NEXT$  LOOP ; 

: $ARRAY:  ( addr -- )
   CREATE     ,   
   DOES> ( ndx -- addr len) 
        @ DUP>R                               \ save copy of base address 
        @                                     \ get the string count   
        OVER U< ABORT" $array index out of range" 
        R> CELL+                              \ base address + cell = 1st string 
        SWAP NTH$ COUNT 
;          
    
: $ARRAYSIZE  ' >BODY @  @ ;

\ =========================[ ELIZA BEGINS ] ========================
\  --- REFLECTIONS ---
   ${ $" I AM"   
      $" I HAVE"   
      $" I'VE"    
      $" I'M"     
      $" I WILL"  
      $" I'D"     
      $" I'LL"    
      $" MINE"    
      $" ARE"     
      $" WERE"    
      $" YOU"     
      $" ME"      
      $" YOUR"    
      $" IS"      
      $" MY"      
      $" I"      
   }$ DUP CONSTANT []PHRASES  \ base address
      $ARRAY: ]PHRASE         \ array word 

 ${ $" YOU ARE"    
    $" YOU HAVE"    
    $" YOU'VE"      
    $" YOU'RE"      
    $" YOU'LL"     
    $" YOU WOULD"  
    $" YOU WILL"   
    $" YOURS"      
    $" AM"          
    $" WAS"        
    $" ME"          
    $" YOU"        
    $" MY"         
    $" YOUR"        
    $" YOU"         
 }$ DUP CONSTANT []COJUGATES 
        $ARRAY: ]CONJUGATE   

\ ---[ KEYWORDS ]---
\ organize the keyword order to optimize responses
.( .)
DECIMAL
   ${ $" SHIT"      $" SHUTUP"
      $" DICK"      $" FUCK"      $" ASS"  $" BASTARD"
      $" ROBOT"     $" COMPUTER"
      $" CONSOLE"   $" SORRY"      $" ALWAYS"

      $" FRIEND"    $" NIL $"       $" BYE"       $" GOODBYE"
      $" CAUSE"     $" DREAM"      $" HELLO"     $" HELL" $" ALIKE"
      $" CAN YOU"   $" CAN I"      $" YOU ARE"   $" NAME"

      $" WHY DON'T YOU"   $" WHY CAN'T I"

      $" I DON'T"   $" I FEEL"     $" ARE YOU"   $" I CAN'T"
      $" I AM"      $" I'M"
      $" YOUR"      $" I WANT"     $" MY"
      $" HI $"      $" MAYBE"      $" I NEED"
      $" THINK"     $" YOU $"      $" YES"
      $" I HAVE"    $" I'VE"       $" REALLY"
      $" WHAT"      $" HOW"
      $" WHO"       $" WHERE"      $" WHEN"      $" WHY"
      $" JE"        $" ICH"
      $" SPRECHEN"  $" SPREKEN"    $" HABLA"     $" PARLEZ"
      $" ITALIANO"  $" ESPANOL $"  $" FRANCAIS"
      $" DEUTSCH"   $" NEDERLANDS"
      $" NO"        $" WE"         $" OK"

}$ DUP CONSTANT []KEYWORDS \ define the base address name 
       $ARRAY: ]KEYWORD    \ define indexable name 


: SEARCH[] ( search$ len array_base_address -- n)
      NEXT$  >R  
      BEGIN
        R@ C@
      WHILE   
        
      






;             
   



\ convert keyword# n, into a FORTH word by STRIPPING noise characters and spaces
\ Example: I CAN'T -> ICANT
\ output is a stack string for EVALUATE to use
: >ACTION  ( n -- addr len )
            DUP 0< ABORT" >ACTION ndx err"
            ]KEYWORD "NOISE" STRIP$ COUNT ;

\ ==============================================
\        --- REPLIES SUPPORT CODE ---

\ Replies create a FORTH word with a 3 CELL header structure
\ followed by a list of counted strings.

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

\ dot reply prints the reply to "USE" and advances the '->USE#' field
\ or resets it to 1
: .REPLY  ( reply_addr -- )
           DUP REPLY$ PRINT.REPLY
           REPLY++ ;

\ ==================================================
\ **************************************************
\ Eliza replies are separate file for easier editing

 S" DSK2.ELIZADATA" INCLUDED

\ **************************************************
\ ==================================================

.( .)
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

: TRIM     ( addr len -- addr' len')  BL SKIP -TRAILING ;

: LISTEN   ( -- $ )
           BEGIN
             CR BEEP ." >"  INPUT$ DUP $ACCEPT
             LEN 0>
           UNTIL
           INPUT$ COUNT 2DUP TOUPPER TRIM
           INPUT$ PLACE
           INPUT$ ;

\ cut INPUT$, return everything after the keyword phrase
 : /TAIL  ( keyword input$ -- adr len)   \ "cut tail"
           2DUP POS$ >R     \ -- key input
           SWAP LEN         \ -- input length
           R> +             \ -- input offset
           SWAP COUNT ROT /STRING ;

: 3RD   ( a b c -- a b c a ) 2 PICK ;

: SPLIT ( addr len char -- str1 len1 str2 len2)
         >R  2DUP  R> SCAN  2SWAP  3RD - ;

: /WORD ( addr len char --  1word len remainder len  )
        SPLIT 2SWAP 1 /STRING  ;

: EVEN#  ( n -- ?) DUP ALIGNED = ;

: CONJUGATE$ ( $ -- $ | $') \ check for PHRASES membership
\        DUP CR ." Tail:" $.
         DUP PHRASES {MEMBER} \ DUP  CR ."  <" . SPACE POSITION @ .  ." > "
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
            BL /WORD 2SWAP SPUSH            \ cut each word->string-stack
            CONJUGATE$ LOWER$ PRINT$ SPACE  \ conjugate TOP$ & print lowcase
         REPEAT
\         ." ?"
         2DROP ;

DECIMAL

\ everthing is handled by {MEMBER} which scans $ for any MEMBER of the list
: ANALYZE   ( $ -- 0 | ndx) KEYWORDS {MEMBER} ;

\ =======================================================
\ A minimal set of key words are needed to compile the program

\ Replies for unknown token
     '{ $" What does that suggest to you?"
        $" I see."
        $" I'm not sure I understand you fully."
        $" Topic shift: How is your love life?"
        $" Can you expand on that a bit?"
        $" That is quite interesting. Tell me more. "
        $" Are you being honest?"
      } REPLY: TAPDANCE

\ bad words list
     '{ $" Hey now. we don't use that kind of language here."
        $" I told you to watch your language!"
        $" That's it. I don't have to listen to this!"
        $"   "
      } REPLY: SHIT

\ all these words cause SHIT to happen :-)
 : FUCK     SHIT ;
 : ASS      SHIT ;
 : BASTARD  SHIT ;
 : HELL     SHIT ;
 : DICK     SHIT ;

: END_SESSION  TEXT  QUIT ;  \  can change this to BYE

: BYE   CR ." OK. Thanks for chatting."
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

\ =========================================================

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

.( .)

INCLUDE DSK1.BIGTYPE 

DECIMAL
: ELIZA    ( -- )
        SHIT ->USE# OFF
        SSW 10 * MALLOC ['] $STAK >BODY !
        TEXT  WHT/BLK
\ ---[ Traditional Eliza Banner Printer ]===
        S" Eliza" BIG.TYPE CR
        ." Hang on a minute,"
        ." I am reviewing your files"
         400 MS
      \  S" DSK2.ELIZADATA" INCLUDED
        GREETING
        BEGIN
          ?BADWORDS
           COLLAPSE  ( the string stack)
           LISTEN ( $) ANALYZE ( ndx) REPLY
       AGAIN ;
