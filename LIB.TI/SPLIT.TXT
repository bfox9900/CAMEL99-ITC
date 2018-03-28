 \ Split join a string into words like Python

DECIMAL

: LASTCHAR   ( addr len -- c) + 1- C@ ;

: -TRAILING  ( adr len -- adr len')     \ remove trailing blanks (spaces)
             BEGIN  2DUP LASTCHAR BL =  \ test char at end of string (adr+len)
             WHILE  1-                  \ while it is a blank, decrement length
             REPEAT ;

: -ALPHA  ( adr len -- n)   \ scan string backwards to find next blank
            BEGIN  2DUP LASTCHAR BL <>
            WHILE  1-
            REPEAT ;

\ "cut word"  cuts off last word from a string.
: /WORD  ( adr len -- adr len-len' adr' len')
             2DUP  -ALPHA    \ scan back past the alphanumeric chars
             DUP 0>          \ if the string has length
             IF DUP >R +        \ calc start of cut word
                SWAP R@ -       \ calc length of cut word
                R> 1-  -ROT     \ put new length on remainding string
             ELSE
                DROP 0          \ probably negative count. replace with 0
            THEN
;

\ split a string into words.
\ outputs multiple stack strings with count on top
: SPLITSTR  ( adr len -- adr len ... adr len cnt)
            -TRAILING          \ clean off trailing spaces
            0 >R               \ put a counter on rstack
            BEGIN
               /WORD  DUP 0>
            WHILE
               2SWAP -TRAILING  \ cut word put remaining string on top
               R> 1+ >R         \ incr the counter
            REPEAT
            2DROP
            R> 1+
;

CHAR " CONSTANT '"'

: .ITEM  (  adr len -- )  '"' EMIT  TYPE '"' EMIT  ;

: .ITEMS  ( [listofstrings] cnt --) \ destructive printlist
         CR 0 ?DO   .ITEM  SPACE LOOP ;

\  non-destructive print list backwards
: .RLIST  ( [listofstrings] cnt  -- [listofstrings] cnt )
        CR
        DUP 2* 1 SWAP
        ?DO
            I PICK  I PICK  .ITEM SPACE
        -2 +LOOP ;

: A$   S" All my ex's live in Texas" ;
: B$   S" ONE  TWO   THREE    FOUR     " ;
: C$   S" NOW IS THE TIME FOR ALL GOOD MEN TO COME TO THE AID OF THEIR COUNTRY      "  ;

\ **** END ****

: BL$  S"  "  ;
: C+!         ( n addr -- )   DUP >R  C@ +  R> C! ;
: APPEND      ( addr n $ -- ) 2DUP 2>R  COUNT +  SWAP CMOVE 2R> C+! ;
: JOIN   ( list cnt addr -- ) >R  0 ?DO   R@ APPEND  BL$ R@ APPEND  LOOP ;


: L>PAD    ( list cnt -- )  2* 0 DO  PAD I CELLS + !  LOOP ;
: PAD>REV  ( list cnt -- )  2* 0 DO  PAD I CELLS + @  LOOP ;

: REVERSE  ( list cnt  -- list cnt  list cnt )

        DUP 2* 1 SWAP
        ?DO
            I PICK  I PICK  PAD I + 2@
        -2 +LOOP ;


: LEFT$    ( $addr len newlen -- $addr len)  NIP  ;
: RIGHT$   ( $addr len newlen -- $addr len)  OVER SWAP - 0 MAX /STRING ;
: SEG$     ( $addr start size -- $addr len)  >R /STRING DROP R> ;
