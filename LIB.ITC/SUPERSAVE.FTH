CR .( SUPERSAVE.FTH for SUPERCART Camel99 Forth  Nov2022 B Fox)
\ creates a binary program E/A 5 format.
\ Makes as many files as needed to save the system

\ For SUPERCART we must save the kernel at >6000 as the primary file.
\ IF the heap is used (H<>$2000) the HEAP is also saved.
\ ALL the memory from >A000 to end of dictioanry is saved as secondary files

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ nothing past here will be in the image.

NEEDS LOAD-FILE FROM DSK1.LOADSAVE  \ we use SAVE-FILE from this library

HERE
HEX
        A000 CONSTANT HIMEM
        1000 CONSTANT VDPBUFF
        2000 CONSTANT 8K
        2000 CONSTANT LOWRAM

          13 CONSTANT PROG     \ file mode for Program files
     3 CELLS CONSTANT HEADLEN
8K 3 CELLS - CONSTANT MAXSIZE

\ define the file header fields. *THESE ARE VDP ADDRESSES*
VDPBUFF            CONSTANT MULTIFLAG
VDPBUFF  1 CELLS + CONSTANT PROGSIZE
VDPBUFF  2 CELLS + CONSTANT LOADADDR
VDPBUFF  HEADLEN + CONSTANT CODEBUFF     \ COPY 8K program chunks to here

VARIABLE FILECOUNT

: ?LOCK
  ORGDP @ A100 <
  IF BEEP CR ." WARNING: missing LOCK directive" CR THEN ;

: ENDMEM  ( -- addr ) ?LOCK  ORGDP @ ;

\ words to compute the himmem parts of the system
: ?SIZE  DUP 8K > ABORT" Code to big" ;
: SYS-SIZE    ( -- n)  ENDMEM HIMEM - ;
: #FILES      ( -- n)  SYS-SIZE 8K /MOD SWAP IF 1+ THEN ;
: CODECHUNK   ( n -- addr) MAXSIZE * HIMEM + ;
: CHUNKSIZE   ( n -- n ) ENDMEM SWAP CODECHUNK -  MAXSIZE MIN ;

: ?PATH  ( addr len -- addr len )
         2DUP  [CHAR] . SCAN NIP 0= ABORT" Path expected" ;

CREATE FILE$ ( -- caddr) 20 ALLOT

: FILENAME   ( -- addr len) FILE$ COUNT ;
: LASTCHAR++ ( Caddr len --)  1- +  1 SWAP C+! ;

: SAVE-IMAGE ( addr len Vaddr size -- )
    CR ." Writing file: " FILENAME TYPE
    HEADLEN +  PROG SAVE-FILE
    FILENAME LASTCHAR++
    FILECOUNT 1+! ;

: HEADER  ( addr size ?) \ store header info in VDP RAM
    MULTIFLAG V!  PROGSIZE V!  LOADADDR V! ;

\ kernel ................
HEX
               6000 CONSTANT KERNORG
' ; 20 +  KERNORG - CONSTANT KERNSIZE \ last word in kernel is ';'

HEX
: SAVEKERNEL ( xt -- <textpath> )
    BOOT !
    PARSE-NAME ?PATH  FILE$ PLACE
    KERNORG KERNSIZE TRUE HEADER  ( Kernel always needs more files )
    KERNORG CODEBUFF KERNSIZE VWRITE \ copy kernel to VDP
    FILENAME VDPBUFF KERNSIZE SAVE-IMAGE
;

: HEAPSIZE ( -- n)  H @ LOWRAM - ;

: SAVEHEAP ( -- )
    HEAPSIZE
    IF
        LOWRAM HEAPSIZE DUP>R TRUE HEADER
        LOWRAM CODEBUFF R@ VWRITE        \ copy HEAP to VDP
        FILENAME VDPBUFF R> SAVE-IMAGE
    THEN ;

INCLUDE DSK1.UDOTR

: .BYTES&ADDR ( addr size --)
   DECIMAL 5 U.R ."  bytes, at " HEX ." >" 4 U.R ;

HEX
: REPORT
    CR
    CR ." Kernel: "  KERNORG  KERNSIZE .BYTES&ADDR
    CR ." Himem : "  HIMEM  ORGDP @ OVER -  .BYTES&ADDR
    CR ." Heap  : "  LOWRAM  HEAPSIZE  .BYTES&ADDR
    CR ." Saved in " FILECOUNT @ .  ." EA5 files"
    CR
;

: SAVEHIMEM ( -- <textpath> )
    #FILES 0
    ?DO
      \ Init file header in VDP RAM
       I CODECHUNK  I CHUNKSIZE  I 1+ #FILES <> HEADER
       LOADADDR V@  CODEBUFF  PROGSIZE V@ HEADLEN +  VWRITE
       FILENAME  VDPBUFF      PROGSIZE V@ SAVE-IMAGE
    LOOP
;

: SUPERSAVE ( xt -- <path>) SAVEKERNEL SAVEHEAP SAVEHIMEM  REPORT ;

HERE SWAP - DECIMAL . .( bytes)
