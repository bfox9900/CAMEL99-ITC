\ VDPSAVE.FTH  words to SAVE and load 8K blocks of VDP memory in <1 second
\ You can use these words with DSK1.VDPMEM

HEX
  13 CONSTANT PRGRM   \ program format identifier used by E/A Module
2000 CONSTANT 8K

: NEWPAB   (  file$ len VDPaddr #bytes mode -- )
           -30 ^PAB +!         \ create new pab in VDP RAM below the current paB
           [PAB 30 0 VFILL     \ erase PAB and file name
        80 [PAB RECLEN] VC!    \ set reclen to HEX 80 like E/A module
\ pull params from the stack to init the PAB
           [PAB FLG] VC!       \ set file access mode byte
           [PAB REC#]  V!      \ set #bytes to save (integer)
           [PAB FBUFF] V!      \ set where the file will load VDP Ram
           [PAB FNAME] VPLACE  \ set file name
;

: POPPAB  ( -- ) 30 ^PAB +! ;

: VDPSAVE ( file$ len VDPaddr size -- )
          PRGRM NEWPAB  6 FILEOP ?FILERR POPPAB ;

: VDPLOAD ( file$ len VDPaddr size -- )
          8K MAX PRGRM NEWPAB  5 FILEOP ?FILERR POPPAB ;
