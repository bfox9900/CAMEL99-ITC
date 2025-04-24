\ OUTFILE.FTH   echo screen output to text file      May 2021  Brian Fox
\ updated Jan 2024 

\ Method: Write data directly into PAB file buffer
\ Use the PAB char count in the PAB as pointer into the PAB when we write.
\ ie: the buffer address= [PAB FBUFF] V@  + [PAB CHARS] VC@ 
\ Only write to disk when CR is encountered or if buffer will overflow.
\ No control characters allowed. Use spaces for DV80 files
\ Apr 2025. Corrected OVERFLOW to limit to 80 bytes/record 
\ changed >>OUT to OUT.TYPE 

\                   *** THIS VERSION WORKS **** 
NEEDS WRITE-FILE  FROM DSK1.ANSFILES
NEEDS VALUE       FROM DSK1.VALUES
 
DECIMAL
0 VALUE OUTH   \ output file handle
VARIABLE FOUT  \ byte counter for outfile 

: MAKE-OUTPUT ( a u -- ) \ *G creates a new output file
    DV80 W/O CREATE-FILE ?FILERR  TO OUTH 
    FOUT OFF ;
 
\ : W/A   APPEND FAM @ ;  \ Moved to DSK1.ANSFILES
: .OUT  ( -- ) FOUT @ U. ." bytes output"  ; 

: OPEN-OUTPUT  ( a u -- ) \ open output file in APPEND mode
    OUTH ABORT" Output file is already open"
    DV80 W/A OPEN-FILE ?FILERR  TO OUTH 
    FOUT OFF ;
 
: CLOSE-OUTPUT ( -- )
    OUTH CLOSE-FILE DROP   0 TO OUTH 
    .OUT ;
 
: WRITE-PAB ( handle -- ) SELECT  3 FILEOP ?FILERR ;

: [PABCHARS]+! ( n -- ) [PAB CHARS] VC@  +  [PAB CHARS] VC! ; 
: [OUTBUFF]    ( -- Vaddr) [PAB FBUFF] V@   [PAB CHARS] VC@ + ;

: FLUSH-BUFFER ( -- ) OUTH WRITE-PAB    0 [PAB CHARS] VC! ;
 
: >= ( n n -- ?)  1- > ;
: OVERFLOW?  ( n -- ?)  \ test n bytes will overflow buffer
    [PAB CHARS]  VC@ +  \ add n to chars in the buffer 
    [PAB RECLEN] VC@ >= \ compare to the maximum size 
;

: OUT.TYPE ( caddr len -- )
    OUTH 0= ABORT" Output file not open"
    OUTH SELECT 
    DUP OVERFLOW? IF  FLUSH-BUFFER  THEN 
    TUCK  ( -- len caddr len )         \ get a copy of the length
    [OUTBUFF] SWAP VWRITE              \ write string to PAB buffer
    ( len) DUP [PABCHARS]+!  FOUT +! ; \ update Char count
 
\ ==========================================
\ redefine standard output words to echo to file if output handle<>0
: EMIT  ( c --)   OUTH IF DUP HERE C!  HERE 1 OUT.TYPE  THEN EMIT ;
: TYPE  ( a u --) OUTH IF 2DUP  OUT.TYPE  THEN TYPE ;

: ."  (  ccc" -- )
    POSTPONE S" 
    STATE @ IF POSTPONE TYPE   EXIT   THEN TYPE ; IMMEDIATE

: SPACE   BL EMIT ;
: SPACES  ( n -- ) 0 MAX  0 ?DO  SPACE LOOP ;
 
: CR   ( -- )
    OUTH IF \ file is open
       [PAB CHARS] VC@  0= IF SPACE THEN FLUSH-BUFFER
    THEN CR  ;
 
\ number output with echo
: UD.  ( d -- ) <#  #S  #> TYPE SPACE ;
: U.   ( u -- ) 0 UD. ;
: .    ( n -- ) DUP ABS 0 <#  #S ROT SIGN  #> TYPE SPACE ;
 
