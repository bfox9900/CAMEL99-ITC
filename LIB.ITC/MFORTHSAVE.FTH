\ MFORTHSAVE.FTH  save memory area as EA5 program   B Fox Dec 7 2020
HEX
     VARIABLE PROGSTART  \ start program in CPU RAM
     VARIABLE PROGEND    \ end of program. Set to HERE

1000 CONSTANT VDPBUFF  \ Programs write to file from VDP Ram
2000 CONSTANT 8K
  13 CONSTANT PROG     \ file mode for Program files

\ define the file header fields ***IN VDP RAM***
VDPBUFF            CONSTANT MULTIFLAG
VDPBUFF  1 CELLS + CONSTANT PROGSIZE
VDPBUFF  2 CELLS + CONSTANT LOADADDR
VDPBUFF  3 CELLS + CONSTANT CODEORG   \ COPY 8K program chunks to here

\ words to compute Forth system properties
: SYS-SIZE    ( -- n) PROGEND @ PROGSTART @ - ;
: #FILES      ( -- n)  SYS-SIZE 8K /MOD SWAP IF 1+ THEN ;

: CODECHUNK   ( n -- addr)
              DUP 8K * ( -- n addr)
              SWAP IF          \ if n <> 0 ie: 2nd, 3rd, chunks
                  3 CELLS  -  \ subtract header space
              THEN PROGSTART @ + ;

: CHUNKSIZE   ( n -- n )
              PROGEND @ SWAP CODECHUNK -    \ compute size
              3 CELLS +                \ add 6 bytes for header
              8K MIN  ;                \ take lesser of size or 8K

: LASTCHAR++  ( Caddr --) COUNT 1- +  1 SWAP C+! ;

: ?PATH    ( addr len -- addr len )
          2DUP  [CHAR] . SCAN NIP 0= ABORT" Path expected" ;
HEX
\ save a machine code program give start and end of program
: SAVEBIN ( source end -- <path> )
        2DUP > ABORT" START/END error"
        PROGEND !
        PROGSTART !
        BL PARSE-WORD  ?PATH  PAD PLACE
        #FILES 0
        ?DO
           CODEORG  8K 0 VFILL
           CR ." Writing file " PAD COUNT TYPE
          ( CR ." Init file header " I  . ." : " )
           I 1+ #FILES <> ( DUP U.)  MULTIFLAG V!
           I CHUNKSIZE    ( DUP U.)  PROGSIZE V!
\ IMPORTANT difference from SAVESYS. We must relocate the loadaddress
           I CODECHUNK DUP   RELOCATE  LOADADDR V!
          ( codechunk) CODEORG  PROGSIZE V@  VWRITE
           PAD COUNT   VDPBUFF  PROGSIZE V@  PROG SAVE-FILE
           PAD LASTCHAR++   \ Update file name
           CR
        LOOP
        CR ." Saved " DECIMAL SYS-SIZE U. ." bytes"
        CR ." in " #FILES .  ." EA5 files"
        CR
;

COMPILER:
: SAVE ( <path>)  CDATA THERE SAVEBIN ; \ saves CDATA program as EA5

\ save all of Camel99 system to EA5 program files
HOST:
: SAVESYS ( xt -- <path> )
    2000 ORIGIN.    \ forces relocation offset to be zero 2000-2000 = 0
    A000  HERE ROT BOOT !
    SAVEBIN ;
