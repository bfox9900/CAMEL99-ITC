\ Backus Naur Parser Generator - Brad Rodriguez
\ BNF Parser                                (c) 1988 B. J. Rodriguez

INCLUDE DSK1.TOOLS.F

MARKER EMPTY

VARIABLE SUCCESS

: <BNF ( -- )
       SUCCESS @
       IF  R> >IN @ >R DP @ >R  >R
       ELSE  R> DROP
       THEN ;

: BNF> ( -- )
       SUCCESS @ IF  R>  R> R> 2DROP   >R
       ELSE  R>  R> DP ! R> >IN !  >R
       THEN ;

: |    ( -- )
       SUCCESS @ IF  R> R> R> 2DROP DROP
       ELSE  R> R> R> 2DUP >R >R >IN ! DP !  1 SUCCESS !  >R
       THEN ;

: BNF: ( -- SYS )  : POSTPONE RECURSE POSTPONE <BNF ; IMMEDIATE

: ;BNF ( SYS -- )    POSTPONE BNF> POSTPONE ; ; IMMEDIATE

: @TOKEN ( -- N )    SOURCE >IN @ /STRING DROP C@ ;
: +TOKEN ( F -- )    IF 1 >IN +! THEN ;

: =TOKEN ( N -- )
         SUCCESS @ IF @TOKEN =  DUP SUCCESS ! +TOKEN
         ELSE DROP 
         THEN ;

: TOKEN ( N -- )    CREATE C, DOES> ( A -- )  C@ =TOKEN ;