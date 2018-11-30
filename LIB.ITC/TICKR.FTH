\ RETURN STACK handy tools

\ The return stack is in memory but standard Forth gives us no access
\ to the memory directly. This means that maintaining a loop index on the
\ return stack is very inefficient.
\ Example: increment cell on top of return stack
\         R> 1+ >R   (very slow)
\
\ Assembler:   *RP INC,  (very fast)

