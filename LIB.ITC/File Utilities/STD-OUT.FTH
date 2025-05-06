\ STD-OUT.FTH  experimental implementation  May 4 2025 Fox  
\ make a std-out device that emits to screen or to file.

NEEDS WRITE-FILE  FROM DSK1.ANSFILES
NEEDS VALUE       FROM DSK1.VALUES

HERE  
DECIMAL
\ This word is analogous to SOURCE-ID but for output 
0 VALUE  STD-OUT \ output file handle
                 \ 0 = screen 
                 \ n = file handle     

VARIABLE FOUT   \ total bytes sent to a file


: MAKE-OUTPUT ( a u -- hndl) \ *G creates a new output file
    DV80 W/O CREATE-FILE ?FILERR 
    FOUT OFF ;
 
: .OUT  ( -- ) FOUT @ U. ." bytes output"  FOUT OFF ; 

: OPEN-OUTPUT  ( a u -- hndl) 
    STD-OUT ABORT" Output file is already open"
    DV80 W/A OPEN-FILE ?FILERR  \ open output file in WRITE/APPEND mode
    FOUT OFF ;
 
: CLOSE-OUTPUT ( -- )
    STD-OUT CLOSE-FILE DROP   0 TO STD-OUT 
    .OUT ;

\ with VC@ V@ V@ V!  we can handle VDP RAM as easily as CPU RAM

: FLUSHLN ( handle -- ) 
    STD-OUT SELECT  3 FILEOP ?FILERR \ write to file 
    0 [PAB CHARS] VC! ;      \ mark buffer empty 

: VC+!  ( n Vaddr -- ) DUP>R VC@ + R> VC! ; \ inc VDP byte address

: >=  1- > ;

\ words to get information from the pab
: MAXLEN  ( -- c) [PAB RECLEN] VC@ ;
\ return bytes in buffer 
: LENGTH  ( -- n) [PAB CHARS] VC@ ;

\ return VDP address where next character goes. Use PAB field as index
: OUTBUFF ( -- Vaddr) [PAB FBUFF] V@  LENGTH + ;

: ?OUTOPEN  ( --) STD-OUT 0= ABORT" Output file not open" ;
: PAB-FULL? ( -- ?) LENGTH MAXLEN >= ; 
: ?FLUSH      PAB-FULL? IF  FLUSHLN   THEN  ;

\ primitive output 1 character to file 
: (FEMIT) ( char -- )
    ?FLUSH 
    OUTBUFF !  
    1 [PAB CHARS] VC+! 
    FOUT 1+! ;

: FEMIT ( c -- ) ?OUTOPEN  (FEMIT) ;

\ DV80 files need a single "blank" character for each empty line 
: FNEWLINE ( -- )  BL FEMIT FLUSHLN ;  

\ primitive: write string to file 
\ using (FEMIT) means the buffer automagically writes to file 
: (FTYPE) ( addr len -- )  0 DO  COUNT (FEMIT)  LOOP DROP ; 

: FTYPE ( caddr len -- ) \ if length=0 do a newline 
    ?OUTOPEN 
    LENGTH OVER + MAXLEN >= IF FLUSHLN THEN  \ if string can't fit 
    DUP IF  (FTYPE)  EXIT THEN 
    2DROP FNEWLINE ;

\ ---------------------------------
\ redefine output words to use STD-OUT 
: CR    ( -- )    STD-OUT IF FNEWLINE  ELSE CR    THEN ;
: EMIT  ( c --)   STD-OUT IF FEMIT     ELSE EMIT  THEN ;
: TYPE  ( a u --) STD-OUT IF FTYPE     ELSE TYPE  THEN ; 

HERE SWAP - DECIMAL CR . .( bytes )

\ USAGE: 
\ S" DSK6.TEXTFILE" MAKE-OUTPUT TO STD-OUT 