\ Number BASE conversion tools for the programmer

: BASE[    S" BASE @ >R" EVALUATE ; IMMEDIATE
: ]BASE    S" R> BASE !" EVALUATE ; IMMEDIATE

 DECIMAL
: BINARY      2 BASE ! ;
: OCTAL       8 BASE ! ;

: .BIN      BASE[  BINARY U.  ]BASE ;
: .HEX      BASE[  HEX    U.  ]BASE ;
: .OCT      BASE[  OCTAL  U.  ]BASE ;
: .DEC      BASE[  DECIMAL U. ]BASE ;

\ changing interpretation number base inside a colon definition
: [DECIMAL]  DECIMAL ; IMMEDIATE
: [HEX]      HEX     ; IMMEDIATE 

