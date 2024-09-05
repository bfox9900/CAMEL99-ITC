\ ELIZA in CAMEL99 Forth  simplified  May 24 2024

\ 3.0 changes reply data to reply code. 

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

\ NEEDS DUMP      FROM DSK1.TOOLS
NEEDS -TRAILING FROM DSK1.TRAILING
NEEDS S=        FROM DSK1.COMPARE
NEEDS SEARCH    FROM DSK1.SEARCH 
NEEDS MARKER    FROM DSK1.MARKER

NEEDS BIG.TYPE  FROM DSK2.BIGTYPE

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
\ : LASTCHAR ( $ -- c)  COUNT + 1- C@ ;            \ get last char in a string
: BETWEEN  ( n min max -- ?)  1+ WITHIN ;        \ is n between or equal-to 
\ : +PLACE      ( addr n $ -- ) 2DUP 2>R  COUNT +  SWAP MOVE 2R> C+! ;
: ERASE   0 FILL ;
: >=      ( n n -- ? ) 1- > ;
: <=      ( n n -- ? ) 1+ < ;

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

DECIMAL 
: TOUPPER ( addr len -- addr len ) \  convert STACK$ to uppercase in place
    2DUP  BOUNDS DO  I C@ UPPER I C!  LOOP ;

: TOLOWER ( addr len -- addr len) \  convert STACK$ to uppercase
    2DUP  BOUNDS DO  I C@ LOWER I C!  LOOP ;

.( .)
\
\ string cleaners .......
\ 
\ remove leading and trailing spaces 
: TRIM     ( addr len -- addr' len') BL SKIP  -TRAILING ;

: MEMBER? ( addr len char -- ? ) SCAN NIP ; \ is char in string addr len
: APPEND-CHAR ( char $ -- ) TUCK COUNT + C!  1 SWAP C+! ;
 
\ these stack strings are passed to STRIP$ (space is also noise)
: NOISE$ ( -- addr len) S" , .?!'@#$[]%^&*()_+-{}:<>" ;
: PUNCTUATION$ ( -- addr len) S" ,.?!'@#$[]%^&*()_+-{}:<>" ;

DECIMAL 
: STRIP  ( source len noise len -- Temp$ len)
      TEMP$ 80 ERASE 
      2SWAP BOUNDS \ loop over the source string 
      DO   
         2DUP I C@ MEMBER? 0=  
         IF
            I C@ TEMP$ APPEND-CHAR 
         THEN
      LOOP 
      2DROP
      TEMP$ COUNT ;

\ : T$ S"  This $is %a @ noisy %&*#$@ string!#@$!" ;
\ T$  NOISE$  STRIP CR TYPE 

\ FLATTEN converts a string into a FORTH word by STRIPPING noise 
\ characters and spaces
\ Example: I CAN'T -> ICANT
\ output is a stack string for EVALUATE to use
: FLATTEN  ( addr len -- addr len ) NOISE$ STRIP ;

\
\ forth word array. Code becomes data 
\
VARIABLE STK  \ can't use CSP because it is used by the colon compiler 

: {  ( -- )   SP@ STK ! ;
: }  ( -- n)  STK @ SP@ - 2/ 1- ;

\ *Lee Stewart improvement puts items in order as written          
: STORE-TOKENS 
      CELLS DUP ALLOT   \ reserve space for all XTs
      CELL+ 2 DO     
         HERE I - !     \ store next one back
      2 +LOOP  
;

: TOKENS:  ( xt1 ... xtn  n -- )
   CREATE    
      DUP ,            \ compile the number of items into this word
\ Compile all the XTs on the data stack from end to beginning
      STORE-TOKENS 
   DOES> ( ndx -- [output depends on the code] )  
        DUP CELL+ >R    \ save copy of xt addresses
        @               \ get the # of strings 
        OVER U< ABORT" TOKEN: index out of range" 
        CELLS R> +      \ index into the array of XTs
        PERFORM         \ fetch the XT and EXECUTE it 
;          

: :: :NONAME ( -- XT ) ; \ renamed for brevity

\ =========================[ ELIZA BEGINS ] ========================
\  --- REFLECTIONS ---
\ Since these are colon definitions, they will return the address 
\ and length of the string when TOKEN does the PERFORM function 

\ EXAMPLE:  7 ]PHRASE  will conjugate with 7 ]CONJUGATE 
   {  :: S" I AM" ;   \ 1
      :: S" I HAVE" ; \ 2 
      :: S" I'VE" ;   \ 3 
      :: S" I'M" ;    \ 4 
      :: S" I WILL" ; \ 5 
      :: S" I'D" ;    \ 6
      :: S" I'LL" ;   \ 7  
      :: S" MINE" ;   \ 8  
      :: S" ARE" ;    \ 9 
      :: S" WERE" ;   \ 10
      :: S" YOU" ;    \ 11
      :: S" ME" ;     \ 12
      :: S" YOUR" ;   \ 13
      :: S" MY" ;     \ 14
      :: S" I" ;      \ 15 
      :: S" WAS" ;
   }  DUP CONSTANT #PHRASES 
      TOKENS: ]PHRASE  

 {  :: S" YOU ARE"  ;  \ 1 
    :: S" YOU HAVE" ;  \ 2  
    :: S" YOU'VE" ;    \ 3  
    :: S" YOU'RE" ;    \ 4  
    :: S" YOU'LL" ;    \ 5 
    :: S" YOU WOULD" ; \ 6
    :: S" YOU WILL" ;  \ 7
    :: S" YOURS" ;     \ 8  
    :: S" AM" ;        \ 9  
    :: S" WAS" ;       \ 10 
    :: S" ME" ;        \ 11 
    :: S" YOU" ;       \ 12  
    :: S" MY" ;        \ 13 
    :: S" YOUR" ;      \ 14 
    :: S" YOU" ;       \ 15 
    :: S" WERE" ;
 }   TOKENS: ]CONJUGATE   

\ : .PHRASES  
\  CR 
\   #PHRASES   0
\   DO 
\     CR I ]PHRASE TYPE ." , "  I ]CONJUGATE TYPE  
\   LOOP 
\ ;

: FIND-PHRASE ( addr len -- n | -1)
   -1  -ROT        \ not found flag under string 
   #PHRASES 0
   DO 
      2DUP I ]PHRASE COMPARE 0=
      IF ROT DROP  \ remove not found flag 
         I -ROT    \ replace with index and put under string
         LEAVE 
      THEN 
   LOOP
   2DROP
;


\ : CONJUGATE  ( addr len -- addr' len) 
\   FIND-PHRASE DUP 0< ABORT" Can't conjugate" 
\   ]CONJUGATE 
\ ;


\  KEYWORDS .....
\ keywords are stored in a fixed width array for faster lookups 
VARIABLE #KEYWORDS 

16 CONSTANT $WIDTH 
$WIDTH 70 * CONSTANT KEY_SIZE 

CREATE []KEYWORDS   []KEYWORDS  KEY_SIZE ALLOT  
[]KEYWORDS KEY_SIZE ERASE \ ERASE the ar

: ]KEYWORD ( n -- addr) $WIDTH * []KEYWORDS + ; 
: KEY,  ( addr u --) #KEYWORDS @ ]KEYWORD PLACE  #KEYWORDS 1+! ;
: KEY"  [CHAR] " PARSE KEY, ; 

DECIMAL
    KEY" SHIT"       
    KEY" SHUTUP"    
    KEY" DICK"         
    KEY" FUCK"      
    KEY" ASSHOLE"           
    KEY" BASTARD"   
    KEY" TI-99"    
    KEY" ROBOT"      
    KEY" ROBOTS"      
    KEY" MACHINE"     
    KEY" COMPUTER"    
    KEY" CONSOLE"     
    KEY" SORRY"         
    KEY" ALWAY"     
    KEY" FRIEND"     
    KEY" BYE"        
    KEY" GOODBYE"    
    KEY" CAUSE"      
    KEY" DREAM"      
    KEY" DREAMT"      
    KEY" HELLO"      
    KEY" HELL "       
    KEY" ALIKE"      
    KEY" CAN YOU"    
    KEY" CAN I"      
    KEY" YOU ARE"    
    KEY" YOU'RE"      
    KEY" NAME"       
    KEY" WHY DON'T YOU"   
    KEY" WHY CAN'T I"   
    KEY" I REMEMBER"  
    KEY" DO YOU REMEMBER"   
    KEY" I DON'T"    
    KEY" I FEEL"     
    KEY" ARE YOU"    
    KEY" I CAN'T"    
    KEY" I AM"       
    KEY" I'M"        
    KEY" YOUR"       
    KEY" I WANT"     
    KEY" MY"         
    KEY" MAYBE"      
    KEY" I NEED"     
    KEY" I THINK"   
    KEY" THINK"    
    KEY" YOU"        
    KEY" YES"        
    KEY" I HAVE"     
    KEY" I'VE"       
    KEY" REALLY"  

    KEY" WHAT"    
    KEY" HOW"     
    KEY" WHO"     
    KEY" WHERE"  
    KEY" WHEN"    
    KEY" WHY"     
    
    KEY" NO"      
    KEY" WE"      
    KEY" OK"       
    KEY" HI"      
 \ this word conflicts with IF in Forth. :-) Need a vocabulary
 \   KEY" IF"   
\
 \ foreign language cue words       
    KEY" FRANCAIS"      
    KEY" ITALIANO"      
    KEY" ESPANOL"     
    KEY" DEUTSCH"      
    KEY" NEDERLANDS"   
    KEY" BONJOUR"   

\ debugging ..............
\ : PRINT$  COUNT TYPE ;
\ : .KEYWORDS  ( -- )
\   CR #KEYWORDS @ 0  
\   DO I ]KEYWORD PRINT$ ." , "  LOOP ;

\ parse out words delimited by char and keep remainder on data stack 
: /WORD ( addr len char --   remainder len 1word len )
      SPLIT 2SWAP 1 /STRING 2SWAP ;

: 1WORD  BL /WORD ;

\ after a search, compute the position of string1 in string2 
: $POS  ( a1 n1 a2 n2 -- n) NIP OVER SWAP - ;

\ find first keyword in input string arg and store index 
\ and position in variables for use later 
VARIABLE KWORD# 
VARIABLE POSITION 

: FIND-KEYWORD ( addr len -- ?)
   KWORD# ON 
   POSITION OFF  
   #KEYWORDS @ 0
   DO \ I .  ( debug)
      2DUP I ]KEYWORD COUNT SEARCH ( --- a n a n ?) 
      IF   I KWORD# !  
           2 PICK OVER - POSITION ! 
           2DROP
           LEAVE 
      THEN 
      2DROP 
   LOOP 
   2DROP 
   KWORD# @ 
;

: KEYWORD$   ( -- $addr) KWORD# @ ]KEYWORD ;

\ : A$ S" This rain in spain, is mainly on the TI-99" ;
\  S" POOPY DIAPER" FIND-KEYWORD 
\  CR CR .S

\ : .KEYWORD   KEYWORD$ COUNT TYPE ;

: ANALYZE  ( addr len --) 
  PUNCTUATION$ STRIP   TOUPPER  FIND-KEYWORD ;      


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
      STORE-TOKENS 
   DOES> ( -- [output depends on the code] )  
         >R    \ save base address of this data 
         last @ #items >= IF last OFF THEN 
         last @ []XT PERFORM  \ fetch the XT and EXECUTE it 
         last 1+! 
         R> DROP 
;          

\ =======================================================
\ A minimal set of key words are needed to compile the program

\ Replies for unknown token
    { :: CR ." What does that suggest to you?" ;
      :: CR ." I see." ;
      :: CR ." I'm not sure I understand you fully." ;
      :: CR ." Topic shift: How is your love life?" ;
      :: CR ." Can you expand on that a bit?" ;
      :: CR ." Go on ..." ;
      :: CR ." Very interesting. Tell me more." ;
      :: CR ." Are you being honest?" ;
      :: CR ." Do you feel strongly about discussing such things?" ;
    } REPLY: TAPDANCE


.( .)
\ USER  text input 
: $ACCEPT ( $addr -- addr len) DUP 80 ACCEPT ;

: LISTEN ( -- addr len)
        BEGIN
        \    BEEP 
            CR ." >"  PAD $ACCEPT
            DUP 0=
        WHILE 
            2DROP 
        REPEAT 
        2DUP INPUT$ PLACE 
;
           
\ cut input string at POSITION, found by FIND-KEYWORD + length 
\ of the keyword phrase.
\ return everything after the keyword phrase
 : /TAIL  ( addr len -- adr len) 
      POSITION @  KEYWORD$ LEN +  /STRING 0 MAX ;


\ conjugate any phrases in the ]PHRASE table 
: ?CONJUGATE ( addr len -- addr len | addr' len) 
        2DUP FIND-PHRASE ( -- $ len ndx )            ( -- $ n)
        DUP 0< 
        IF DROP    
        ELSE NIP NIP ]CONJUGATE  \ replaced $ with conjugate
        THEN  
;

\ print input string word by word and cojugate words found in the ]phrase table
: /CONJUGATE  ( addr len -- )
        TRIM 
        BEGIN
           DUP 0> ( len>0 ?)
        WHILE
            1WORD ?CONJUGATE TOLOWER TYPE SPACE 
        REPEAT
        2DROP ;

: '?'  [CHAR] ? EMIT ;
: '.'  [CHAR] . EMIT ;
: '"'  [CHAR] " EMIT ;

: <ROGERIAN>  ( -- ) 
  INPUT$ COUNT /TAIL DUP 1 < IF 2DROP EXIT THEN 
  PUNCTUATION$ STRIP  /CONJUGATE  ;

: <ROGERIAN?>  <ROGERIAN> '?' ;

DECIMAL
: END_SESSION
      CR 
      CR ." OK. Thanks for chatting."
      CR ." Bye bye!"  700 MS
      CR ." ...Oh and by the way..."
      1000 MS
      CR
      CR ." My bill is $400.00." 500 MS 
      CR ." (I accept Paypal)"  300 MS 
      CR ." :-)"   2000 MS 
      BYE ;

: GOODBYE   END_SESSION ;
: BYE       END_SESSION ;

\ bad words list
    { :: CR ." Hey now."  CR ." We don't use that kind of language here." ;
      :: CR ." I told you to watch your language!" ;
      :: CR ." That's enough! I don't have to listen to this!"
               1000 MS END_SESSION ;
    } REPLY: SHIT 

\ all these words cause SHIT to happen :-)
 : FUCK     SHIT ;
 : ASS      SHIT ;
 : BASTARD  SHIT ;
 : HELL     SHIT ;
 : DICK     SHIT ;

: SHUTUP    CR CR ." That's rude!"  1000 MS BYE ;

: CONSOLE   CR
            CR ." Exiting ELIZA ..."
            CR ." CAMEL99 FORTH"
            CR  QUIT ;

: REPLY   ( n -- )  \ n = keyword index
      CR
      DUP -1 =
      IF  ( no matching keyword)
         DROP
         TAPDANCE

      ELSE ( keyword found)
         ( n) ]KEYWORD COUNT FLATTEN EVALUATE 
      THEN ;

\ **************************************************
\ Eliza replies are separate file for easier editing

 S" DSK2.ELIZADATA3" INCLUDED

\ **************************************************
.( .)
DECIMAL
: CENTER.TYPE  ( addr len -- ) C/L@ OVER - 2/ SPACES TYPE ;

: .OPENING  
      TEXT  
      WHT BLK SCREEN 
      S"  Eliza" BIG.TYPE 
      CR S" by Brian Fox 2024" CENTER.TYPE 
      CR 
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
        LISTEN ANALYZE REPLY
      AGAIN ;

: START    WARM ELIZA ;

\ Save as binary program 
LOCK 

INCLUDE DSK1.SAVESYS

' START SAVESYS DSK2.ELIZA
