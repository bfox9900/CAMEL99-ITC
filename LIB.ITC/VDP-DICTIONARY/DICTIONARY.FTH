\ dictionary.fth  create linked list dictionaries in VDP RAM B Fox 2025
\ This code provides a way to make lookup tables of text in VDP RAM.
\ Using VDP RAM is slower but saves valuable program space if you
\ have large tables to store.

\ You can use the phrase FATAL ON or FATAL OFF to cottrol is duplicate
\ dictionary entry causes an ABORT or just a 'not unique' warning.

INCLUDE DSK1.TOOLS
INCLUDE DSK1.VDPMEM  \ primary VDP memory manager

HEX 0C00 VP !        \ safe to use in 40 column text mode
VP @ 2000 0 VFILL

\ Initialize a new thread in VDP space, give it a name
: DICTIONARY: ( -- )
    CREATE      \ create a variable in Forth dictionary
        VHERE , \ record the VDP 'HERE' in this variable
        0 V, ;  \ record a 0 integer in VDP ram at this address
                \ the 0 is the last link in the linked-list

HEX
: VALIGN    VP @ 1+ FFFE AND  VP ! ;

\ "place" string caddr/u in VDP memory as byte-counted string
: VS,  ( caddr u -- ) VHERE OVER 1+ VALLOT VPLACE VALIGN ;

\ Neil Baud's COMPARE modified to compare RAM string to VDP string
\  0 means adr1 = adr2
\ -1 means adr1 < adr2
\  1 means adr1 > adr2
DECIMAL
: VCOMPARE  ( addr u1 Vaddr u2 -- -1|0|1 )
    ROT  2DUP - >R            ( a1 a2 n2 n1) ( R: n2-n1)
    MIN                       ( a1 a2 n3)
    BOUNDS  ( loop index I becomes the VDP address)
    DO                        ( a1)
        COUNT  I VC@ -        ( a1 diff)
        DUP IF
            NIP 0< 1 OR       ( -1|1)
            UNLOOP
            R> DROP
            EXIT
        THEN                  ( a1 diff)
        DROP                  ( a1)
    LOOP
    DROP                      ( )
    R> DUP IF  0> 1 OR  THEN  \ 2's complement arithmetic
;

\ default "did" is dictionary ID so we can make multiple dictionaries
: LOOKUP ( addr len did -- nfa | 0) \ nfa is "name field address" in VDP RAM
    @ >R          \ save the wordlist identifier
    BEGIN
        R@      \ save NFA & test <>0
    WHILE
        2DUP R@ VCOUNT VCOMPARE
    WHILE ( compare<>0)
        R> NFA>LFA V@ >R  \ follow link in VDP push to rstack
    REPEAT
    THEN
    2DROP
    R> ;

VARIABLE FATAL   \ FATAL ON -or- FATAL OFF
: ?FATAL    ( ? -- ) ABORT" Duplicate dictionary entry" ;
: 3DUP      ( a b c -- a b c a b c ) >R 2DUP R@ -ROT R> ;
: -UNIQUE?  ( addr len did -- ?)
    3DUP LOOKUP  DUP FATAL @ AND ?FATAL  IF ." Not unique " THEN ;

: ADD$ ( addr len did --) \ compile string into dictionary(did)
    -UNIQUE?
    VALIGN
    DUP @ V,              \ get last NFA & compile in this LFA field
    -ROT                  ( did addr len -- ) \ move did to the bottom
    0 VC,                 \ compile an empty byte (immediate flag, type info)
    VHERE >R              \ save HERE (ie: new NFA location)
    VS,                   \ compile (addr len) as counted string
    R> SWAP !            \ VHERE is NFA of last word defined
;
