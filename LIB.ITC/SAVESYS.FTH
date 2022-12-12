CR .( SAVESYS.FTH V2 creates EA5 program Dec 2022 B Fox)
\ creates a binary program E/A 5 format.
\ Makes as many files as needed to save the system
\ Jun 2022 version fixed section overlap. Tested with check sum.
\ Dec 2022 saves the HEAP (Low RAM) as a file if variable H <> 0

\ Usage example:
\  INCLUDE DSK2.MYPOGRAM   ( load all your code)
\  : STARTUP     WARM   CR ." Myprogram ready"  ABORT" ;
\  LOCK   ( this locks the dictionary to the current size )
\
\   INCLUDE DSK1.SAVESYS
\  ' STARTUP SAVESYS DSK3.MYFILENAME

\ NEEDS DUMP      FROM DSK1.TOOLS
NEEDS LOCK      FROM DSK1.MARKER
NEEDS LOAD-FILE FROM DSK1.LOADSAVE  \ we use SAVE-FILE from this library
NEEDS U.R       FROM DSK1.UDOTR

HERE
HEX
A000 CONSTANT HIMEM     \ start of Camel99 Forth program in CPU RAM
1000 CONSTANT VDPBUFF  \ Programs write to file from VDP Ram
2000 CONSTANT LOWRAM
2000 CONSTANT 8K
8K 3 CELLS - CONSTANT IMGSIZE \ makes space for header cells
  13 CONSTANT PROGRAM     \ file mode for Program files

\ define the file header fields. *THESE ARE VDP ADDRESSES*
VDPBUFF            CONSTANT MULTIFLAG
VDPBUFF  1 CELLS + CONSTANT PROGSIZE
VDPBUFF  2 CELLS + CONSTANT LOADADDR
VDPBUFF  3 CELLS + CONSTANT CODEBUFF  \ COPY 8K program chunks to here
         3 CELLS   CONSTANT HEADLEN

: HEADER  ( Vaddr size ?) \ store header info in VDP RAM
    MULTIFLAG V!  PROGSIZE V!  LOADADDR V! ;

: END  ( -- addr )
  ORGDP @ DUP C000 < IF HONK CR ." WARNING: missing LOCK directive" THEN ;

 \ words to compute Forth system properties
: SYS-SIZE    ( -- n)  HIMEM  END  SWAP - ;
: #FILES      ( -- n)  SYS-SIZE 8K /MOD SWAP IF 1+ THEN ;
: CODECHUNK   ( n -- addr) IMGSIZE * HIMEM + ;
: CHUNKSIZE   ( n -- n ) CODECHUNK END SWAP -  IMGSIZE MIN ;
: LASTCHAR++  ( Caddr len --)  1- +  1 SWAP C+! ;
: HEAPSIZE    ( -- n)  H @ LOWRAM - ;
: ?PATH  ( addr len -- addr len )
  2DUP  [CHAR] . SCAN NIP 0= ABORT" Path expected" ;

: GET-PATH    ( <text>) BL PARSE-WORD ?PATH  PAD PLACE ;

: FILENAME    ( -- addr len) PAD COUNT ;

VARIABLE FILECOUNT

: SAVE-IMAGE ( addr len Vaddr size -- )
    CR ." Writing file: " FILENAME TYPE
    HEADLEN +  PROGRAM SAVE-FILE
    FILENAME LASTCHAR++
    FILECOUNT 1+! ;

: SAVELO ( -- )
    HEAPSIZE
    IF
        LOWRAM HEAPSIZE DUP>R FALSE HEADER \ heap is last file saved
        LOWRAM CODEBUFF R@ VWRITE          \ copy HEAP to VDP
        FILENAME VDPBUFF R> SAVE-IMAGE
    THEN ;

HEX
: SAVEHI ( XT -- <textpath> )
    #FILES 0
    ?DO
      \ compute file header values
       I CODECHUNK  I CHUNKSIZE       ( -- addr size )
       I 1+ #FILES <>  HEAPSIZE 0> OR \ multiflag=true if heap has data
       ( addr size ?) HEADER          \ store in file header
      \ Copy to VDP RAM
       LOADADDR V@  CODEBUFF  PROGSIZE V@ HEADLEN +  VWRITE
      \ write VDP to disk"
       FILENAME   VDPBUFF   PROGSIZE V@  SAVE-IMAGE
    LOOP
;
: .BYTES&ADDR ( addr size --)
   DECIMAL 5 U.R ."  bytes, at " HEX ." >" 4 U.R ;

: REPORT
    CR
    CR ." Himem : "  HIMEM  ORGDP @ OVER -  .BYTES&ADDR
    CR ." Heap  : "  LOWRAM  HEAPSIZE  .BYTES&ADDR
    CR ." Saved in " FILECOUNT @ .  ." EA5 files"
    CR
;

: SAVESYS ( xt -- <path>)
    BOOT !
    FILECOUNT OFF
    GET-PATH  SAVEHI  SAVELO REPORT ;

HERE SWAP - CR DECIMAL . .( bytes)

\ ----------------
\  TEST CODE
INCLUDE DSK1.MALLOC

HEX 800 MALLOC CONSTANT MYBUFFER \ mybuffer is in Low RAM

MYBUFFER 800  CHAR $ FILL

: GO   WARM  ABORT ; \ minimum startup code to start Forth interpreter

LOCK                 \ lock dictionary to current size on re-boot

' GO SAVESYS DSK7.TESTKERNEL
