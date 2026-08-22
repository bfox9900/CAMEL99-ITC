CR
CR .( >> File deletion tool << )
CR
CR .( You must set the file access mode betore use)
CR
NEEDS OPEN-FILE  FROM DSK1.ANSFILES
NEEDS DIR  FROM DSK1.DIR
NEEDS MORE FROM DSK1.MORE

: DEL ( addr len)
    PARSE-NAME
    CR ." Permanently delete " 2DUP TYPE ."  ?: Y/N"
    KEY [CHAR] Y =
    IF
        FAM @ DELETE-FILE 7 <> ABORT" File deletion failed"
        EXIT
    THEN
    CR ." Deletion cancelled"
;

\ : MAKE-TESTFILE
\  DV80  S" DSK2.TESTFILE" W/O OPEN-FILE ?FILERR >R
\  S" This is a test file" R@ WRITE-LINE ?FILERR
\  S"  " R@ WRITE-LINE ?FILERR
\  R> CLOSE-FILE DROP
\ ;
