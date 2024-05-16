\ Leo Wong  2 April 02003 fyj +
\ !+ (.) ++ ,s -digit .c 4dup <next> >d >n ?? @+ alias aliases array
\ cell k* macro many: noop padlength preparse s= tools.txt

1 CELLS CONSTANT CELL
-1 CELLS CONSTANT -CELL
: CELL-  ( A1 -- A2 )  CELL - ;
S" /PAD" ENVIRONMENT? 0= [IF] 84 [THEN] CONSTANT PADLENGTH
: NOOP ( -- ) ;
: 4DUP  ( A B C D -- A B C D A B C D )  2OVER 2OVER ;
: .C
   STATE @
   IF  POSTPONE [CHAR]  POSTPONE EMIT
   ELSE CHAR EMIT THEN ; IMMEDIATE
: S=  ( A1 U1 A2 U2 -- FLAG ) COMPARE 0= ;
: K*  ( N -- 1024*N )  1024 * ;
: @+  ( A -- A' X )  DUP CELL+ SWAP @ ;
: !+  ( X A -- A+  )  TUCK ! CELL+ ; \ bf: changed arg order to be like ! 
: ++  ( A -- )  1 SWAP +! ;
: -DIGIT  ( C -- N )  [CHAR] 0 -  DUP 9 >  7 AND - ;
: (.)  ( N -- CA U )  DUP ABS 0 <#  #S  ROT SIGN  #> ;
: >D  ( A U -- D )  0 0 2SWAP >NUMBER NIP NIP ;
: >N  ( A U -- N )  >D D>S ;

: ARRAY  \ DEFINE AN ARRAY OF N CELLS
   CREATE ( +N -- ) CELLS ALLOT
   DOES> ( +N -- A ) SWAP CELLS + ;

: ,S  ( X1 ... XN N -- )  \ COMPILE N VALUES
   BEGIN ?DUP WHILE  DUP ROLL ,  1-  REPEAT ;

: EXCHANGE ( A1 A2 -- )  2DUP 2>R  @ SWAP @  R> !  R> ! ;

: 2EXCHANGE  ( A1 A2 -- )  2DUP 2>R  2@ ROT 2@  R> 2!  R> 2! ;

: ??  \ by wil baden: if <word> then
   S" IF" EVALUATE BL WORD COUNT EVALUATE  S" THEN" EVALUATE ; IMMEDIATE

: SLITERAL ( ca u --) \ Not in Camel99 Forth kernel
  POSTPONE (S")  S,  ; IMMEDIATE

: MACRO  \ BY WIL BADEN
   : CHAR PARSE  POSTPONE SLITERAL  POSTPONE EVALUATE POSTPONE ;
   IMMEDIATE ;

: ALIAS  ( XT -- ) >R : R> COMPILE, POSTPONE ; ;

: ALIASES  ( XT -- XT )  DUP ALIAS ;

: <NEXT>    BL WORD COUNT ;

: PREPARSE  >IN @ >R <NEXT> R> >IN ! ;

: MANY:  ( ... -- ... )   \ usage: many <word> ... ;
   ' >R
   BEGIN
     PREPARSE 2DUP S" ;" COMPARE
   WHILE
     2DUP S" (" S= IF 2DROP POSTPONE (  ELSE   ( fix colorizer :)
     2DUP S" \" S= IF 2DROP POSTPONE \  ELSE 
               NIP IF R@ EXECUTE        ELSE
                      REFILL 0= ABORT" ; MISSING AFTER MANY"
     THEN THEN THEN
   REPEAT 2DROP
   BL WORD DROP  \ SKIP ;
   R> DROP ;
