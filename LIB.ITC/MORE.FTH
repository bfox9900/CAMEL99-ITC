\ more.fth  simple file viewer  Brian Fox Jun 2020
\ default is DV80 files but you can change it with TI-99 file commands
\ Oct 2020: for kernel V2.63. New ?FILE ( caddr len -- caddr len)
\ Feb 2021: Fixed bug from Speccery, not printing last line of file
NEEDS OPEN-FILE  FROM DSK1.ANSFILES

HEX
\ : DV80    DISPLAY 50 VARI SEQUENTIAL ;  \ moved to ANSFILES

: MORE ( <filename>)
    BL PARSE-WORD ?FILE
    DV80 R/O OPEN-FILE ?FILERR >R
    BEGIN
      PAD DUP 50 R@ READ-LINE ?FILERR DROP
      CR TYPE
      KEY? BL =
      IF KEY DROP
      ELSE
         ?TERMINAL
         IF  R> CLOSE-FILE  2DROP CR ." ^C" ABORT
         THEN
      THEN
      R@ EOF
    UNTIL
    DROP
    R> CLOSE-FILE
;
