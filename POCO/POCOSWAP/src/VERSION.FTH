\ VERSION.FTH   requires CLASSIC99 emulator    Aug 2026  Brian Fox

: OPEN-CLOCK ( -- - hndl) S" CLOCK" DV80 R/O OPEN-FILE ?FILERR ;

: READ-CLOCK ( -- addr len) \ reads into PAD memory above dictionary
    OPEN-CLOCK >R
    PAD DUP 1+ 80 R@ READ-LINE ?FILERR DROP
    SWAP C!
    R> CLOSE-FILE DROP
    PAD COUNT ;

: DATE$  ( -- addr len) READ-CLOCK  2 /STRING  DROP 8 ;
