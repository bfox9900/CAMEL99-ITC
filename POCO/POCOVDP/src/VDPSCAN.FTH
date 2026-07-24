
: VDP.SCAN (  adr len char -- adr' len')
        >R     \ remember char
        BEGIN
          DUP
        WHILE ( len<>0)
          OVER VC@ R@ <>
        WHILE ( R@<>char)
          1 /STRING            \ advance to next char address
        REPEAT
        THEN
        R> DROP  \ drop char   \ 32 bytes
;

: VDP.SKIP (  adr len char -- adr' len')
        >R     \ remember char
        BEGIN
          DUP
        WHILE ( len<>0)
          OVER VC@ R@ =
        WHILE ( R@<>char)
          1 /STRING            \ advance to next char address
        REPEAT
        THEN
        R> DROP  \ drop char   \ 32 bytes
;


: LASTCHAR   ( Vaddr len -- c) 2DUP + 1- VC@ ;

: VDELIMIT  ( Vaddr len char -- n)  \ scan string backwards to find next char
    >R
    BEGIN  LASTCHAR R@ <>
    WHILE  1-
    REPEAT
    1-
    R> DROP ;
