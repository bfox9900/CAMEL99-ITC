\ filesys is a minimal single PAB file mechanism  BJF 17MAR2018
\  *** NEEDS DISKDSR.HSF


 HEX  

\ PAB location and size
\ 3EDF CONSTANT: PAB0    \ 1ST peripheral access block at top of VDP RAM
   20 CONSTANT PSIZE     \ size of a PAB in CAMEL99 Forth 32 bytes

\ VARIABLE: ^PAB


\ fast fetch of pab pointer
: PAB   ( -- adr) ^PAB @ ;

\  RAM<->VDP string transfers
: VPLACE   ( $addr len Vaddr -- ) 2DUP VC! 1+ SWAP VWRITE ;
: VGET     ( Vaddr len $addr -- ) 2DUP C!  1+ SWAP  VREAD ;

\ PAB fields:
\ these are 8 bytes smaller than Forth code & ASM is faster
: _FLG    ( addr -- addr')  1+   ;
: _FBUFF  ( addr -- addr')  2+   ;
: _RECLEN ( addr -- addr')  4 +  ;
: _CHARS  ( addr -- addr')  5 +  ;
: _REC#   ( addr -- addr')  6 +  ;
: _STAT   ( addr -- addr')  8 +  ;
: _FNAME  ( addr -- addr')  9 +  ;

 HEX
\ PAB FLAGS/STATUS field access words
\ : PAB_FLG!    ( c-- ) PAB _FLG VC! ;
\ : PAB_FLG@    ( -- c) PAB _FLG VC@ ;

: ERR@    ( -- n)  \ *NEW* combine GPL status and file err# into one 16bit number
          PAB _FLG VC@ 5 RSHIFT ;    \ shift error bits down

: FILEOP  ( opcode -- err)                  \ TI99 O/S call
          PAB VC!                           \ write opcode byte to VDP PAB
          PAB _FLG DUP VC@ 1F AND SWAP VC!  \ clear err code bits
          0 GPLSTAT C!                      \ clear GPL status register
          DISKON
          DSKLNK BLWP ERR@
          DISKOFF  ;

\ DSR error handlers
: ?CARDID  ( -- )      'ID C@ AA <> S" CARD not found" ?ABORT ;
: ?DEVERR  ( link -- ) 0= S" Device not found" ?ABORT ;
\ generic file error handler
: ?FILERR  ( ior -- ) ?DUP IF ."  File Err " .  ABORT THEN ;

\ MAKEPAB writes PAB directly to VDP ram 1 field at a time.
\ Returns address of filename at the first '.'  ex: .TEST
: MAKEPAB  ( addr len -- real-PAB-addr)
           PAB PSIZE 0 VFILL             \ erase the VDP PAB to be safe.
           PAB PSIZE +  PAB _FBUFF V!       \ set FBUFF 32 bytes past PAB
           14   PAB _FLG    VC!          \ default to: DISPLAY,VARIABLE
           50   PAB _RECLEN VC!          \ 80 bytes/record
           2DUP PAB _FNAME VPLACE        \ dup & write string to PAB
           /DOT NIP 1+ ( -- n)           \ compute offset upto '.' in string
           PAB _FNAME + ;                \ add offset to PAB _FNAME
                                         \ *this is the PAB address for the ROM code

\ : CELLS  2* ;
\ : CELL+  2+ ;

\ address navigation helpers.
: REG#    ( workspace R# -- addr)  2* + ;      \ COMPUTE address of R# in workspace
: >ENTRY  ( DSRlink -- entry_addr) 2+ @ ;      \ convert a LINK in ROM to code entry

: NEWFILE ( $addr len REALpab -- REALpab ) \  *STACK PICTURE*
         -ROT           ( -- REALpab $addr len )
         DiskON ?CARDID                           \ abort if card is not 'AA'
         DSRFIND         ( -- realpab link)
         DUP ?DEVERR                              \ ABORT if link=0
         DUP 4 +         ( -- link $)             \ link+4=DSR$ ie: the name of the DSR
             C@ 8355 C!                           \ len(DSR$) -> hex8355
                         ( -- link)
         >ENTRY  83E0 9 REG# !                    \  DSR code entry into GPL.R9
        ( -- realpab ) DUP 8356 !                 \ the "REAL" PAB file name stored here
;

\ return VDP buffer and characters read as a Forth stack string
: VDATA    ( -- vaddr len) PAB _FBUFF V@  PAB _CHARS VC@ ;

VARIABLE LDBUFF        \ hold File loading buffer. Set by COLD (startup)

\ ** HI LEVEL FUNCTIONS **

: FSTAT ( -- c) 9 FILEOP DROP PAB _STAT VC@ ; \ see E/A Manual page 298 for meaning

\ : EOF   ( -- ?) FSTAT 1 AND ;

\ READ until EOF
: REFILL ( -- flag )  \ flag=true if there is more data
            2 FileOp ?FILERR
            FSTAT 1 AND 0= ;

\ primitive file words to bootstrap the system on startup
: OPN    (  -- realpab )
            -120 ^PAB +!
            50 MALLOC LDBUFF !           \ get us a load buffer
            SOURCE 2DUP MAKEPAB ( -- $addr len realpab)
            NEWFILE ( realpab)
            0 FILEOP ?FILERR ;

: CLS    ( realpab -- )
           DUP U.
           8356 !                      \ set the REALPAB (FILE ID)
           1 FILEOP ?FILERR
           50 MFREE H @ LDBUFF !       \ release the buffer space, set to HEAP
\           120 ^PAB +!                \ pop back 1 pab on the pabstack
;


\ VARIABLE: LINES \ moved to main program

\ load file primitive. NOT re-entrant
: LD     ( -- ior)
            OPN ( -- realpab)
            BEGIN
              REFILL ( -- ? )
            WHILE
              VDATA  LDBUFF @ VGET      \ transfer VDP data to buffer
              LDBUFF @ COUNT INTERPRET   \ interpret the new string
              1 LINES +!
            REPEAT
            CLS
;

: .LOC ( -- )  LINES @ .  ." lines" ;  \ print lines of code compiled

\ This word bootstraps the system on startup.
\ FILESYS8 is nestable. Allocates a new PAB and LDBUFF
\ Typically: S" DSK1.START" FLOAD
: INCLUDED  ( caddr len -- )
           CR CR T." Loading: " 2DUP TYPE
           LINES OFF
           SOURCE 2>R  >IN @ >R        \ save input
          'SOURCE 2!                   \ file name becomes new source
           LD
           R> >IN !  2R> 'SOURCE 2!    \ restore input
           CR .LOC
           CR  ;

