\ dictionary examples   2025 Brian Fox

DICTIONARY: VFORTH  \ Init a dictionary in VDP RAM

HEX
: COPY-DICTIONARY
    CR
    LATEST @
    BEGIN
        DUP COUNT VFORTH ADD$
        NFA>LFA @ DUP    \ follow link in Forth dictionary to next word
    0= UNTIL
    DROP
;

\ lets you see the contents of a dictionary
: VDP.TYPE  ( Vaddr len --) BOUNDS ?DO I VC@ EMIT LOOP ;

: VWORDS  ( did -- ) \ dictionary ID argument required
    CR
    @
    BEGIN
        DUP VCOUNT VDP.TYPE SPACE
        NFA>LFA V@
        DUP 0=
    UNTIL
    DROP
;

\ make some dictionaries for a language ...
DICTIONARY: KWlist
: KEYWORD:  PARSE-NAME KWlist ADD$ ;
: KWFIND    kwlist LOOKUP ;

  KEYWORD: IF      KEYWORD: ELSE      KEYWORD: ENDIF
  KEYWORD: WHILE   KEYWORD: ENDWHILE
  KEYWORD: DO      KEYWORD: ENDDO
  KEYWORD: LOOP    KEYWORD: ENDLOOP
  KEYWORD: REPEAT  KEYWORD: UNTIL
  KEYWORD: FOR     KEYWORD: TO      KEYWORD: ENDFOR
  KEYWORD: BREAK   KEYWORD: READ    KEYWORD: WRITE
  KEYWORD: VAR     KEYWORD: END

  KEYWORD: PROCEDURE
  KEYWORD: PROGRAM

DICTIONARY: Symboltab
: SymbolFind   Symboltab LOOKUP ;

: INT: ( -- ) \ Example Integer definer
( *Not complete: needs data space allocation )
         BEGIN
           [CHAR] , PARSE-WORD  DUP
         WHILE
            Symboltab ADD$
         REPEAT
         2DROP ;

INT: X,Y,Z,HANDLE,Q,R,S,T
