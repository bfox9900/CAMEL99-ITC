\ ---------------------------------------------------------------------- 
\ compare: compare two files for equality
\ ---------------------------------------------------------------------- 

\ #include "st.h"
\ char arg1[MAXLINE], arg2[MAXLINE], line1[MAXLINE], line2[MAXLINE];

\ ---------------------------------------------------------------------- 
\ difmsg: print line numbers and differing lines
\ ---------------------------------------------------------------------- 
\ void difmsg(size_t lineno, const STR const line1, 
\    const STR const line2) {
\  io_putdec(lineno, 5);
\  PUTC(NEWLINE);
\  io_putlin(line1, stdout);
\  io_putlin(line2, stdout);
\ }
  
\ size_t m1, m2;

\MAIN (
\  if (args_getarg(1, arg1, MAXLINE) >= MAXLINE
\    || args_getarg(2, arg2, MAXLINE) >= MAXLINE)
\    error("usage: compare file1 file2.");
\  FILE *infil1 = io_open(arg1, READ);
\  if (infil1 == NULL)
\    io_cant(arg1);
\  FILE *infil2 = io_open(arg2, READ);
\  if (infil2 == NULL)
\    io_cant(arg2);
\  size_t lineno = 0;
\  REPEAT {
\    m1 = io_getlin(line1, infil1, MAXLINE);
\    m2 = io_getlin(line2, infil2, MAXLINE);
\    if (m1 >= MAXLINE || m2 >= MAXLINE)
\      break;
\    ++lineno;
\    if (str_equal(line1, line2) == NO)
\      difmsg(lineno, line1, line2);
\  }
\  if (m1 >= MAXLINE && m2 < MAXLINE)
\    remark("eof on file 1.");
\  else if (m2 >= MAXLINE && m1 < MAXLINE)
\    remark("eof on file 2.");

