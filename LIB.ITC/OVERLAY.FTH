CR .( OVERLAY.FTH saves dictionary as binary images  Jun 2022 B Fox)
 \ creates a binary program E/A 5 format.

NEEDS LOCK      FROM DSK1.MARKER
NEEDS LOAD-FILE FROM DSK1.LOADSAVE  \ we use SAVE-FILE from this library

HERE
HEX
A000 CONSTANT 'ORG     \ start of Camel99 Forth program in CPU RAM
1000 CONSTANT VDPBUFF  \ Programs write to file from VDP Ram
2000 CONSTANT 8K
  13 CONSTANT PROG     \ file mode for Program files

\ define the file header fields. *THESE ARE VDP ADDRESSES*
VDPBUFF            CONSTANT MULTIFLAG
VDPBUFF  1 CELLS + CONSTANT PROGSIZE
VDPBUFF  2 CELLS + CONSTANT LOADADDR
VDPBUFF  3 CELLS + CONSTANT CODEORG     \ COPY 8K program chunks to here
           3 CELLS CONSTANT HEADLEN

: END  ( -- addr )
  ORGDP @ DUP C000 < IF HONK CR ." WARNING: missing LOCK directive" THEN ;

\ words to compute Forth system properties
: SYS-SIZE    ( -- n)  'ORG  END  SWAP - ;
: #FILES      ( -- n)  SYS-SIZE 8K /MOD SWAP IF 1+ THEN ;
: CODECHUNK   ( n -- addr) 8K *  'ORG + ;
: CHUNKSIZE   ( n -- n ) END SWAP CODECHUNK -  8K MIN ;
: LASTCHAR++  ( Caddr len --)  1- +  1 SWAP C+! ;

: ?PATH  ( addr len -- addr len )
         2DUP  [CHAR] . SCAN NIP 0= ABORT" Path expected" ;

HEX
: BSAVE ( -- <textpath> )
    BL PARSE-WORD ?PATH  ( caddr len ) PAD PLACE
    #FILES 0
    ?DO
      \ Init file header in VDP RAM
       I 1+ #FILES <>  MULTIFLAG V!
       I CHUNKSIZE     PROGSIZE V!
       I CODECHUNK     LOADADDR V!
      \ Copy to VDP & write to disk"
       CR ." Writing file "  PAD COUNT TYPE
       LOADADDR V@  CODEORG  PROGSIZE V@  HEADLEN + VWRITE
       PAD COUNT    VDPBUFF  PROGSIZE V@  HEADLEN + PROG SAVE-FILE
       PAD COUNT  LASTCHAR++   \ Update file name
    LOOP
    CR ." System size=" DECIMAL SYS-SIZE U. ." bytes"
    CR ." Saved in " #FILES .  ." EA5 files"
    CR
;

HERE SWAP - CR DECIMAL . .( bytes)
