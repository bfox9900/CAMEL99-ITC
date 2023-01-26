\ loadfile/ savefile utilties for CAMEL99 Forth 
\ Update: Jan 25, 2023: LOAD-FONT will load a 2K font file

\ The TI-99 file system does not support an exact command for
\ ANS Forth WRITE-FILE, READ-FILE. These are the TI-99 equivalents.
\ Limited to 8K file size and VDP RAM buffer only

\ INCLUDE DSK1.TOOLS debugging only

HEX
\ PRE-FAB file access mode selectors for default file binary type
0B CONSTANT W/O100  \ WRITE ONLY, binary, relative, fixed 100
0D CONSTANT R/O100  \ READ ONLY,  binary, relative, fixed 100

: NEWPAB   (  file$ len VDPaddr #bytes mode -- )
  -30 ^PAB +!         \ create small pab in VDP RAM
  [PAB 30 0 VFILL     \ erase PAB and file name
  0 [PAB RECLEN] VC!  \ set reclen (0 means >100 (256) bytes)
\ pulls params from the stack to init the PAB
  [PAB FLG] VC!       \ set file access mode byte
  [PAB REC#]  V!      \ set #bytes to save (integer)
  [PAB FBUFF] V!      \ set where the file will load VDP Ram
  [PAB FNAME] VPLACE  \ set file name
;

: POPPAB  ( -- ) 30 ^PAB +! ;

: SAVE-FILE ( file$ len VDPaddr size mode -- )
  NEWPAB  6 FILEOP ?FILERR  POPPAB ;

: LOAD-FILE ( file$ len VDPaddr size mode -- )
  NEWPAB  5 FILEOP ?FILERR  POPPAB ;

\ Usage:  S" DSK3.FONT0000" SAVE-FONT
\         S" DSK3.FONT0000" LOAD-FONT
\                            pdt size  mode
: SAVE-FONT ( file$ len --)  800  400  W/O100 SAVE-FILE ;
: LOAD-FONT ( file$ len --)  800 1000  R/O100 LOAD-FILE ;
