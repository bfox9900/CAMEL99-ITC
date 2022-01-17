\ From Neil Baud's toolbox
\ Changed to SPLIT$ to avoid conflct with SPLIT in kernel ( aabb -- bb aa)

\  SPLIT$  ( str len char -- str1 len1 str2 len2)
\     Divide a string at a given character. The first part of the
\     string is on top, the remaining part is underneath. The
\     remaining part begins with the scanned-for character.

INCLUDE DSK1.TOOLS
\ INCLUDE DSK1.3RD4TH                  \ 50% faster but 2X larger

: 3RD  ( a b c -- a b c a ) 2 PICK ;

: $SPLIT ( addr len char -- str1 len1 str2 len2)
         >R  2DUP  R> SCAN  2SWAP  3RD - ;

: /WORD ( addr len char -- aword len endstr len )
        $SPLIT 2SWAP 1 /STRING ;

: /WORDS  ( addr len -- addr len ... addr[n] len[n] )
         BL SKIP
         BEGIN  DUP 0>
         WHILE  BL /WORD
         REPEAT
         2DROP ;
