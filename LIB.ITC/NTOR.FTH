\ multiple rstack push and pop   for Camel99 Forth   Oct 2020

\ E.15.6.2.1908N>R
\ This implementation depends on the return address being on the return stack.
: N>R \ xn .. x1 N -- ; R: -- x1 .. xn n
\ Transfer N items and count to the return stack.
   DUP                        \ xn .. x1 N N --
   BEGIN
      DUP
   WHILE
      ROT R> SWAP >R >R      \ xn .. N N -- ; R: .. x1 --
      1-                      \ xn .. N 'N -- ; R: .. x1 --
   REPEAT
   DROP                       \ N -- ; R: x1 .. xn --
   R> SWAP >R >R
;
E.15.6.2.1940NR>
\ This implementation depends on the return address being on the return stack.
: NR> \ -- xn .. x1 N ; R: x1 .. xn N --
\ Pull N items and count off the return stack.
   R> R> SWAP >R DUP
   BEGIN
      DUP
   WHILE
      R> R> SWAP >R -ROT
      1-
   REPEAT
   DROP
;
