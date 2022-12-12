\ TEXTETC.FTH    tools to manipulate text

\ From Neil Baud's toolbox

\  SPLIT  ( str len char -- str1 len1 str2 len2)
\     Divide a string at a given character. The first part of the
\     string is on top, the remaining part is underneath. The
\     remaining part begins with the scanned-for character.

INCLUDE DSK1.TOOLS
\ INCLUDE DSK1.3RD4TH                      \ 50% faster but 2X larger

: 3RD  ( a b c -- a b c a ) 2 PICK ;       \ Changed name from Niels' THIRD

: SPLIT ( addr len char -- str1 len1 str2 len2)
         >R  2DUP  R> SCAN  2SWAP  3RD - ;

: /WORD ( addr len char -- aword len endstr len )
        SPLIT 2SWAP 1 /STRING ;

: CHOP   ( addr len n -- addr len addr len ) \ BFox addition
         >R                  \ Rpush n
         2DUP DROP R@        \ dup $, do left$
         2SWAP               \ put original $ on top
         R> /STRING ;        \ cut remainder string

: R+!    ( n -- )  S" R> + >R" EVALUATE ; IMMEDIATE

: '"'    [CHAR] " EMIT ;

: {CHARS} ( addr len -- addr len .... addr len count  )
          0 >R
          BEGIN
             1 CHOP
             1 R+!
             DUP 0=
          UNTIL
          2DROP
          R> ;

: {WORDS}  ( addr len -- addr len ... addr[n] len[n]  n )
         0 >R
         BL SKIP
         BEGIN  DUP 0>
         WHILE  BL /WORD
                1 R+!
         REPEAT
         2DROP
         R> ;

: N>R \ xn .. x1 N -- ; R: -- x1 .. xn n
\ Transfer N items and count to the return stack.
   DUP                        \ xn .. x1 N N --
   BEGIN
      DUP
   WHILE
      ROT R> SWAP >R >R      \ xn .. N N -- ; R: .. x1 --
      1-                      \ xn .. N 'N -- ; R: .. x1 --
   REPEAT
   DROP                       \ N -- ; R: x1 .. xn --
   R> SWAP >R >R
 ;

: .{LIST}  ( addr n   n -- )
          2* N>R
          0 ?DO  '"' TYPE '"' SPACE  LOOP ;


: A$   S" ABCDE 12335" ;
: B$   S" This is a test of a long string that we will chop into pieces!"  ;

 A$ BL SPLIT CR TYPE CR TYPE
 A$ BL /WORD CR TYPE CR TYPE
 A$  5 CHOP CR TYPE CR TYPE
