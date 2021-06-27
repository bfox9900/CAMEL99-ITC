\ SAVESYS.FTH  save Forth dictionary as EA5 program   B Fox Oct 2020
\ creates a binary program E/A 5 format.
\ Makes as many files as needed to save the system

\ typically load your include options first
\ INCLUDE DSK1.TOOLS
\ INCLUDE DSK1.SHELL
\ use LOCK  at the end of your program.
\ Then use:  ' MYBOOTWORD SAVESYS DSK?.MYFILENAME
\ Where MYBOOTWORD begins with WARM and ends with ABORT

MARKER /SAVESYS
NEEDS LOAD-FILE FROM DSK1.LOADSAVE  \ we use SAVE-FILE from this library

HEX
A000 CONSTANT 'ORG     \ start of Camel99 Forth program in CPU RAM
1000 CONSTANT VDPBUFF  \ Programs write to file from VDP Ram
2000 CONSTANT 8K
  13 CONSTANT PROG     \ file mode for Program files

\ define the file header fields *THESE ARE VDP ADDRESSES*
VDPBUFF            CONSTANT MULTIFLAG
VDPBUFF  1 CELLS + CONSTANT PROGSIZE
VDPBUFF  2 CELLS + CONSTANT LOADADDR
VDPBUFF  3 CELLS + CONSTANT CODEORG     \ COPY 8K program chunks to here

\ words to compute Forth system properties
: SYS-SIZE    ( -- n) 'ORG HERE SWAP - ;
: #FILES      ( -- n)  SYS-SIZE 8K /MOD SWAP IF 1+ THEN ;
: CODECHUNK   ( n -- addr)
              DUP 8K * ( -- n addr)
              SWAP IF          \ if n <> 0 ie: 2nd, 3rd, chunks
                  3 CELLS  -  \ subtract header space
              THEN 'ORG + ;

: CHUNKSIZE   ( n -- n )
              HERE SWAP CODECHUNK -    \ compute size
              3 CELLS +                \ add 6 bytes for header
              8K MIN  ;                \ take lesser of size or 8K

: LASTCHAR++  ( Caddr --) COUNT 1- +  1 SWAP C+! ;

: ?PATH  ( addr len -- addr len )
          2DUP  [CHAR] . SCAN NIP 0= ABORT" Path expected" ;
HEX
: OVERLAY ( XT -- <textpath> )
        BOOT !
        BL PARSE-WORD  ?PATH  PAD PLACE
        #FILES 0
        ?DO
          \ Init file header in VDP RAM
           I 1+ #FILES <>  MULTIFLAG V!
           I CHUNKSIZE     PROGSIZE V!
           I CODECHUNK     LOADADDR V!
         \ Copy to VDP & write to disk"
           CR ." Writing file " PAD COUNT TYPE
           CODEORG  8K 0 VFILL
           LOADADDR V@  CODEORG  PROGSIZE V@  VWRITE
           PAD COUNT  VDPBUFF PROGSIZE V@  PROG SAVE-FILE
           PAD LASTCHAR++   \ Update file name
        LOOP
        CR ." System size=" DECIMAL SYS-SIZE U. ." bytes"
        CR ." Saved in " #FILES .  ." EA5 files"
        CR
;

\ : LOAD-FILE ( file$ len VDPaddr count mode -- )
