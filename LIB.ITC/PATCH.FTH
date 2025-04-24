\ PATCH.FTH    patch a new word into an existing word  Nov 2021

\ Method:
\ Patched word:  <DOCOL> <1STWORD> <2NDWORD> < etc ... > <EXIT>
\ Patching changes these   ^^^^      ^^^^
\ 1stword is patched to address of the new word.
\ 2ndword is patch to be the address of Forth EXIT (end of sub-routine)
\

INCLUDE DSK1.TOOLS

: PATCHES ( xt --)
    '                        \ get code address of the word to patch
    >BODY DUP>R              \ advance to the data address and save a copy
      !                      \ store the execution token in data field
    ['] EXIT R> CELL+ !  ;   \ store XT of EXIT in the next address

: TEST   CR ." DEFAULT ACTION" ;

: TRICK  CR ." FOOLED YA! :-)" ;

' TRICK PATCHES TEST
