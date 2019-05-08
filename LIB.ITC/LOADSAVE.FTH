\ loadfile savefile utilties
HEX
0B CONSTANT W/O100  \ output, internal, relative, fixed 100
0D CONSTANT R/O100  \ input,  internal, relative, fixed 100

: SETPAB   ( VDPaddr count file$ len mode -- )
            [PAB FLG] VC!       \ set file access mode byte
            [PAB FNAME] VPLACE  \ set file name
          0 [PAB RECLEN] VC!    \ set reclen
            [PAB REC#]  V!      \ set #bytes to save (int)
            [PAB FBUFF] V!      \ set start address in VDP Ram (int) ;

: SAVE-FILE ( VDPaddr count file$ len mode -- )
           PSHPAB SETPAB  6 FILEOP ?FILERR  POPPAB ;

: LOAD-FILE ( VDPaddr count file$ len mode -- )
           PSHPAB SETPAB  5 FILEOP ?FILERR  POPPAB ;
           
400 CONSTANT 1K
800 CONSTANT 2K

: SAVE-FONT ( file$ len size --)  2K SWAP  2SWAP W/O100 SAVE-FILE ;
: LOAD-FONT ( file$ len size --)  2K SWAP  2SWAP R/O100 LOAD-FILE ;