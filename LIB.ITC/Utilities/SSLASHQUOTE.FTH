\ strings with embedded escaped characters

\ source: http://www.forth200x.org/escaped-strings.html

\ This code works as designed but the Camel99 but...
\ Camel99 kernel only interprets 'BACKSPACE' and ^M ( carriage return)
\   *** USEFUL ONLY FOR CAMEL99 Forth TTY version ***

HERE
\ Camel99 Forth Harness
: 2OVER   3 PICK 3 PICK ;
\ SLITERAL.FTH    Not in Camel99 Forth kernel
: SLITERAL ( ca u --) POSTPONE (S")  S,  ; IMMEDIATE

DECIMAL

: C+!           \ c c-addr --
\ *G Add CHARacter C to the contents of address C-ADDR.
  TUCK C@ + SWAP C!
;

: ADDCHAR       \ CHAR string --
\ *G Add the CHARacter to the end of the counted string.
  TUCK COUNT + C!
  1 SWAP C+!
;

: APPEND        \ c-addr u $dest --
\ *G Add the string described by C-ADDR U to the counted string at
\ ** $DEST. The strings must not overlap.
  >R
  TUCK  R@ COUNT +  SWAP CMOVE          \ ADD SOURCE TO END
  R> C+!                                \ ADD LENGTH TO COUNT
;

: EXTRACT2H   \ c-addr len -- c-addr' len' u
\ *G Extract a two-digit hex number in the given base from the
\ ** start of the string, returning the remaining string
\ ** and the converted number.
  BASE @ >R  HEX
  0 0 2OVER DROP 2 >NUMBER 2DROP DROP
  >R  2 /STRING  R>
  R> BASE !
;

CREATE ESCAPETABLE      \ -- addr
\ *G Table of translations for \a..\z.
        7 C,   \ \a BEL (Alert)
        8 C,   \ \b BS  (Backspace)
   CHAR c C,   \ \c
   CHAR d C,   \ \d
       27 C,   \ \e ESC (Escape)
       12 C,   \ \f FF  (Form feed)
   CHAR g C,   \ \g
   CHAR h C,   \ \h
   CHAR i C,   \ \i
   CHAR j C,   \ \j
   CHAR k C,   \ \k
       10 C,   \ \l LF  (Line feed)
   CHAR m C,   \ \m
       10 C,   \ \n (Unices only)
   CHAR o C,   \ \o
   CHAR p C,   \ \p
   CHAR " C,   \ \q "   (Double quote)
       13 C,   \ \r CR  (Carriage Return)
   CHAR s C,   \ \s
        9 C,   \ \t HT  (horizontal tab}
   CHAR u C,   \ \u
       11 C,   \ \v VT  (vertical tab)
   CHAR w C,   \ \w
   CHAR x C,   \ \x
   CHAR y C,   \ \y
        0 C,   \ \z NUL (no CHARacter)

CREATE CRLF$   \ -- addr ; CR/LF as counted string
  2 C,  13 C,  10 C,

: ADDESCAPE  \ c-addr len dest -- c-addr' len'
\ *G Add an escape sequence to the counted string at dest,
\ ** returning the remaining string.
  OVER 0=                               \ ZERO LENGTH CHECK
  IF  DROP  EXIT  THEN
  >R                                    \ -- CADDR LEN ; R: -- DEST
  OVER C@ [CHAR] x = IF                 \ HEX NUMBER?
    1 /STRING EXTRACT2H R> ADDCHAR  EXIT
  THEN
  OVER C@ [CHAR] m = IF                 \ CR/LF PAIR
    1 /STRING
    13 R@ ADDCHAR  10 R> ADDCHAR  EXIT
  THEN
  OVER C@ [CHAR] n = IF                 \ CR/LF PAIR? (WINDOWS/DOS ONLY)
    1 /STRING  CRLF$ COUNT R> APPEND  EXIT
  THEN
  OVER C@ [CHAR] a [CHAR] z 1+ WITHIN IF
    OVER C@ [CHAR] a - ESCAPETABLE + C@  R> ADDCHAR
  ELSE
    OVER C@ R> ADDCHAR
  THEN
  1 /STRING
;

: PARSE\" ( c-addr len dest -- c-addr' len')
\ *G Parses a string up to an unescaped '"', translating '\'
\ ** escapes to CHARacters. The translated string is a
\ ** counted string at *\i{dest}.
\ ** The supported escapes (case sensitive) are:
\ *D \a      BEL          (alert)
\ *D \b      BS           (backspace)
\ *D \e      ESC (not in C99)
\ *D \f      FF           (form feed)
\ *D \l      LF (ASCII 10)
\ *D \m      CR/LF pair - for HTML etc.
\ *D \n      newline - CRLF for Windows/DOS, LF for Unices
\ *D \q      double-quote
\ *D \r      CR (ASCII 13)
\ *D \t      HT (tab)
\ *D \v      VT
\ *D \z      NUL (ASCII 0)
\ *D \"      double-quote
\ *D \xAB    Two CHAR Hex numerical CHARacter value
\ *D \\      backslash itself
\ *D \       before any other CHARacter represents that CHARacter
  DUP >R
  0 SWAP C!                             \ zero destination
  BEGIN                                 \ -- caddr len ; r: -- dest
    DUP
   WHILE
    OVER C@ [CHAR] " <>                 \ check for terminator
   WHILE
    OVER C@ [CHAR] \ = IF               \ deal with escapes
      1 /STRING R@ ADDESCAPE
    ELSE                                \ normal character
      OVER C@ R@ ADDCHAR  1 /STRING
    THEN
  REPEAT THEN
  DUP                                   \ step over terminating "
  IF 1 /STRING  THEN
  R> DROP
;

CREATE POCKET ( -- addr)
\ *G A tempory buffer to hold processed string.
\    This would normally be an internal system buffer.

\ s" /COUNTED-STRING" environment? 0= [if] 256 [then]
258  ALLOT \ for Camel99 Forth

: READESCAPED  ( "ccc" -- c-addr)
\ *G Parses an escaped string from the input stream according to
\ ** the rules of *\fo{parse\"} above, returning the address
\ ** of the translated counted string in *\fo{POCKET}.
  SOURCE >IN @ /STRING TUCK             \ -- len caddr len
  POCKET PARSE\" NIP
  - >IN +!
  POCKET
;

: S\"          ( "string" -- caddr u)
\ *G As *\fo{S"}, but translates escaped CHARacters using
\ ** *\fo{parse\"} above.
  READESCAPED COUNT  STATE @
  IF  POSTPONE SLITERAL  THEN
; IMMEDIATE

HERE SWAP -
DECIMAL
CR . .( bytes)


PAGE
S\" \n\n\n\n\nThis still looks weird to me"
