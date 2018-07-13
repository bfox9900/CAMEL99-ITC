\ C O M P A R E
\ Based on SOD32 by L.C. Benschop
\ Copyright 2001 - 2005, Kirill Timofeev, kt97679@gmail.com
\ The program is released under the GNU General Public License version 2.

\ This is a beautiful example of difficult stack juggling but it works great BF
: COMPARE ( addr1 u1 addr2 u2 --- diff )
\ Compare two strings. diff is negative if addr1 u1 is smaller, 0 if it
\ is equal and positive if it is greater than addr2 u2.
                ROT 2DUP - >R                    \ compute U2-U1, push to RSTACK.
                MIN DUP
                IF
                    >R                           \ loop counter push to RSTACK
                    BEGIN
                       OVER C@ OVER C@ -
                       IF  SWAP C@ SWAP C@ -
                           2R> 2DROP             \ clean Rstack
                           EXIT                  \ & get out of this word
                       THEN
                       1+ SWAP 1+ SWAP           \ incr. addr2 & addr1
                       R> 1- DUP >R              \ get rstack loop counter, decr, copy, push back
                     0= UNTIL                    \ loop until loop counter=0
                    R>                           \ get the U2-U1 value
                THEN
                DROP 2DROP R> NEGATE ;
                

: A$   S" THIS IS A STRING" ;

: B$   S" AND THIS IS ANOTHER STRING" ;

B$ PAD PLACE

A$ B$ COMPARE .
B$ A$ COMPARE .
B$ PAD COUNT COMPARE .

