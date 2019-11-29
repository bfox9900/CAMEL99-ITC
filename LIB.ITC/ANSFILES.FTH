\ ANSFILES  for CAMEL99 V2 BJF 02APR2018)
\ A subset of ANS Forth files wordset with TI-99 specific file control words
\ Apr 10, 2018 re-write for DSRLINK9 saves space.
\ Oct 13, 2019 changed ?FILERR to automatically release the current handle

\ Dependancy:
\ TI-99 file system is record oriented not byte oriented
\ therefore READ-FILE and WRITE-FILE are not part of this lexicon.

\ ANS/ISO Forth Definitions:
\  fid -  file identifier (a file handle)
\  ior -  input/output response (the error number)
\  fam -  file access mode. see code for details

\ O/S file system commands for reference (removed to save space)
\ : OPEN    ( -- ior)  0 FILEOP ;  : CLOSE   ( -- ior)  1 FILEOP ;
\ : READ    ( -- ior)  2 FILEOP ;  : WRITE   ( -- ior)  3 FILEOP ;
\ : REWIND  ( -- ior)  4 FILEOP ;  : LOAD    ( -- ior)  5 FILEOP ;
\ : SAVE    ( -- ior)  6 FILEOP ;  : DELETE  ( -- ior)  7 FILEOP ;
\ : SCRATCH ( -- ior)  8 FILEOP ;  : STATUS  ( -- stat) 9 FILEOP ;

HERE      \ for size calculation
.(  ..)
\ File handle server
HEX
VARIABLE #FILES
VARIABLE LASTH

\ File ID array holds VDP PAB address of an open file.
CREATE FIDS ( -- addr) 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ,

\ FIDS as an array
: ]FID   ( hndl -- PAB_addr ) CELLS FIDS + ;

\ compute the VDP address for any PAB(n)
: >PABADR   ( n -- VDPadr) PSZ * VDPTOP SWAP - ;

: NEWHNDL ( -- hndl) \ returns first free handle
         0           \ start at handle=0
         BEGIN
           1+
           DUP #FILES @ > ABORT" no free handle"
           DUP ]FID @    \ fetch pab table contents
         WHILE REPEAT    \ loop until we find an empty location
;

: NEWPAB ( hndl -- )
         DUP >PABADR  SWAP ]FID !    \ calc. PAB, record in FID array
;

: SELECT ( hndl -- )
        DUP 1 #FILES @ 1+ WITHIN  0= ABORT" Bad handle"
        DUP ]FID @ ^PAB !
        LASTH !
       ( [PAB FNAME] 8356 !)  \ DSRLNK9 does this now in FILEOP
;

: RELEASE ( hndl -- ) ]FID OFF  ;

\ *new* file error handler that releases handle
: ?FILERR  ( ior -- )
           ?DUP IF
              CR ." * File Err "  .
              LASTH @ RELEASE
              ABORT
           THEN ;

\ user level command.
: FILES   ( n -- )
          DUP 3 > ABORT" too many files"
          #FILES ! ;
.( ..)
\ ===================================
\ file access mode configuration

VARIABLE FAM  \ we build the file access mode in a variable

\ and/or the contents of a variable with mask
 : AND!   ( mask addr -- ) TUCK @ AND SWAP ! ;
 : OR!    ( mask addr -- ) TUCK @  OR SWAP ! ;

\ TI-99 file access mode modifiers
 2 BASE !  \        *ctrl bits*
 : DISPLAY    ( -- ) 11110111 FAM AND! ;
 : SEQUENTIAL ( -- ) 11111110 FAM AND! ;
 : RELATIVE   ( -- ) 00000001 FAM OR! ;

 : UPDATE     ( -- )        11111001 FAM AND! ;
 : INPUT      ( -- ) UPDATE 00000100 FAM OR! ;
 : OUTPUT     ( -- ) UPDATE 00000010 FAM OR! ;
 : APPEND     ( -- )        00000110 FAM OR! ;

VARIABLE B/REC    \ bytes per record
 : VARI  ( size -- fam) B/REC ! 00010000 FAM  OR! ;
 : FIXED ( size -- fam) B/REC ! 11101111 FAM AND! ;

\ set fam on stack to default file format
\ (in case the op forgets to set it up)
.( ..)
 HEX
\ These ANS word adjust and return the FAM variable
 : R/W   ( -- fam)  UPDATE  FAM @ ;
 : R/O   ( -- fam)  INPUT   FAM @ ;
 : W/O   ( -- fam)  OUTPUT  FAM @ ;

\ ANS Forth BIN replaces TI-99 "INTERNAL"
: BIN         ( fam -- fam') 8 OR ;  \ modify FAM to "INTERNAL"

\ system default to this file format
: DV80   ( -- ) UPDATE DISPLAY SEQUENTIAL 50 VARI ;

.( ..)
HEX
\ build the PAB from all the pieces, with error checking
: OPEN-FILE ( $addr len fam -- fid ior)
            ( fam) DUP FF00 AND OVER  0=  OR ABORT" Bad file mode"
             -ROT             \ tuck the FAM away for now
             DEPTH 3 < ABORT" OPEN-FILE args"
             NEWHNDL DUP >R          \ copy handle to Rstack
             DUP NEWPAB              \ compute the new PAB
           ( hndl) SELECT            \ select the pab
           ( fam $adr len) INITPAB
           ( fam) [PAB FLG] VC!      \ write file access mode to PAB
            B/REC @ [PAB RECLEN] VC! \ store reclen in PAB
            B/REC OFF                \ reset the B/REC variable
            0 FILEOP ( -- err#)      \ call O/S OPEN
            DUP                      \ test for error
            IF   R> RELEASE 0 SWAP   \ release hndl, return (0,ior)
            ELSE R> SWAP             \ return (fid,ior)
            THEN ;

: CLOSE-FILE ( fid -- ior) DUP SELECT  1 FILEOP  SWAP RELEASE ;
: EOF        ( fid -- c) SELECT (EOF) ;

.( ..)
\ F9 AND forces 'fam' bits to UPDATE mode
: CREATE-FILE     ( caddr len fam -- fid ior ) F9 AND  OPEN-FILE ;
: FILE-POSITION   ( fid -- rec# ior) SELECT  [PAB REC#] V@  [PAB FLG] VC@ ;
: REPOSITION-FILE ( rec# fid -- ior) SELECT  [PAB REC#] V!  4 FILEOP ;
: DELETE-FILE     ( caddr len -- ior) OPEN-FILE  7 FILEOP SWAP CLOSE-FILE OR ;

.( ..)
: READ-LINE ( c-addr u1 fid -- u2 flag ior )
            SELECT
            2 FILEOP DUP >R               \ read operation, rpush error#
            IF                            \ if err#<>0
               0 0 R>                     \ error, return err# only
            ELSE
               ( -- adr u1)
               [PAB CHARS] VC@            \ get no. chars actually read
               MIN >R                     \ MIN(u1,chars)= u2, rpush
               [PAB FBUFF] V@ SWAP R@ VREAD  \ move VDP fbuff to c-addr

               R>                         \ get u2 (chars actually read)
               (EOF) 0=                   \ test for EOF
               R>                         \ get error#.
            THEN ;

: WRITE-LINE ( c-addr u fileid -- ior )
             SELECT
             DUP [PAB CHARS] VC!        \ # chars to write ->PAB
             [PAB FBUFF] V@ SWAP VWRITE \ write CPU RAM to VDP file buffer
             3 FILEOP ( -- ior)         \ call write operation
;

\ ===================================
3 FILES             \ set the #FILES now
DECIMAL
CR .( Max files set to ) #FILES @ .
CR HERE SWAP - . .( bytes used)
HEX
