\  smarter wordlists

: LIST:
       CREATE ( addr --) DUP , {LEN} ,  \ compile address and length of list

       DOES>  ( n -- $)
             DUP >R
             CELL+ @ OVER U< ABORT" List index error"
             R> @ SWAP {NTH} {$} ;



   '{ " NOW" " IS" " THE" " TIME" " FOR" " ALL" } LIST: TEST
