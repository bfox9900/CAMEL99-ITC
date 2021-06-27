\ linput reads file record into a counted string

: LINPUT  ( $ handle -- )
            OVER 1+ SWAP  ( -- $ $+1 handle)
            SELECT                        \ select the correct PAB
            2 FILEOP ?FILERR              \ read operation, test error#
            [PAB FBUFF] V@  SWAP [PAB RECLEN] VC@  VREAD
            [PAB CHARS] VC@ SWAP C!       \ update string length
;