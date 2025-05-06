\ ---------------------------------------------------------------------- 
\ charcount: count characters in standard output
\ ---------------------------------------------------------------------- 
\ MAIN (
\  int c;
\  int nc = 0;

\  while (GETC(c) != EOF)
\    ++nc;
\  io_putdec(nc, 1);
\  PUTC(NEWLINE);\

\  return 0;
\ )

\ CAMEL99 FORTH PORT 
INCLUDE DSK1.ANSFILES
INCLUDE DSK1.REFILL  

