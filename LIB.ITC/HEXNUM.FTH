\ From Neil Baud's toolbelt.

\  H#                           ( "hexnumber" -- n )
\     Get the next word in the input stream as an unsigned hex
\     single-number literal. (Adopted from Open Firmware.)
\
\     "The best way to manage BASE is to establish a global default,
\     e.g. DECIMAL. If you change to another, e.g. HEX, you assume
\     responsibility for changing back when you're done with it. The
\     scope of a changed region can be part of a file or all of a
\     file, but shouldn't span files. Always return to your default
\     at the end of a file _if_ you've changed it. This minimizes
\     fussy saving & restoring, and you always know where you are."
\     -- Elizabeth D. Rather

: H#  ( "hexnumber" -- u )  \  Simplified for easy porting.
    0 0 BL PARSE-WORD  ( -- 0 0 str len)  \ changed WORD to PARSE-WORD
    BASE @ >R  HEX  >NUMBER  R> BASE !
        ABORT" not Hex#" 2DROP ( -- u)
    STATE @ IF  POSTPONE LITERAL  THEN
    ; IMMEDIATE

\ Example:
\ DECIMAL                  \ BASE is now decimal
\ : TEST   H# 0FF AND ;    \ but we can use 0FF as a mask :-)