\ load/save  file utilties for CAMEL99 Forth

\ G* The TI-99 file system does not support an exact command for
\ ** ANS WRITE-FILE, READ-FILE. SAVE-FILE, LOAD-FILE are TI-99 equivalents.
\ ** Limited to MAX 8K file size and operate in VDP RAM only

\ INCLUDE DSK1.TOOLS debugging

HEX
\ PRE-FAB file access mode selectors for default file binary type
0B CONSTANT W/O100  \ WRITE ONLY, binary, relative, fixed 100
0D CONSTANT R/O100  \ READ ONLY,  binary, relative, fixed 100
\ 13 CONSTANT PROG

: NEWPAB   (  file$ len VDPaddr #bytes mode -- )
           -30 ^PAB +!         \ create new pab in VDP RAM with NO buffer
           [PAB 30 0 VFILL     \ erase PAB and file name
         0 [PAB RECLEN] VC!    \ set reclen (0 means >100 (256) bytes)
         \ pulls params from the stack to init the PAB
           [PAB FLG] VC!       \ set file access mode byte
           [PAB REC#]  V!      \ set #bytes to save (integer)
           [PAB FBUFF] V!      \ set where the file will load VDP Ram
           [PAB FNAME] VPLACE  \ set file name
;

: SAVE-FILE ( file$ len VDPaddr count -- ior)
       W/O100 NEWPAB  6 FILEOP  30 ^PAB +! ;

: LOAD-FILE ( file$ len VDPaddr size -- ior)
       R/O100 NEWPAB  5 FILEOP  30 ^PAB +! ;

\                            pdt size
: SAVE-FONT ( file$ len --)  800 400  SAVE-FILE ?FILERR ;
: LOAD-FONT ( file$ len --)  800 400  LOAD-FILE ?FILERR ;

HEX
