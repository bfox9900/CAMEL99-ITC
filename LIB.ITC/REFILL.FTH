\ REFILL.FTH   for files only          Dec 2021   Fox

\ When the input source is a text file, attempt to read the next line from the
\ text-input file. If successful, make the result the current input buffer, set
\ >IN to zero, and return true. Otherwise return false.

\ *NON* standard for Camel Forth
DECIMAL
: REFILL ( -- addr len ? ) \ len=0 means no input
      SOURCE-ID @
      IF
         2 FILEOP ?FILERR
         RP0 100 - DUP FGET  >IN OFF
      ELSE
         TIB DUP 120 ACCEPT
      THEN
      DUP 0 <>
;
