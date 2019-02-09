\ more.f   simple file viewer
\ default is DV80 files but you can change it with TI-99 file commands

HEX
\ : DV80    DISPLAY 50 VARI SEQUENTIAL ;  \ moved to ANSFILES

: MORE    ( <filename>)
          BL PARSE-WORD DUP ?FILE
          DV80 R/O OPEN-FILE ?FILERR
          >R   \ push handle onto Return stack
          BEGIN
             PAD DUP 50 R@ READ-LINE ?FILERR ( adr len flag)
          WHILE
             CR TYPE
             CKEY?
             IF CR ." ..."
                KEY 0F =            \ test for escape key
                IF R> CLOSE-FILE    \ if detected we're done here
                   2DROP
                   CR CR ." <Esc>" ABORT
                THEN
             THEN
          REPEAT
          R> CLOSE-FILE
          2DROP DROP ;
