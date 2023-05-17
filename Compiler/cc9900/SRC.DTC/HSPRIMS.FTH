\ HSPRIMS.FTH  Optimizing compilers for fast RAM code primitives

: HSPRIM: ( addr -- ) \ <name>
  CREATE  , IMMEDIATE    \ remember the address. Make new word IMMEDIATE 
  DOES> @      \ fetch the address
        STATE @ \ what is the compiler state ?
        IF   COMPILE,
        ELSE EXECUTE
        THEN  ;

\ Address       Name
\ -------       -----
_HSDUP  HSPRIM: DUP
_HSPLUS HSPRIM: +
_HS@    HSPRIM: @
_HS!    HSPRIM: !
_HSDROP HSPRIM: DROP
