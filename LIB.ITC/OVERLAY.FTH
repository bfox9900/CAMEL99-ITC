\ loadfile savefile utilties
NEEDS FILEOP FROM DSK1.ANSFILES

HEX
0B CONSTANT W/O100  \ output, internal, relative, fixed 100
0D CONSTANT R/O100  \ input,  internal, relative, fixed 100

: SETPAB   ( VDPaddr count file$ len mode -- )
            [PAB FLG] VC!       \ set file access mode byte
            [PAB FNAME] VPLACE  \ set file name
          0 [PAB RECLEN] VC!    \ set reclen
            [PAB REC#]  V!      \ set #bytes to save (int)
            [PAB FBUFF] V!  ;   \ set start address in VDP Ram (int)

: SAVE-FILE ( VDPaddr count file$ len mode -- )
            PSHPAB SETPAB  6 FILEOP ?FILERR  POPPAB ;

: LOAD-FILE ( VDPaddr count file$ len mode -- )
            PSHPAB SETPAB  5 FILEOP ?FILERR  POPPAB ;

: SAVE-OVERLAY ( file$ len cpuadr vdpadr size --)
            2DUP 2>R  \ top 2 args
            VWRITE    \ move CPU block to VDP RAM
            2R>       ( file len VDPaddr size )
            2SWAP W/O100 SAVE-FILE ;

: LOAD-OVERLAY ( file$ len cpuadr vdpadr size --)
            DUP >R     \ save size
            ROT >R     \ save cpu address
            OVER >R    \ save VDPaddr
( file len VDPaddr size) 2SWAP R/O100 LOAD-FILE
            R> R> R> ( VPDaddr cpu-adr size) VREAD ;

: LINK-OVERLAY
