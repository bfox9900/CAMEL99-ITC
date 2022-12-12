CR .( SAVESYS.FTH  for CAMEL99 SUPERCART  EA5 program Jul 2022 B Fox)
\ creates a binary program E/A 5 format.
\ First section is a copy of the image in super-CART at >6000
\ Other sections begin at >A000
\ Makes as many files as needed to save the system

\ Usage example:
\  INCLUDE DSK2.MYPOGRAM   ( load all your code)
\  : COLDSTART     WARM   CR ." Myprogram ready"  ABORT" ;
\  LOCK   ( this locks the dictionary to this new )
\  INCLUDE DSK1.SAVESYS
\  ' COLDSTART SAVESYS DSK3.MYFILENAME

NEEDS DUMP      FROM DSK1.TOOLS
NEEDS LOCK      FROM DSK1.MARKER
NEEDS LOAD-FILE FROM DSK1.LOADSAVE  \ we use SAVE-FILE from this library

HERE
HEX
6000 CONSTANT 'SUPER   \ Address of the kernel segment in SUPER CART
A000 CONSTANT 'UPPER   \ start of Camel99 Forth program in CPU RAM
1000 CONSTANT VDPBUFF  \ Programs write to file from VDP Ram
2000 CONSTANT 8K
  13 CONSTANT PROG     \ file mode for Program files
3 CELLS  CONSTANT HEADLEN

\ define the file header fields. *THESE ARE VDP ADDRESSES*
VDPBUFF            CONSTANT MULTIFLAG
VDPBUFF  1 CELLS + CONSTANT PROGSIZE
VDPBUFF  2 CELLS + CONSTANT LOADADDR
VDPBUFF  HEADLEN + CONSTANT CODEORG  \ COPY 8K program chunks to here

: END  ( -- addr )
  ORGDP @ HERE OVER > IF HONK CR ." WARNING: missing LOCK directive" THEN ;

\ words to compute Forth system properties
: SYS-SIZE    ( -- n)  'UPPER  END  SWAP - ;
: #FILES      ( -- n)  SYS-SIZE 8K /MOD SWAP IF 1+ THEN ;
: CODECHUNK   ( n -- addr) 8K *  'UPPER + ;
: CHUNKSIZE   ( n -- n ) END SWAP CODECHUNK -  8K MIN ;
: LASTCHAR++  ( Caddr len --)  1- +  1 SWAP C+! ;

: ?PATH  ( addr len -- addr len )
         2DUP  [CHAR] . SCAN NIP 0= ABORT" Path expected" ;

: SAVE-PROG ( addr len -- )
  LOADADDR V@  CODEORG  PROGSIZE V@  HEADLEN + VWRITE  \ write RAM to VDP
  2DUP ( addr len)
  VDPBUFF  PROGSIZE V@  HEADLEN +  PROG SAVE-FILE \ save VDP to disk
( addr len) LASTCHAR++   \ Update file name
;

: SAVE1ST ( addr size  XT -- <textpath> )
       BOOT !
       PARSE-NAME ?PATH PAD PLACE
       CR ." Saving Super-Cart image "
     \ Init file header in VDP RAM
       0   MULTIFLAG V!
      1E00  PROGSIZE V!
      'SUPER LOADADDR V!
     \ Copy to VDP & write to disk"
      CR ." Writing file "  PAD COUNT TYPE
       LOADADDR V@  CODEORG  PROGSIZE V@  HEADLEN + VWRITE
       PAD COUNT    VDPBUFF  PROGSIZE V@  HEADLEN + PROG SAVE-FILE
       PAD COUNT  LASTCHAR++   \ Update file name
;

: REPORT.SYS ( -- )
    CR ." System size=" DECIMAL SYS-SIZE U. ." bytes"
    CR ." Saved in " #FILES .  ." EA5 files"
    CR
;

HEX
: SAVE-HIRAM ( n -- <textpath> )
     0
    ?DO
       FALSE       MULTIFLAG V!
      I CHUNKSIZE  PROGSIZE V!
      I CODECHUNK  LOADADDR V!
      CR ." Saving Upper RAM "
      PAD COUNT 2DUP TYPE SAVE-PROG
    LOOP
    REPORT.SYS
;

: SAVESUPER  ( XT -- <textpath>)
  'SUPER 8K SAVE1ST
  #FILES 1- SAVE-HIRAM
  REPORT.SYS ;

HERE SWAP - CR DECIMAL . .( bytes)

\ INCLUDE DSK1.WORDLISTS
\ VOCABULARY ASSEMBLER
\ ONLY FORTH ALSO ASSEMBLER DEFINITIONS
\ INCLUDE DSK1.ASM9900
\ INCLUDE DSK1.ASMLABELS

\ ONLY FORTH DEFINITIONS
\ INCLUDE DSK1.VPDMEM
\ INCLUDE DSK1.AUTOMOTION
\ INCLUDE DSK1.ELAPSE
\ INCLUDE DSK1.DIR
\ INCLUDE DSK1.CATALOG
\ INCLUDE DSK1.MORE
\ INCLUDE DSK1.RKEY
\ INCLUDE DSK1.STRINGS
\ INCLUDE DSK1.SAMS

\ 'UPPER ' COLD CHK HEX .  ( this number should be the same in the saved image)
: START    WARM ( INIT-WORDLISTS)  CR ." Kernel + tools" CR ABORT ;

LOCK

' START SAVESUPER DSK1.SUPERSAVE
