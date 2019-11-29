\ vdp memory manager lexicon

\ VDP Memory Usage in Camel99 Forth when this file is loaded
\ |  VDP screen   |
\ + --------------|
\ |   RESERVED    |    sprites, patterns color tables
\ |               |
\ +---------------+  HEX 1000, VDP HEAP start
\ |    VHERE      |  VDP heap moves upwards
\ |      .        |
\ |      .        |
\ |      .        |
\ |      .        |
\ |               |
\ |               |
\ |               |
\ |   ^^^^^^^     |  move downwards
\ |  PAB stack    |  PABs start here
\ +---------------+ <-- VDPTOP returns this address
\ | 99 O/S space  |
\ |---------------|

INCLUDE DSK1.TOOLS

VARIABLE VP

HEX
1000 CONSTANT VDPSTART
2000 CONSTANT 8K

VDPSTART VP !   \ "VDP pointer" start of free VDP RAM

: VHERE   ( -- addr) VP @ ;   \ FETCH the value in VDP pointer
: VALLOT  ( n -- )   VP +! ;  \ add n to the value in VDP pointer
: VC,     ( n -- )   VHERE VC!  1 VALLOT ;
: V,      ( n -- )   VHERE V!   2 VALLOT ;
: VCOUNT  ( vdp$adr -- vdpadr len ) DUP 1+ SWAP VC@ ;
: VCREATE ( <text> -- ) VHERE CONSTANT  ; \ address when <text> invoked

HEX
\ Integrate VDP load/save because they need each other :-)

0B CONSTANT W/O100  \ WRITE ONLY, binary, relative, fixed 100
0D CONSTANT R/O100  \ READ ONLY,  binary, relative, fixed 100
13 CONSTANT PROG
: BIN         ( fam -- fam') 8 OR ;  \ modify FAM to "INTERNAL"

: NEWPAB   (  file$ len VDPaddr #bytes mode -- )
           -30 ^PAB +!         \ create new pab in VDP RAM below the current paB
           [PAB 30 0 VFILL     \ erase PAB and file name
        80 [PAB RECLEN] VC!   \ set reclen (0 means >100
\ pulls params from the stack to init the PAB
           [PAB FLG] VC!       \ set file access mode byte
           [PAB REC#]  V!      \ set #bytes to save (integer)
           [PAB FBUFF] V!      \ set where the file will load VDP Ram
           [PAB FNAME] VPLACE  \ set file name
;

: POPPAB  ( -- ) 30 ^PAB +! ;

: SAVE-FILE ( file$ len VDPaddr #bytes mode -- )
          NEWPAB  6 FILEOP ?FILERR  POPPAB ;

: LOAD-FILE ( file$ len VDPaddr #bytes mode -- )
          NEWPAB  5 FILEOP ?FILERR  POPPAB ;

: VDPUSED  ( -- addr len) VDPSTART  VHERE OVER -  DUP 8K > ABORT" VDP>8K" ;

: SAVE-VDP ( file$ len -- ) VDPUSED W/O100 SAVE-FILE ;

: LOAD-VDP ( file$ len -- ) VDPUSED 8K MAX R/O100 LOAD-FILE  ;

: LOAD-VDP2 ( file$ len -- ) VDPUSED DROP 2100 PROG BIN LOAD-FILE  ;

HEX

