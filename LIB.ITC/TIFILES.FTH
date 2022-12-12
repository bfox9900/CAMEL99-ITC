\ TIFILES.FTH  NON ANS Files for the low-fat computing    Mar 27 2021 FOX
\ Smaller alternative to DSK1.ANSFILES. More like BASIC file interface
HERE
\ pab definer uses PSZ (pab size = 300 bytes) to compute the PAB address
: PAB: ( n -- )  CREATE  PSZ * VDPTOP SWAP - ,   DOES> @ ^PAB ! ;

\ make 3 predefined peripheral access blocks.
\ Each one sets the current PAB as active in the ^PAB variable
1 PAB: #1   2 PAB: #2   3 PAB: #3

\ modify the pab flag field directly
: VOR!  ( c --)  [PAB FLG] TUCK VC@   OR SWAP VC! ;
: VAND! ( c --)  [PAB FLG] TUCK VC@  AND SWAP VC! ;

\ Primary access mode words must be used first
2 BASE !
: UPDATE  ( --) [PAB BL 0 VFILL   11111001 [PAB FLG] VC! ;
: INPUT   ( --) UPDATE 00000100  VOR! ;
: OUTPUT  ( --) UPDATE 00000010  VOR! ;
: APPEND  ( --) UPDATE 00000110  VOR! ;

\ TI-99 file access mode modifiers are used second
: DISPLAY    ( --) 11110111 VAND! ;
: SEQUENTIAL ( --) 11111110 VAND! ;
: RELATIVE   ( --) 00000001 VOR!  ;
: INTERNAL   ( --) 00001000 VOR!  ;

: VARI  ( size --) [PAB RECLEN] VC! 00010000 VOR!  ;
: FIXED ( size --) [PAB RECLEN] VC! 11101111 VAND! ;

DECIMAL
: DV80  ( -- ) UPDATE DISPLAY SEQUENTIAL 80 VARI ;
: DF128 ( -- ) UPDATE INTERNAL RELATIVE 128 FIXED ;

: OPEN   ( $addr len -- )
          [PAB FNAME] DUP           \ -- addr len Vaddr Vaddr
          32 + [PAB FBUFF] V!       \ FBUFF=32 bytes past fname
          VPLACE                    \ write string to [PAB FNAME]
          0 FILEOP ?FILERR ;        \ open the file, return err code

: READ   ( buffer -- buffer len ) 2 FILEOP ?FILERR  FGET ;
: WRITE  ( addr len --)
         DUP [PAB CHARS] VC!
         [PAB FBUFF] V@ SWAP VWRITE
         3 FILEOP ?FILERR ;

: EOF     ( -- c)    FSTAT 3 AND ;
: RECORD# ( -- rec#) [PAB REC#] V@  [PAB FLG] VC@ ?FILERR ;
: SEEK    ( rec# --) [PAB REC#] V!  4 FILEOP ?FILERR ;
: CLOSE   ( -- ) 1 FILEOP ?FILERR ;
: DELETE  ( caddr len -- ior) OPEN  7 FILEOP ?FILERR CLOSE ;
HERE SWAP - DECIMAL .

\ Usage:
 CREATE A$  80 ALLOT
 : SEEFILE ( addr len )
          #1 DV80 OPEN
          BEGIN
            A$ #1 READ CR TYPE
            #1 EOF
          UNTIL
          #1 CLOSE
 ;
