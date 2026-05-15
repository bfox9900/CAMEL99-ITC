\ REFILL.FTH   for files only          Mar 2026   Fox

\ When the input source is a file, attempt to read the next line from the
\ text-input file. If successful, make the result the current input buffer,
\ set >IN to zero, and return true. Otherwise return false.

\ *NON* standard for Camel99 Forth
DECIMAL
: REFILL ( -- ?) \ len=0 means no input
  TIB DUP        \ read input into terminal input buffer
  SOURCE-ID @ 0>
  IF   2 FILEOP 0= >R   FGET ( addr len) R> AND \ AND length with error flag
  ELSE 80 ACCEPT ( addr len)
  THEN
  DUP  \ Test length
  IF
      'SOURCE 2!  >IN OFF
      TRUE
      EXIT
  THEN
  NIP  \ length was zero, remove the address
;
