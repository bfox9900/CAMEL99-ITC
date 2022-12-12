\ heapstrings.fth  loads dv80 into heap as strings Sept 2022 Brian Fox

\ This version compiles file data as counted strings in low RAM.
\ This is a fast way to seek to a line while having variable length data.

\ NEEDS .S   FROM DSK1.TOOLS ( transient assembler & tools )
\ NEEDS MOV. FROM DSK1.ASM9900
\ NEEDS ELAPSE FROM DSK1.ELAPSE
NEEDS READ-LINE FROM DSK1.ANSFILES

HERE

\ ===[ heap management ]====
\ low RAM is file buffer
HEX
2000 CONSTANT BUFFER  \ base address of the heap
2000 CONSTANT 8K      \ max size of the heap
BUFFER 8K +  CONSTANT BUFFEND

DECIMAL
\ variable H is our memory management pointer

: HALLOT ( n --)  \ WITH memory protection
  H  2DUP @ + BUFFEND BUFFER WITHIN ABORT" HEAP error"
  +! ;

: HEAP   H @ ;
: HC,   ( c --)  HEAP C!  1 HALLOT ;  \ compile c into heap

\ purge sets the heap to use addr and then erases it
: PURGE    ( addr len -- ) OVER H !  0 FILL   LINES OFF  ;

: FSIZE    ( -- n )  HEAP BUFFER - ;

\ : NEXT$    ( addr -- addr' ) COUNT + ;
HEX
CODE NEXT$ ( addr -- addr' )
     C044 , \   TOS R1 MOV,
     0584 , \      TOS INC,
     D051 , \ R1 ** R1 MOVB,
     0981 , \    R1  8 SRL,
     A101 , \   R1 TOS ADD,
     NEXT,
ENDCODE

: LEN      S" C@" EVALUATE ; IMMEDIATE  \ syntax sugar

: NTH ( addr n -- Caddr)  0 ?DO NEXT$ LOOP ; \ seek to nth line

DECIMAL
: V$,  ( Vaddr u -- ) \ compile VDP stack string as counted string in HEAP
      TUCK                \ tuck a copy of length under Vaddr
      DUP HC,             \ compile the length in heap
      HEAP SWAP VREAD     \ copy VRAM to RAM
      HALLOT ;            \ Allocate the heap space

: FDATA  ( -- Vaddr len ) [PAB FBUFF] V@  [PAB CHARS] VC@ ;

\ usage:  #1  S" DSK1.MYFILE" READ-FILE
: READ-FILE ( addr len -- )
        BUFFER 8K PURGE
        DV80 R/O OPEN-FILE ?FILERR >R
        LINES OFF
        BEGIN
           R@ SELECT 2 FILEOP 0= \ faster than ANS read-line
        WHILE
           FDATA V$,
           LINES 1+!
        REPEAT
        R> CLOSE-FILE DROP
;

: WRITELN ( addr len -- ior)
  DUP [PAB CHARS] VC!        \ set the record length
  [PAB FBUFF] V@ SWAP VWRITE \ write addr,len to Pab file buffer
  3 FILEOP ?FILERR ;         \ hit the system

\ usage:  #1 S" DSK1.MYFILE" WRITE-FILE
: WRITE-FILE ( addr len -- )
       DV80 W/O  OPEN-FILE ?FILERR >R
       BUFFER ( caddr )
       BEGIN
          DUP LEN
       WHILE
          DUP COUNT R@ WRITE-LINE ?FILERR
          NEXT$
       REPEAT
       DROP
       R> CLOSE-FILE DROP ;

DECIMAL HERE SWAP - CR . .( bytes)

\ test code
\ : TEST   TMR@   BUFFER 10 NTH TMR@ NIP - . ;
\ : PRINT ( $ -- ) COUNT ( C/L@ 1- MIN)  CR TYPE ;
\ : .HEAP ( -- ) BUFFER BEGIN  DUP LEN WHILE   DUP PRINT NEXT$   REPEAT ;
