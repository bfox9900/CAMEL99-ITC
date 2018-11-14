\ linput provides a high level way to read file data

VARIABLE INHDL

: LINPUT  ( $ -- )
           DUP 1+ INHDL @ READ-LINE ?FILERR
          ( -- $ len  ) SWAP C! ;
