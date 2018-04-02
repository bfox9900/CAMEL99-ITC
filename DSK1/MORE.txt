\ more.f   simple file viewer
\ default is DV80 files but you can change it with TI-99 file commands

\ DISPLAY  80 VARI SEQUENTIAL

HEX
: MORE    ( <filename>)
          BL PARSE-NAME DUP ?FILE
          R/O OPEN-FILE ?FILERR
          >R                    \ push handle onto Return stack
          BEGIN
             PAD DUP 50 R@ READ-LINE ?FILERR
          WHILE
             CR TYPE
             KEY?
             IF CR ." ..."
                KEY 0F =            \ test for escape key
                IF R> CLOSE-FILE    \ if detected we're done here
                   2DROP
                   CR CR ." >>Esc<<" ABORT
                THEN
             THEN
          REPEAT
          R> CLOSE-FILE
          2DROP DROP ;
