\ ANSFILES for Camel99 v2.1                 Brian Fox  Feb 2020
\ V2.24 removed file length and FAM=0 error test from OPEN-FILE
\ *G V2.25  Uses FOPEN to simplify OPEN-FILE, FREAD for READ-FILE
\ ** V2.26  Removed UPDATE INPUT OUTPUT APPEND. Use R/W R/O W/O W/A
\ ** Forced CREATE-FILE to erase previous file by using in W/O mode
CR .( ANS Files V2.27 Sept 2021..)
HEX
HERE

03 CONSTANT #FILES  \ ** this is locked at 3 in Camel99 Forth
VARIABLE LASTH      \ ** last handle that was selected ie:  CURRENT handle

CREATE FIDS ( -- addr) 0 , 0 , 0 , 0 , 0 , 0 ,
: FATAL   ( -- true)
          FIDS #FILES CELLS  0 FILL  \ erase all file IDs
          TRUE ;

: ?HNDL   ( n -- )  #FILES 1+ 1 WITHIN IF FATAL ABORT" Bad handle" THEN  ;
: ]FID    ( hndl -- PAB_addr ) DUP ?HNDL CELLS FIDS + ;

: NEWHNDL ( -- hndl) \ *G Handle server: Looks for available file handle.
  1  BEGIN  DUP ]FID @ WHILE  1+  REPEAT DUP ?HNDL ;

: RELEASE ( hndl -- ) ]FID OFF ;  \ *G release handle back to the pool
: SELECT  ( hndl -- )
\ *G make hndl the active PAB. Record as last handle in use
  DUP ]FID @  ^PAB !  LASTH  ! ;

: VCOUNT  ( vdp$adr -- vdpadr len )
\ *G COUNT for VDP strings
      DUP 1+ SWAP VC@ ;

: TYPE.VDP ( vdpaddr len -- ) BOUNDS ?DO  I VC@ EMIT  LOOP ;

: DUMP]   ( PABvaddr -- ) \ dump contents of a PAB
\ *G PAB dump utility used by ANSFILES error handler.
\ ** It can be expanded by uncommenting two lines in source code.
\ ** This will add REC# and file status fields to the output.
         DUP >R
         HEX
         CR ." PAB:" .  ." FAM=" R@ FLG] VC@ 1F AND .
\           ."  Rec#="   R@ REC#]  V@ .
\           ."  Fstat= " R@ STAT] VC@ .
         CR ." Dev:" R> FNAME] VCOUNT TYPE.VDP ;

: ?FILERR  ( ior -- )
\ *G Enhanced file error handler for use with ANS/ISO file words.
\ ** Runs [PAB DUMP] for displaying error no., file handle, flag status
\ ** and file name. See: DUMP]
       ?DUP IF
           CR
           CR ." Err# " .   ."  Hndl=" LASTH @ .
           [PAB DUMP]
           FATAL ABORT" Handles reset"
       THEN ;

.( ..)
VARIABLE FAM   \ ** file access mode is built in this variable

CODE AND!  ( mask addr -- addr)  \ *SP INV, *SP+ *TOS SZC, TOS POP,
    0556 ,  4536 ,  C136 ,  NEXT,  ENDCODE

CODE OR! ( mask addr -- addr)  \ *SP+ *TOS SOC,  TOS POP,
     E536 ,   C136 ,  NEXT, ENDCODE

\ TI-99 file access mode modifiers
 2 BASE !  \        *ctrl bits*
: DISPLAY    ( -- ) 11110111 FAM AND!  ; \ ** Same as BASIC ie: TEXT file
: SEQUENTIAL ( -- ) 11111110 FAM AND!  ; \ ** Same as BASIC
: RELATIVE   ( -- ) 00000001 FAM OR!   ; \ ** Same as BASIC

VARIABLE B/REC
: VARI  ( size -- fam) B/REC ! 00010000 FAM  OR! ;
\ *G Used to open or create a file with variable record size.

: FIXED ( size -- fam) B/REC ! 11101111 FAM AND! ;
\ *G Used to open or create a file with fixed record size.

: UPDT      ( -- fam)      11111001 FAM AND! ; \ set UPDATE Mode
\ : INPUT   ( -- fam) UPDT 00000100 FAM OR! ;
\ : OUTPUT  ( -- fam) UPDT 00000010 FAM OR! ;
\ : APPEND  ( -- fam) UPDT 00000110 FAM OR! ;

.( ..)
: R/W   ( -- fam)  UPDT FAM @ ;    \ ** TI UPDATE mode
: R/O   ( -- fam)  UPDT 00000100 FAM OR! FAM @ ; \ ** TI INPUT mode
: W/O   ( -- fam)  UPDT 00000010 FAM OR! FAM @ ; \ ** TI OUTPUT mode
: W/A   ( -- fam)  UPDT 00000110 FAM OR! FAM @ ; \ ** TI APPEND mode

HEX
\ ANS Forth BIN replaces TI-99 "INTERNAL"
: BIN   ( fam -- fam') 08 OR ;  \ ** TI INTERNAL file ie: binary file

DECIMAL
: DV80  ( -- )
\ *G Sets default TI-99 text file mode
  DISPLAY SEQUENTIAL 80 VARI ;
.( ..)
HEX
: OPEN-FILE ( $addr len fam -- fid ior)
\ *G ANS/ISO Forth compliant open-file. Requires error handler or ior
\ ** See: ?FILERR for simplest error handler
       DEPTH 3 < ABORT" OPEN-FILE args"
       B/REC @ SWAP ( -- $addr len b/rec fam)
       VDPTOP NEWHNDL DUP>R PSZ * -  \ new PAB = VDPTOP-(PABSIZE*HNDL)
       ( -- addr ) R@ ]FID !         \ store PAB in FID array
       R@ SELECT FOPEN               \ select handle & open
       B/REC OFF
       DUP ( -- ior ior )
       IF   R> RELEASE 0 SWAP
       ELSE R> SWAP
       THEN ;

.( ..)
: CLOSE-FILE      ( fid -- ior)
       DUP ]FID @ 0= ABORT" Hndl not open"
       DUP SELECT  1 FILEOP  SWAP RELEASE ;

: EOF             ( fid -- c) SELECT  FSTAT 3 AND ;
: CREATE-FILE     ( caddr len fam -- fid ior ) DROP W/O OPEN-FILE ;
: FILE-POSITION   ( fid -- rec# ior) SELECT  [PAB REC#] V@  [PAB FLG] VC@ ;
: REPOSITION-FILE ( rec# fid -- ior) SELECT  [PAB REC#] V!  4 FILEOP ;
: DELETE-FILE     ( caddr len fam -- ior)
  OPEN-FILE ?FILERR   7 FILEOP ?FILERR CLOSE-FILE  ;

.( ..)
: READ-LINE ( addr u1 fid -- u2 flag ior|0 )
\ *G Read one record into addr, expecting u1 bytes.
\ ** Return bytes read in U2, TRUE if data was recieved and error no,
  NIP              \ don't need u1 for TI file system
  SELECT 2 FILEOP ( addr ior)
  SWAP FGET ( -- ior u2)
  DUP 0= INVERT ROT ;

: WRITE-LINE ( caddr u fileid -- ior|0 ) \ ** zero means no errors
\ *G write string defined by caddr u to handle fileid. Return ior.
  SELECT
  DUP [PAB CHARS] VC!
  [PAB FBUFF] V@ SWAP VWRITE
  3 FILEOP ; ( -- ior)

\ =======================================
DECIMAL FATAL DROP
CR .( Max files set to ) #FILES .
CR HERE SWAP - U. .( bytes used)
HEX
