\ ASM2CODE.FTH  convert an ASM word to machine code  2022 Brian Fox

INCLUDE DSK1.MARKER

MARKER /.CODE

NEEDS CFA>NFA     FROM DSK1.FORGET
NEEDS MAKE-OUTPUT FROM DSK1.OUTFILE

HEX
045A CONSTANT 'NEXT'

\ convert n to HEX number string
: .#### ( n -- addr len )
  BASE @ >R HEX 0 <# # # # # #>  TYPE  R> BASE ! ;

: ?CR  ( -- ) VCOL @ 24 > IF CR 2 SPACES THEN ;

: WRITE-CODE ( cfa  -- )
     2 SPACES
     BEGIN
       CELL+
       DUP @           \ addr code
       DUP 'NEXT' <>   \ addr code ?
     WHILE
        .####  S"  , " TYPE ?CR
     REPEAT
     2DROP
;

: .HEADER  ( $addr -- addr len)
  S" CODE " TYPE  COUNT TYPE  ;

: .FOOTER ( -- )
  ?CR S" NEXT," TYPE
  CR S" ENDCODE" TYPE ;

: ?CODE  ( cfa -- ) DUP @ 2- <> ABORT" Not a code word" ;

: .CODE ( cfa  )
    DUP ?CODE
    DUP CFA>NFA CR .HEADER
    CR WRITE-CODE
   ?CR .FOOTER
    CR
;

\ usage:
\ S" CLIP" MAKE-OUTPUT
\ ' >R .CODE
\ ' CMOVE .CODE
\ ' CPUT .CODE
\ CLOSE-OUTPUT
