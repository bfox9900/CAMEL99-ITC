\ Ansfiles  for Camel99 v2.1 bjf  Feb 2020
\ V2.24 removed file length and FAM=0 error test from OPEN-FILE
\ v2.25  used new FOPEN to simplify OPEN-FILE, FREAD for READ-FILE
CR .( ANS Files V2.25 Mar 2021..)
HEX
HERE
03 CONSTANT #FILES  \ this is locked at 3 for now.
VARIABLE LASTH     \ last handle that was selected ie:  CURRENT handle

CREATE FIDS ( -- addr) 0 , 0 , 0 , 0 , 0 , 0 ,

: FATAL   ( -- true)
          FIDS #FILES CELLS  0 FILL  \ erase all file IDs
          TRUE ;

: ?HNDL   ( n -- )  #FILES 1+ 1 WITHIN IF FATAL ABORT" Bad handle" THEN  ;
: ]FID    ( hndl -- PAB_addr ) DUP ?HNDL  CELLS FIDS + ;

: NEWHNDL ( -- hndl) 0  BEGIN  1+ DUP ]FID @  WHILE REPEAT DUP ?HNDL ;

\ : NEWPAB  ( hndl -- ) DUP PSZ * VDPTOP SWAP - SWAP ( -- addr hndl) ]FID ! ;
: RELEASE ( hndl -- ) ]FID OFF ;
: SELECT  ( hndl -- ) DUP ]FID @  ^PAB !  LASTH  ! ;

: VCOUNT  ( vdp$adr -- vdpadr len ) DUP 1+ SWAP VC@ ;
: .FNAME  ( padaddr -- ) FNAME] VCOUNT 10 MAX BOUNDS DO  I VC@ EMIT LOOP ;

: DUMP]   ( vaddr -- ) \ dump contents of a PAB
         DUP >R
         HEX
         CR ." PAB:" .  ." FAM=" R@ FLG] VC@ 1F AND .
\           ."  Rec#="   R@ REC#]  V@ .
\           ."  Fstat= " R@ STAT] VC@ .
         CR ." Dev:" R> .FNAME ;

: ?FILERR  ( ior -- )
       ?DUP IF
           CR
           CR ." Err# " .   ."  Hndl=" LASTH @ .
           [PAB DUMP]
           FATAL ABORT" Handles reset"
       THEN ;

.( ..)
VARIABLE FAM
CODE AND!  ( mask addr -- )  \ *SP INV, *SP+ *TOS SZC, TOS POP,
    0556 ,   4536 ,  C136 ,  NEXT,  ENDCODE

CODE OR! ( mask addr -- )  \ *SP+ *TOS SOC,  TOS POP,
     E536 ,  C136 , NEXT, ENDCODE

\ TI-99 file access mode modifiers
 2 BASE !  \        *ctrl bits*
: DISPLAY    ( -- ) 11110111 FAM AND! ;
: SEQUENTIAL ( -- ) 11111110 FAM AND! ;
: RELATIVE   ( -- ) 00000001 FAM OR! ;

: UPDATE     ( -- )        11111001 FAM AND! ;
: INPUT      ( -- ) UPDATE 00000100 FAM OR! ;
: OUTPUT     ( -- ) UPDATE 00000010 FAM OR! ;
: APPEND     ( -- ) UPDATE 00000110 FAM OR! ;

VARIABLE B/REC
: VARI  ( size -- fam) B/REC ! 00010000 FAM  OR! ;
: FIXED ( size -- fam) B/REC ! 11101111 FAM AND! ;

.( ..)
 HEX
: R/W   ( -- fam)  UPDATE  FAM @ ;
: R/O   ( -- fam)  INPUT   FAM @ ;
: W/O   ( -- fam)  OUTPUT  FAM @ ;
: W/A   ( -- fam)  APPEND  FAM @ ;

\ ANS Forth BIN replaces TI-99 "INTERNAL"
: BIN   ( fam -- fam') 8 OR ;
DECIMAL
: DV80  ( -- ) UPDATE DISPLAY SEQUENTIAL 80 VARI ;
.( ..)
HEX
: OPEN-FILE ( $addr len fam -- fid ior)
       DEPTH 3 < ABORT" OPEN-FILE args"
       B/REC @ SWAP ( -- $addr len b/rec fam)
       VDPTOP NEWHNDL DUP>R PSZ * -  \ new PAB = VDPTOP-(PABSIZE*HNDL)
       ( -- addr ) R@ ]FID !         \ store handle in FID array
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

: EOF             ( fid -- c) SELECT (EOF) ;
: CREATE-FILE     ( caddr len fam -- fid ior ) F9 AND  OPEN-FILE ;
: FILE-POSITION   ( fid -- rec# ior) SELECT  [PAB REC#] V@  [PAB FLG] VC@ ;
: REPOSITION-FILE ( rec# fid -- ior) SELECT  [PAB REC#] V!  4 FILEOP ;
: DELETE-FILE     ( caddr len fam -- ior)
       OPEN-FILE ?FILERR   7 FILEOP ?FILERR CLOSE-FILE  ;

.( ..)
: READ-LINE ( addr u1 fid -- u2 flag ior )
       NIP SELECT 2 FILEOP ( addr ior)
       SWAP FGET ( -- ior u2)
       DUP 0= 0=  ROT ;

: WRITE-LINE ( c-addr u fileid -- ior )
       SELECT
       DUP [PAB CHARS] VC!
      [PAB FBUFF] V@ SWAP VWRITE
       3 FILEOP ; ( -- ior)

\ =======================================
DECIMAL
CR .( Max files set to ) #FILES .
CR HERE SWAP - . .( bytes used)
HEX
