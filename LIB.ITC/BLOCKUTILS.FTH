\ simple block editor words

: <LINE>  ( l# s# - addr #c )
        BLOCK  SWAP  C/L @ *  + 40  C/L @ ;

: .LINE   ( l# s# - )
        <LINE> -TRAILING  TYPE  #LINE 1+! ;

: LIST  ( s# - )
        CR
        DUP SCR ! ." SCR#"  U.
        10 0
         DO
             CR  I 3 .R SPACE   I SCR @ .LINE
         LOOP
         CR ;


: PP       0 TEXT PAD 1+ SWAP   scr @ <LINE> CMOVE UPDATE ;

: PL
        0D EMIT OUT 0!
        C/L @ SPACES
        0D EMIT
        [char] ? EMIT
        0D EMIT
        DUP SCR @ <LINE> PAD 2dup C! 1+ SWAP CMOVE <IN$>
        1+ SWAP scr @ <LINE> CMOVE UPDATE ;

: .INDEX   0 SWAP .LINE ;                              \      scr -

: CLEAR ( n -- )
        BUFFER B/BUF BLANK  UPDATE ;                \      scr -

: COPY  ( n -- )
        SAVE-BUFFERS    SWAP  BLOCK  2-  !  UPDATE ;   \  from to -

: THRU  ( 1st-block last-block -- )
        1+ SWAP
        DO
            I U. I LOAD
        LOOP ;

: CR'S  ( n -- )
        0 DO
             CR #LINE 1+!
          LOOP ;

: FORM-FEED
        0C EMIT  #PAGE 1+!   #LINE 0!  ;

: .PAGE#
        #PAGE @ IF ." page:" #PAGE @ 3 .R THEN ;

: .HEADER
        CR  ACTIVE $.
        TAB  TAB  TIME@ TIME->$ $. SPACE SPACE DATE@ DATE->$ $. ;

: .FOOTER
        CR  CR
        L/PAGE #LINE @ -  CR'S
        0F CTAB ." HS/FORTH V5.0" 10 SPACES ." Intelect Systems"
        CR 40 CTAB .PAGE#
        FORM-FEED ;

: ?FORMFEED  #LINE @  L/PAGE > IF .FOOTER .HEADER  THEN ;

: INDEX    ( from,to -- )
           DECIMAL
           HIGHBLK @ 1- MIN
           OVER L/PAGE / 1+ #PAGE !      \ calculate page# for 1st blk
           #LINE 0!
           .HEADER CR CR
           1+ SWAP
           DO  CR  I 4 .R  4 SPACES  I .INDEX  ?FORMFEED  1 /LOOP
          .FOOTER ;

: 3'S    3 / 3 * ;

: TRIAD  ( scr# -- )
        DECIMAL
        #PAGE 0! .HEADER
        3'S DUP 3 + SWAP
        DO CR I LIST LOOP
        .FOOTER ;

: TRIADS  ( from,to -- )
           3'S  1+ SWAP  3'S   DO  I TRIAD  3 +LOOP ;

: LISTING  0 HIGHBLK @ 2 - TRIADS ;

[then]


false [if]


: \     ( -- )
        source-id @ ABS 1-
        IF      [COMPILE] \
        ELSE    >IN @ 40 + -40 AND  >IN !
        THEN ;
        IMMEDIATE

: \S    ( -- )
        B/BUF >IN ! ; IMMEDIATE


\ ---- screen to file conversion
\ $" sourcef"   OPEN-BLOCKS                               To copy screens
\ $" dest-file" MAKE-OUTPUT                                      into a file
\                    OUTPUT @ scr#  BLOCKS->FILE          Do for each screen
\              CLOSE-OUTPUT         CLOSE-SCREEN

VARIABLE CTRL-Z  1A CTRL-Z !

: BLOCKS->FILE  ( n scr# -- )
        FIRST cell+ SWAP  RSCRNF                     \  >handle  scr# --
        LISTS @  SWAP                             \   >handle seg buf
        10 0
        DO
          2dup  40 -TRAILING ?DUP
          IF
             2dup + DUP>R DUP@ >R 0A0D SWAP !  cell+ DUP>R
             6 PICK WRITEH R> - ABORT" Write Failed"    DR> !
          ELSE  2drop
          THEN  40 +
        LOOP
        2drop LISTS @ CTRL-Z 1 4 PICK WRITEH DROP
        0 0 3 PICK LSEEK++ -1 -1 D+ ROT LSEEK 2drop ;

SF-IO  F-IO
\ ---- prompted screen to file conversion
: BLOCKS-TO-FILE ( -- )
        CR ." Source file for screens" IN$  OPEN-BLOCKS
        CR ." Append to old destination file? " ?YN
        CR ." Destination file" IN$ SWAP
        IF
            OPEN-OUTPUT -1 -1 OUTPUT @ LSEEK+  2drop
        ELSE
            MAKE-OUTPUT
        THEN
        BEGIN
          CR ." First screen to copy (0 to end)" #IN ?DUP
        WHILE
          ."  Last screen" #IN  2dup <=
          IF
              1+ SWAP
              DO
                  OUTPUT @ I BLOCKS->FILE
              LOOP
          THEN
        REPEAT
        CLOSE-OUTPUT CLOSE-BLOCKS ;
DECIMAL

[then]
