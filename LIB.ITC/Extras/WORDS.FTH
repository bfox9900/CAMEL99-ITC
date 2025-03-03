\ words.fth per Forth 2012 with extra features  Brian Fox 2024 
\ Terms:
\ wid  wordlist indentifier
\ nt   name token  (ie Name field address)

NEEDS .S       FROM DSK1.TOOLS
NEEDS NFA>CFA  FROM DSK1.FORGET 

HEX
: ?BREAK  ( -- ) ?TERMINAL ABORT" *BREAK*" ;
: SPACEBAR ( -- ) KEY? BL = IF  KEY DROP  THEN ;

: GET-CONTEXT ( -- addr) CONTEXT @ @ ;

\ Remove wid and xt from the stack. Execute xt once for every word in the
\ wordlist wid, passing the name token nt of the word to xt, until the wordlist
\ is exhausted or until xt returns false.
: TRAVERSE-WORDLIST ( xt wid -- )
           SWAP >R
           BEGIN
              DUP
           WHILE
              DUP R@ EXECUTE
              NFA>LFA @
           REPEAT
           R> 2DROP
;

\ count number of words 
VARIABLE WC

: .WC   ( -- ) CR WC @ U.  ." words"  ;

\ prints the names of words in the CONTEXT compilation wordlist.
: NAME>STRING ( nt -- ) COUNT 1F AND ;
: ID.TYPE     ( addr len -- ) TYPE SPACE  WC 1+!  ?BREAK SPACEBAR ;
: .NFA        ( nt --) NAME>STRING ID.TYPE ;

: SCAN.VOC ( xt --  ) CR  WC OFF  GET-CONTEXT TRAVERSE-WORDLIST .WC ;


\ ** Now we can make variations that do different things ** 

\ print words that contain the string arguments 
 NEEDS SEARCH FROM DSK1.SEARCH

: .MATCH ( addr len -- )
   NAME>STRING 2DUP PAD COUNT SEARCH ( --  addr n ?)
   IF   2DROP ID.TYPE 
   ELSE 2DROP 2DROP 
   THEN ;

: WORDS ( <text>) 
   PARSE-NAME DUP 0= 
   IF    2DROP ['] .NFA  SCAN.VOC        \ normal "words"
   ELSE  PAD PLACE ['] .MATCH SCAN.VOC   \ match argument 
   THEN ;

\ type specific word printers 
: .CODEWORD  ( nfa -- ) DUP NFA>CFA DUP @      2- = IF .NFA  EXIT THEN DROP ;
: .VAR       ( nfa -- ) DUP NFA>CFA @  ['] DOVAR  = IF .NFA  EXIT THEN DROP ;
: .USER      ( nfa -- ) DUP NFA>CFA @  ['] DOUSER = IF .NFA  EXIT THEN DROP ;
: .CONST     ( nfa -- ) DUP NFA>CFA @  ['] DOCON  = IF .NFA  EXIT THEN DROP ;
: .COLON     ( nfa -- ) DUP NFA>CFA @  ['] DOCOL @ = IF .NFA  EXIT THEN DROP ;

\ User API 
: CODE-WORDS  ['] .CODEWORD SCAN.VOC ;
: VARIABLES   ['] .VAR   SCAN.VOC ;
: USERS       ['] .USER  SCAN.VOC ;
: CONSTANTS   ['] .CONST SCAN.VOC ;
: COLONS      ['] .COLON SCAN.VOC ;

