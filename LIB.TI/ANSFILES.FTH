CR .( ANSFILES  for CAMEL99 V2 BJF 02APR2018)

\ Jun 21 2018, Added EOF with file handle
\ July 3, 2018 Added update to INPUT, OUTPUT to clear the respective fields
\ Requires CAMEL99 V2 with DISKDSR4 and FILESYSD

\ A subset of ANS Forth files wordset with TI-99 specific file control words

\ Dependancy:
\ TI-99 file system is record oriented not byte oriented
\ therefore READ-FILE and WRITE-FILE are part of this lexicon.

\ ANS/ISO Forth Definitions used in this code:
\         fid -  file identifier (a file handle)
\         ior -  input/output response (the error number)
\         fam -  file access mode. see code for details

\ O/S file system commands for reference (removed to save space)
\ : OPEN    ( -- ior)  0 FILEOP ;
\ : CLOSE   ( -- ior)  1 FILEOP ;
\ : READ    ( -- ior)  2 FILEOP ;
\ : WRITE   ( -- ior)  3 FILEOP ;
\ : REWIND  ( -- ior)  4 FILEOP ;
\ : LOAD    ( -- ior)  5 FILEOP ;
\ : SAVE    ( -- ior)  6 FILEOP ;
\ : DELETE  ( -- ior)  7 FILEOP ;
\ : SCRATCH ( -- ior)  8 FILEOP ;

 INCLUDE DSK1.TOOLS.F   \ for debugging

CR .( ..)
\ File handle server
HEX
VARIABLE #FILES

8370 CONSTANT VDPEND     \ TI O/S variable, points to last usable VDP address

CREATE PABS ( -- addr)   \ table for 8 potential PABs
             0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ,

\ ]PTAB exposes PABS as an array
: ]PTAB   ( n -- addr )  2* PABS + ;

\ compute the VDP address for any PAB(n)
: PAB[n]  ( n -- VDPadr) 120 * VDPEND @ SWAP - ;

: ?FILES  ( n -- ) #FILES @ > ABORT" no more handles" ;

: NEWHNDL ( -- hndl) \ returns first free handle
         0           \ start at handle=0
         BEGIN
           1+
           DUP ?FILES    \ have we exceeded #files allowed
           DUP ]PTAB @   \ fetch pab table contents
         0= UNTIL ;      \ loop until we find an empty location

\ the file handle selects the active PAB
: SELECT  ( hndl -- )
           DUP ?FILES
           ]PTAB @ DUP 0= ABORT" Cannot select hndl 0"
           ^PAB !        \ set the pab pointer to PTAB(hndl)
           [PAB DSRNAM] V@  DSRNAM !  ;

: NEWPAB  ( hndl -- ) \ assign a new PAB and SELECT it.
          DUP DUP PAB[n] SWAP ]PTAB !  ( hndl) SELECT ;

: RELEASE ( hndl -- ) ]PTAB OFF ;

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

\ ANS Forth word replaces INTERNAL
 : BIN   ( fam -- fam') 8 OR ;  \ modify FAM to set INTERNAL flag

: DV80   ( -- ) UPDATE DISPLAY SEQUENTIAL 50 VARI ;
.( ..)
HEX
\ build the PAB from all the pieces, with error checking
: OPEN-FILE ( $addr len fam -- fid ior)
             SP0 SP@ 2+ - 2/          \ calulate stack DEPTH manually
             3 < ABORT" OPEN-FILE args"
             NEWHNDL DUP >R NEWPAB    \ copy handle & assign PAB
             [PAB BL 0 VFILL          \ BL= >20 erase the VDP PAB

             ?DUP 0=                  \ is FAM 0
             IF     DV80 FAM @
             THEN  [PAB FLG] VC!      \ write file access mode

             B/REC @ ?DUP 0=          \ test for new record length
             IF  50                   \ if not default to 80 bytes (>50)
             THEN [PAB RECLEN] VC!    \ store reclen in PAB
                  B/REC OFF           \ reset the B/REC variable

             2DUP  MAKEPAB ( --  $adr len )
             DSKCARD OPENDEV          \ open device DSR on card
             0 FILEOP ( -- err#)      \ call O/S OPEN
             DUP                      \ test for error
             IF   R> RELEASE 0 SWAP   \ release hndl. return 0
             ELSE R> SWAP             \ return handle, 0
             THEN ;

: CLOSE-FILE ( fid -- ?)
             DUP SELECT  1 FILEOP SWAP  RELEASE ;

\ (EOF) is a bit faster
: (EOF)     ( -- ? ) FSTAT 3 AND ;       \ EOF of currently OPEN file

: EOF       ( fid -- ? ) SELECT (EOF) ;  \ EOF of fid file

: READ-LINE ( c-addr u1 fid -- u2 flag ior )
            SELECT
            2 FILEOP DUP >R               \ read operation, rpush error#
            IF                            \ if err#<>0
               0 FSTAT  R>                \ fatal error, don't read data
            ELSE
               ( -- adr u1)
               [PAB CHARS] VC@             \ get no. chars actually read
               MIN  >R                     \ MIN(u1,chars)= u2, rpush
               [PAB FBUFF] V@ SWAP R@ VREAD   \ move VDP fbuff to c-addr
               R>                         \ get u2 (chars actually read)
               (EOF) 0=                   \ TRUE if EOF = 0
               R>                         \ bring back error#
            THEN ;

: WRITE-LINE ( c-addr u fileid -- ior )
             SELECT
             DUP [PAB CHARS] VC!        \ # chars to write ->PAB
             [PAB FBUFF] V@ SWAP VWRITE \ write CPU RAM to VDP file buffer
             3 FILEOP ( -- ior)         \ call write operation
            \ (EOF) FUSE                \ fuse EOF and general file errors
;
.( ..)
: CREATE-FILE ( caddr len fam -- fid ior )
\ update mode forces new file creation in TI-99 O/S
               F9 AND        \ force 'fam' bits to UPDATE mode
               OPEN-FILE ;

: FILE-POSITION   ( fid -- rec# ior) SELECT  [PAB REC#] V@ ERR@ ;
: REPOSITION-FILE ( rec# fid -- ior) SELECT  [PAB REC#] V! 4 FILEOP ;

: DELETE-FILE     ( caddr len -- ior ) R/W OPEN-FILE ?FILERR 7 FILEOP  ;

\ ===================================
3 FILES             \ set the #FILES now

DECIMAL

CR .( Max files set to ) #FILES @ .
( About 1080 bytes)
HEX


