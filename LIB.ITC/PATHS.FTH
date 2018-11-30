\ simple file path ( 1 disk deep)

\ Usage:
\  DSK2.
\  S" MYFILE"  +PATH  ( returns DSK2.MYFILE )

HEX
CREATE DEV$   10 ALLOT   \ holds the device string
CREATE PATH$  32 ALLOT   \ holds the path string

\ predefine some disk drives
: DSK1. ( -- ) S" DSK1." DEV$ PLACE ;
: DSK2. ( -- ) S" DSK2." DEV$ PLACE ;
: DSK3. ( -- ) S" DSK3." DEV$ PLACE ;

: +PLACE ( adr len adr -- ) \ appends adr len TO adr
          2DUP 2>R  COUNT +  SWAP CMOVE 2R> C+! ;

: ?DEV  ( caddr len -- ?) 
        DEV$ COUNT DUP 0= >R       \ test for empty string
        [CHAR] . SCAN NIP 0=  R>   \ test for '.' char
        OR ABORT" Bad DEV$"  ;     \ if either=true ABORT

: +PATH ( addr len -- addr' len')
         ?DEV
         PATH$ 32 0 FILL
         DEV$ COUNT PATH$ PLACE
         DUP 0A > ABORT" Name too long"
         PATH$ +PLACE
         PATH$ COUNT ;

