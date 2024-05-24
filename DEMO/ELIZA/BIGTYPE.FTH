\ bittype.fth  prints big characters made of the letter

HEX
 \ get us access to the pattern table in VDP RAM
 : ]PDT ( char# --  Vaddr) 8* 800 + ; 

DECIMAL 
 VARIABLE LETTER

: BIG.TYPE ( addr len -- )
    8 0 DO  CR                       ( str len)
        2DUP BOUNDS ?DO
            I C@ DUP LETTER !
            ]PDT J +  VC@            \ PDT char, byte# J from VDP RAM
            2 7 DO                   \ from bit# 7 to 2
                DUP 1 I LSHIFT AND   \ mask out each bit
                IF    LETTER @ EMIT  \ if true emit a character
                ELSE  SPACE          \ else print space
                THEN
            -1 +LOOP
            DROP
        LOOP                         ( str len)
    LOOP
    2DROP ;

