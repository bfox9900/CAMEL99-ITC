\ OUTFILE.FTH   echo screen output to text file      May 2021  Brian Fox

\ Method: Write data into pab FILE buffer, keeping track of char count
\ Use the char count in the pab as Pointer into the Pab when we write
\ So data is written to [PAB FBUFF] V@ [PAB CHARS] VC@ +
\ Only write to disk when CR is encountered.
\ No control characters allowed. Use spaces for DV80 files

NEEDS WRITE-FILE  FROM DSK1.ANSFILES
NEEDS VALUE       FROM DSK1.VALUES

DECIMAL
0 VALUE OUTH   \ output file handle
: MAKE-OUTPUT ( a u -- ) \ *G creates a new output file
      DV80 W/O CREATE-FILE ?FILERR  TO OUTH ;

\ : W/A   APPEND FAM @ ;  \ Moved to DSK1.ANSFILES

: OPEN-OUTPUT  ( a u -- ) \ open output file in APPEND mode
      OUTH ABORT" Output file is already open"
      DV80 W/A OPEN-FILE ?FILERR  TO OUTH ;

: CLOSE-OUTPUT ( -- )
      OUTH CLOSE-FILE DROP   0 TO OUTH ;

: [PABCHARS]+! ( n -- ) \ bump the file buffer char count by n
      [PAB CHARS] VC@  +
      DUP [PAB RECLEN] VC@ > IF BEEP CR ." *WARNING: buffer overflow*" THEN
      80 MIN  [PAB CHARS] VC! ;  \ update the PAB, clip to 80 chars

: OUTBUFF ( -- Vaddr) [PAB FBUFF] V@ [PAB CHARS] VC@ + ;

: >>OUT ( caddr len -- )
       OUTH DUP 0= ABORT" Output file not open"
       SELECT
       TUCK  ( -- len caddr len )  \ get a copy of the length
       OUTBUFF SWAP VWRITE  \ write string to buffer
       ( len) DUP [PABCHARS]+! OUT +! ; \ update Char count
HEX
: FLUSH-BUFFER ( -- )
       3 FILEOP ?FILERR     \ write to disk
       0 [PAB CHARS] VC!    \ reset byte counter
      [PAB FBUFF] V@ 80 0 VFILL  \ erase buffer (debugging)
;

\ ==========================================
\ redefine standard output words to echo to file if output handle is active

: EMIT ( c --)
      DUP EMIT
      OUTH IF HERE C!  HERE 1 >>OUT   EXIT
      THEN DROP ;

: TYPE  ( a u --)
      2DUP TYPE
      OUTH IF  >>OUT EXIT
      THEN 2DROP ;

: SPACE   BL EMIT ;
: SPACES  ( n -- ) 0 MAX  0 ?DO  SPACE LOOP ;

: CR   ( -- )
      CR
      OUTH
      IF \ file is open
         OUT @ 0= IF  SPACE THEN FLUSH-BUFFER
      THEN OUT OFF ;

\ number output with echo
: UD.    ( d -- ) <#  #S  #> TYPE SPACE ;
: U.     ( u -- ) 0 UD. ;
: .      ( n -- ) DUP ABS 0 <#  #S ROT SIGN  #> TYPE SPACE ;
