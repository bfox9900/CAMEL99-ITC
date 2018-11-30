\ easyfile.fth  simple text file access words

\ The ANS Forth wordset can be daunting to a BASIC programmer with the
\ requirement to do so many things manually. This word set attempts to
\ make a set of words that are more like BASIC. Although they are not
\ exactly the same they are easier to use.

NEEDS VALUE  FROM DSK1.VALUES.F
NEEDS R/W    FROM DSK1.ANSFILES.F

\ define 3 file identifiers. You can make more if you need to.
0 VALUE #1
0 VALUE #2
0 VALUE #3

\ create commands with error testing included by default
: OPEN    ( addr len -- fid) OPEN-FILE ?FILERR ;
: CLOSE   ( fid -- ) CLOSE-FILE ?FILERR ;

\ write a "stack string" to file fid
: WRITE   ( addr len fid -- ) WRITE-LINE ?FILERR ;

\ write a counted string from memory to file fid
: WRITE$   ( caddr fid -- ) >R COUNT R> WRITE ;

\ read entire record into a counted string
: LINPUT  ( caddr handle -- )
           >R DUP 1+ R> ( -- $ $+1 handle)
           SELECT                        \ select the correct PAB
           2 FILEOP ?FILERR              \ read operation, test error#
           [PAB FBUFF] V@  SWAP [PAB RECLEN] VC@  VREAD
           [PAB CHARS] VC@ SWAP C!       \ update string length
;
\ alias the word TO for use with OPEN
: AS:     ( n -- <value>) POSTPONE TO ; IMMEDIATE


