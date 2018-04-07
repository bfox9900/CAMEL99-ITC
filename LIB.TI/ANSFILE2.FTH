CR .( ANSFILES  FOR CAMEL99 V2 BJF 17MAR2018)

\ Requires CAMEL99 V2 with DSR support and simple file access
\ A subset of ANS Forth files wordset with TI-99 specific words

\ ANS/ISO Forth Definitions used in this code:
\         fid -  file identifier (a file handle)
\         ior -  input/output response (the error number)
\         fam -  file access mode. see code for details

HEX

3FFF 120 8* -  CONSTANT MAXPAB

VARIABLE LASTPAB

: ?HNDL  ( n -- ) DUP  MAXFILES > ABORT" too many files" ;

: FILES  ( n -- )   \ fill the PABS table with computed PABs
         ?HNDL
         PABS 24 0 FILL           \ clear PABS table
         3FFF ^PAB !              \ set ^PAB to top of VDP address
         DUP LASTHNDL !
         1+  1 MAX 1
         DO
           DSRPAB PAB SWAP I ]PABS 2!  \ allocate and put in buffs
         LOOP ;

: SELECT   ( hndl -- DSRPab)   \ sets the PAB POINTER, returns the DSRPab
           ]PABS 2@  ^PAB ! DSRNAM ! ;

\ get the next file handle, ABORT if none left to use
: NEWH   ( -- n ) HNDL DUP @ 1+  ?HNDL  TUCK SWAP !  ;

\ decrement hndl, limit to zero
: POPH    ( -- ) HNDL @ 1- 0 MAX HNDL ! ;

VARIABLE FAM  \ build the file access mode here

\ and/or the contents of a variable with mask
 : AND!   ( mask addr -- ) TUCK @ AND SWAP ! ;
 : OR!    ( mask addr -- ) TUCK @  OR SWAP ! ;

\ TI-99 file access mode modifiers
 2 BASE !  \        *ctrl bits*
 : DISPLAY    ( -- ) 11110111 FAM AND! ;
 : SEQUENTIAL ( -- ) 11111110 FAM AND! ;
 : RELATIVE   ( -- ) 00000001 FAM OR! ;

 : UPDATE     ( -- ) 11111001 FAM AND! ;
 : INPUT      ( -- ) 00000100 FAM OR! ;
 : OUTPUT     ( -- ) 00000010 FAM OR! ;
 : APPEND     ( -- ) 00000110 FAM OR! ;

VARIABLE B/REC    \ bytes per record
 : VARI  ( size -- fam) B/REC ! 00010000 FAM  OR! ;
 : FIXED ( size -- fam) B/REC ! 11101111 FAM AND! ;

HEX
CR .( TI FILE system commands
 : OPEN    ( -- ior)  0 FILEOP ;
 : CLOSE   ( -- ior)  1 FILEOP ;
 : READ    ( -- ior)  2 FILEOP ;
 : WRITE   ( -- ior)  3 FILEOP ;
 : REWIND  ( -- ior)  4 FILEOP ;
 : LOAD    ( -- ior)  5 FILEOP ;
 : SAVE    ( -- ior)  6 FILEOP ;
 : DELETE  ( -- ior)  7 FILEOP ;
 : SCRATCH ( -- ior)  8 FILEOP ;

 : FILE-STATUS  ( -- char) 9 FILEOP DROP  PAB 8 + VC@ ;

\ Abreviations for file formats are easy!
DECIMAL
 : DV80  ( -- ) INPUT DISPLAY 80 VARI SEQUENTIAL ;

\ ANS file access mode selectors default to DV80
\ change them with the TI-99 MODIFIER WORDS before OPEN-FILE
\ OR CREATE-FILE
 : R/W   ( -- fam)  UPDATE  FAM @ ;
 : R/O   ( -- fam)  INPUT   FAM @ ;
 : W/O   ( -- fam)  OUTPUT  FAM @ ;

 \ ANS Forth word replaces INTERNAL
 : BIN   ( fam -- fam') 8 OR ;  \ modify FAM on stack

 : OPEN-FILE ( caddr len fam -- fid ior)
             >R                      \ push file access mode
             NEWH SELECT             \ set new PAB address
             2DUP PAB _FNAME VPLACE  \ over-write PAB file name 
             R> PAB_FLG!             \ over-write default file mode

             TEMP @ ?DUP             \ test for new record length
             IF PAB _RECLEN VC!      \ yes, over-write the default
             THEN NEWFILE            \ setup new file
                  TEMP OFF           \ reset TEMP
                  OPEN               \ call O/S OPEN
           ( -- ior) HNDL @ SWAP ;

 : CREATE-FILE ( caddr len fam -- fid ior )
              R/W OPEN-FILE ;

 : CLOSE-FILE ( fid -- ?)
              DUP SELECT CLOSE SWAP POPH ;

\ nestable INCLUDED
 : INCLUDED  ( addr len -- )
            DV80 R/O OPEN-FILE ?FILERR
           ( - handle) (LD) DUP @ CLOSE-FILE ?FILERR
           ( srcid ) OFF ;

: INCLUDE  ( -- <text> )BL PARSE-NAME  INCLUDED ;

 : FILE-POSITION   ( -- n) PAB _REC# V@ ;
 : REPOSITION-FILE ( n --) PAB _REC# V! REWIND ;


 : READ-LINE ( c-addr u1 -- u2 flag ior )
            READ DUP >R                 \ rpush the error#
            0= IF
               PAB _FBUFF V@ -ROT VREAD \ move VDP fbuff to c-addr
               PAB _CHARS VC@           \ get actual chars read
               R@ 0=                    \ flag=true if no read error
            THEN R> ;


7 FILES
DECIMAL
CR .( Max files set to ) MAXFILES @ .


