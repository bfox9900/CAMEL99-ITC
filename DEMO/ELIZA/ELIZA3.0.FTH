\ ELIZA in CAMEL99 Forth  simplified  May 24 2024

\ 3.0 changes reply data to reply code. 


\ **********************************************************************
\ V2.0  replaces "list" data structures with simpler counted strings.
\       uses more stack strings for faster processing
\ **********************************************************************

\ This implementation uses the Forth dictionary as a big case statement
\ Eliza's KEYWORD phrases are converted to Forth words by removing the spaces.

\ Example:
\ "I CAN'T" becomes ICANT.  ICANT is a valid FORTH word so all
\ we need is a word in the dictionary called ICANT to make something
\ happen.

\ This allows synonyms to be created using a colon definition and adding
\ the new keyword to the KEYWORDS list.
\ Example:  : ICANNOT  ICANT ;
\ The definition for ICANNOT will do the same thing as ICANT

NEEDS DUMP      FROM DSK1.TOOLS
NEEDS -TRAILING FROM DSK1.TRAILING
NEEDS S=        FROM DSK1.COMPARE
NEEDS SEARCH    FROM DSK1.SEARCH 
NEEDS MARKER    FROM DSK1.MARKER

NEEDS BIG.TYPE  FROM DSK2.BIG.TYPE

MARKER /ELIZA  \ remove everthing but the library files 

\ ==============================================
\ WIL BADEN'S MACRO maker R.I.P. 
: SLITERAL ( ca u --) POSTPONE (S")  S,  ; IMMEDIATE
: MACRO  
  :   CHAR PARSE  POSTPONE SLITERAL  POSTPONE EVALUATE POSTPONE ;  IMMEDIATE 
;

\ ======[ punctuation characters ]======
DECIMAL
CHAR ~ CONSTANT '~'   \ strings that end with '~' reflect the users input
CHAR , CONSTANT ','
CHAR . CONSTANT '.'

\ working memory for string processing
CREATE INPUT$  81 ALLOT  \ holds the "clean" reply from the patient

CREATE TEMP$   81 ALLOT 

\
\ utility words ............
\
: LEN      ( $ -- length)  C@ ;
: LASTCHAR ( $ -- c)  COUNT + 1- C@ ;            \ get last char in a string
: BETWEEN  ( n min max -- ?)  1+ WITHIN ;        \ is n between or equal-to 
: FORALLCHARS ( $ -- end start) COUNT BOUNDS ;   \ convert $ to 2 addresses foP
: +PLACE      ( addr n $ -- ) 2DUP 2>R  COUNT +  SWAP MOVE 2R> C+! ;

: >=      ( n n -- ? ) 1- > ;
: <=      ( n n -- ? ) 1+ < ;
: PRINT$     COUNT TYPE ;

\ text color definitions
: SCREEN  ( fg bg ) SWAP 4 LSHIFT SWAP +  7 VWTR ;

 1 CONSTANT BLK 
15 CONSTANT WHT 
 9 CONSTANT RED


DECIMAL
\
\ string splitter at character position 
\ 
: 3RD   ( a b c -- a b c a ) 2 PICK ;
: SPLIT ( addr len char -- str1 len1 str2 len2)
        >R  2DUP  R> SCAN  2SWAP  3RD - ;

\
\ case testers .....
\
: LOWER?  ( char -- ?)  [CHAR] a [CHAR] z BETWEEN ;
: UPPER?  ( char -- ?)  [CHAR] A [CHAR] Z BETWEEN ;

\
\  case covertors .....
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
\
\ string cleaners .......
\ 
\ remove leading and trailing spaces 
: TRIM     ( addr len -- addr' len') BL SKIP -TRAILING ;

: MEMBER? ( addr len char -- ? ) SCAN NIP ; \ is char in string addr len
: APPEND-CHAR ( char $ -- ) TUCK COUNT + C!  1 SWAP C+! ;
 
\ these stack strings are passed to STRIP$ (1st char is space)
: NOISE$ ( -- addr len) S"  ,.?!'@#$[]%^&*()_+-{}:<>" ;

CREATE TEMP$  ( -- adr) 80 ALLOT  

: STRIP  ( source len noise len -- Temp$ len)
      TEMP$ OFF 
      2SWAP BOUNDS \ loop over the source string 
      DO   
         2DUP I C@ MEMBER? 0=  
         IF I C@ TEMP$  APPEND-CHAR THEN
      LOOP 
      2DROP
      TEMP$ COUNT ;

\ S"  This $is %a @ noisy %&*#$@ string!#@$!"  NOISE$  STRIP CR TYPE 

\
\ forth word array. Code becomes data 
\
VARIABLE STK  \ can't use CSP because it is used by the colon compiler 

: {  ( -- )   SP@ STK ! ;
: }  ( -- n)  STK @ SP@ - 2/ 1- ;

: TOKENS:  ( xt1 ... xtn  n -- )
   CREATE    
      DUP ,            \ compile the number of items into this word
\ *Lee Stewart improvement puts items in order as written          
      CELLS DUP ALLOT   \ reserve space for all XTs
\ Compile all the XTs on the data stack from end to beginning
      CELL+ 2 DO     
         HERE I - !     \ store next one back
      2 +LOOP  

   DOES> ( ndx -- [output depends on the code] )  
        DUP CELL+ >R    \ save copy of xt addresses
        @               \ get the # of strings 
        OVER U< ABORT" TOKEN: index out of range" 
        CELLS R> +      \ index into the array of XTs
        PERFORM         \ fetch the XT and EXECUTE it 
;          

\ : TOKENS:  ( xt1 ... xtn  n -- )
\   CREATE    
\        DUP ,            \ compile the number of items into this word 
\        0 ?DO  ,  LOOP   \ compile all the XTs on the data stack 

\   DOES> ( ndx -- [output depends on the code] )  
\        DUP CELL+ >R    \ save copy of xt addresses
\        @               \ get the # of strings 
\        OVER U< ABORT" TOKEN: index out of range" 
\        CELLS R> +      \ index into the array of XTs
\        PERFORM         \ fetch the XT and EXECUTE it 
\ ;          

: :: :NONAME ( -- XT ) ; \ renamed for brevity

\ =========================[ ELIZA BEGINS ] ========================
\  --- REFLECTIONS ---
\ Since these are colon definitions, they will return the address 
\ and length of the string when TOKEN does the PERFORM function 

\ EXAMPLE:  7 ]PHRASE  will conjugate with 7 ]CONJUGATE 
   {  :: S" I AM" ;   
      :: S" I HAVE" ; 
      :: S" I'VE" ;   
      :: S" I'M" ;    
      :: S" I WILL" ; 
      :: S" I'D" ;    
      :: S" I'LL" ;   
      :: S" MINE" ;   
      :: S" ARE" ;    
      :: S" WERE" ;   
      :: S" YOU" ;    
      :: S" ME" ;     
      :: S" YOUR" ;   
      :: S" IS" ;     
      :: S" MY" ;     
      :: S" I" ;     
   }  TOKENS: ]PHRASE  

: .PHRASES  
  CR 
 ['] ]PHRASE >BODY @   0
   DO  I ]PHRASE TYPE ." , "  LOOP 
;

: FIND-PHRASE ( addr len -- n | -1)
   -1  -ROT        \ not found flag under string 
   ['] ]PHRASE >BODY @   0
   DO 
      2DUP I ]PHRASE COMPARE 0=
      IF ROT DROP  \ remove not found flag 
         I -ROT    \ replace with index and put under string
         LEAVE 
      THEN 
   LOOP
   2DROP


 {  :: S" YOU ARE"  ;  
    :: S" YOU HAVE" ;   
    :: S" YOU'VE" ;     
    :: S" YOU'RE" ;     
    :: S" YOU'LL" ;    
    :: S" YOU WOULD" ; 
    :: S" YOU WILL" ;  
    :: S" YOURS" ;     
    :: S" AM" ;         
    :: S" WAS" ;       
    :: S" ME" ;         
    :: S" YOU" ;       
    :: S" MY" ;        
    :: S" YOUR" ;       
    :: S" YOU" ;        
 }   TOKENS: ]CONJUGATE   

: CONJUGATE  ( addr len -- addr' len) 
   FIND-PHRASE DUP 0< ABORT" Can't conjugate" 
   ]CONJUGATE 
;


\  KEYWORDS .....
\ keywords are stored in a compact array of counted strings 
.( .)
: [[  ( -- addr) HERE 0 , ;

\ compiles 0 to end data
: ]]  ( -- size) HERE OVER - 2- OVER !   0 , ; 

\ compile a string literal into dictionary memory 
: $"   POSTPONE S"   S,  ;

: NEXT$   COUNT + ALIGNED ;  
: NTH  ( $array n -- $addr) 0 ?DO NEXT$ LOOP ;

DECIMAL
   [[ $" SHIT"       $" SHUTUP" 
      $" DICK"       $" FUCK"     
      $" ASS"        
      $" BASTARD" 

      $" ROBOT"      $" COMPUTER" 
      $" CONSOLE"    $" SORRY"   
      $" ALWAYS"     
      $" FRIEND"     
      $" NIL"        $" BYE"        
      $" GOODBYE"    $" CAUSE"      
      $" DREAM"      $" HELLO"      
      $" HELL"       $" ALIKE"      
      $" CAN YOU"    $" CAN I"      
      $" YOU ARE"    $" NAME"       
      $" WHY DON'T YOU"    
      $" WHY CAN'T I" 
      $" I DON'T"    $" I FEEL"     
      $" ARE YOU"    $" I CAN'T" 
      $" I AM"       $" I'M"
      $" YOUR"       $" I WANT"      
      $" MY"         $" HI"       
      $" MAYBE"      $" I NEED"     
      $" THINK"      $" YOU"         
      $" YES"   
      $" I HAVE"     $" I'VE"        
      $" REALLY"
      $" WHAT"       $" HOW"
      $" WHO"        $" WHERE"       
      $" WHEN"       $" WHY"
      $" NO"         $" WE"          
      $" OK"

\ foreign language cue words       
      $" JE"         $" ICH"
      $" SPRECHEN"   $" SPREKEN"   $" HABLA"      $" PARLEZ"
      $" ITALIANO"   $" ESPANOL"   $" FRANCAIS"
      $" DEUTSCH"    $" NEDERLAND" 
   ]] CELL+ CONSTANT []KEYWORDS  \ size is stored 1 cell before keywords

: HOWMANY ( addr -- n) \ count no. strings in a compact array 
      0 
      BEGIN 
        OVER C@
      WHILE 
        SWAP NEXT$ SWAP 
        1+ 
      REPEAT 
      NIP   
;

[]KEYWORDS HOWMANY CONSTANT #KEYWORDS 

\ index into keywords list and return a stack string
\ if length = 0 n goes to end of the array
: ]KEYWORD ( n -- addr len) []KEYWORDS SWAP NTH COUNT ;

\ debugging ..............
: PRINT$  COUNT TYPE ;
: .KEYWORDS  ( -- )
   []KEYWORDS 
   BEGIN  
      DUP C@ 
   WHILE 
      DUP PRINT$ SPACE
      NEXT$ 
   REPEAT 
   DROP ;        

\ worst case search= 1 seconds 
: A$ S"  MPs 'wittingly' helped Liberals with NEDERLAND"  ; 
\ ........................


\ after a search, compute the position of string1 in string2 
: WHERE  ( a1 n1 a2 n2 -- n) NIP OVER SWAP - 1+ ;

\ find first keyword in input string arg and store index 
\ and position in variables for use later 
VARIABLE KWORD# 
VARIABLE POSITION 

: FIND-KEYWORD ( addr len -- ?)
   KWORD# ON   POSITION OFF 
   2DUP TOUPPER
   #KEYWORDS 0
   DO 
      2DUP I ]KEYWORD SEARCH  ( --- a n a n ?) 
      IF WHERE POSITION !  \ compute string position & store  
         I KWORD# ! 
         LEAVE 
      THEN 
      2DROP 
   LOOP 
   KWORD# @ 
;

: <KEYWORD>   KWORD# @ ]KEYWORD TYPE ;

\ FLATTEN converts a string into a FORTH word by STRIPPING noise 
\ characters and spaces
\ Example: I CAN'T -> ICANT
\ output is a stack string for EVALUATE to use
: FLATTEN  ( addr len -- addr len ) NOISE$ STRIP ;


\ ==============================================
\        --- REPLIES SUPPORT CODE ---
\ A REPLY:  Contains the number text messages, a counter 
\ and the base address of the XTs of the code that runs. 
\ The local counter is incremented after every invocation
\ When a reply is executed it PERFORMs the xt at the counter. 
\ When the counter >= #items the counter wraps back to 0 
\ Base address of the defining word's data structure 
\ is held on the return stack.
\ These macros give us access to those fields transparently 
MACRO #items  " R@ @ "          \ a constant 
MACRO last    " R@ 2+ "         \ a variable 
MACRO []XT    " CELLS R@ + 2 CELLS +"   \ address of Array of Xts 

: REPLY:  ( xt1 ... xtn  n -- )
   CREATE    
      DUP , 0 ,        \ compile the number of items & counter 
      0 ?DO  ,  LOOP   \ compile all the XTs on the data stack 

   DOES> ( -- [output depends on the code] )  
         >R    \ save base address of this data 
         last @ #items 1- > IF last OFF THEN 
         last @ []XT PERFORM  \ fetch the XT and EXECUTE it 
         last 1+! 
         R> DROP 
;          

\ =======================================================
\ A minimal set of key words are needed to compile the program

\ Replies for unknown token
   {  :: ." What does that suggest to you?" ;
      :: ." I see." ;
      :: ." I'm not sure I understand you fully." ;
      :: ." Topic shift: How is your love life?" ;
      :: ." Can you expand on that a bit?" ;
      :: ." Go on ..." ;
      :: ." Very interesting. Tell me more." ;
      :: ." Are you being honest?" ;
      :: ." Do you feel strongly about discussing such things?" ;
   } REPLY: TAPDANCE

\ bad words list
   {  :: ." Hey now. we don't use that kind of language here." ;
      :: ." I told you to watch your language!" ;
      :: ." That's it. I don't have to listen to this!" ;
    } REPLY: SHIT 



\ **************************************************
\ Eliza replies are separate file for easier editing

 S" DSK2.ELIZADATA" INCLUDED

\ **************************************************

.( .)

: $ACCEPT ( $addr -- ) DUP  1+ 80 ACCEPT  SWAP C!  ;

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


: /WORD ( addr len char --  1word len remainder len  )
        SPLIT 2SWAP 1 /STRING  ;

: EVEN#  ( n -- ?) DUP ALIGNED = ;

: CONJUGATE$ ( $ -- $ | $') \ check for PHRASES membership
         DUP PHRASES {MEMBER} \ DUP  CR ."  <" . SPACE POSITION @ .  ." > "
         DUP 0<                ( -- $ n)
         IF                    \ if not a member
             DROP              \ drop ndx, keep $
         ELSE
            NIP               \ remove $  ( -- n)
            ]CONJUGATE        \ replaced with conjugate
        THEN ;

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
               TAPDANCE CR TYPE 

           ELSE ( keywords found)
                DUP FLATTEN EVALUATE .REPLY
                ROGERIAN @
                IF  ( n) ]KEYWORD INPUT$ /TAIL /CONJUGATE
                ELSE DROP
                THEN
           THEN ;

: ?BADWORDS  ( -- )
       []SHIT 2 CELLS+ @  3 =
       IF 2000 MS
          PAGE
          RED BLK SCREEN 
          0 12 AT-XY ." DON'T LET THE DOOR HIT YOU"
          CR ." ON YOUR WAY OUT!"
          3000 MS
          END_SESSION
       THEN ;

.( .)
DECIMAL
: .OPENING  
      TEXT  
      WHT BLK SCREEN 
      S" Eliza" BIG.TYPE CR
;

: GREETING  ( -- )
      CR
      CR ." Hi! My name is Eliza."
      CR ." Can I help you?" ;

: ELIZA    ( -- )
      DECIMAL
      .OPENING 
      GREETING
      BEGIN
        ?BADWORDS
        LISTEN ANALYZE  REPLY
      AGAIN ;
