\ keywords example   2025 Brian Fox

: VDP.TYPE  ( Vaddr len --) BOUNDS ?DO I VC@ EMIT LOOP ;

\ lets you see the contents of a dictionary
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

\ make a dictionary for a language ...
DICTIONARY: KWlist
\ use API
: KEYWORD:  PARSE-NAME KWlist ADD$ ;
: KWFIND    KWlist LOOKUP ;
: KEYWORDS  KWlist VWORDS ;  \ show the dictionary of keywords


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

\ make a symbol table for this language with a data field
DICTIONARY: Symboltab
: SymbolFind   Symboltab LOOKUP ;
: SYMBOLS  Symboltab VWORDS ;

: NEWVAR   Symboltab ADD$  0 V, ;

: INT: ( -- ) \ Example Integer definer
( *Not complete: needs data space allocation )
         BEGIN
           [CHAR] , PARSE-WORD  DUP
         WHILE
            Symboltab ADD$
         REPEAT
         2DROP ;

INT: X,Y,Z,HANDLE,Q,R,S,T
