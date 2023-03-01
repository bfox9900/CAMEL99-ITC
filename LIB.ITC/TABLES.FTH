\ TABLES.FTH access memory as fast arrays. For CPU or VDP RAM.  Brian Fox

\  CREATE Q  100 ALLOT
\  Q TABLE: ]Q
\  CHAR A 7 ]Q C!
\  7 ]Q C@ .

HEX
: TABLE: ( Vaddr -- ) \ byte table
     CREATE     ,              \ compile base address in RAM
     ;CODE ( n -- addr')       \ RUN time
         A118 ,  \ *W TOS ADD,  \ W holds the PFA of the word.
         NEXT,
     ENDCODE

: TABLE2: ( Vaddr -- )  \ create a table of 4 byte records
     CREATE    ,             \ compile base address into this word
     ;CODE ( n -- Vaddr')     \ RUN time
          0A14 ,  \ TOS 1 SLA,  ( tos = n x 2 )
          A118 ,  \ *W TOS ADD,
          NEXT,
     ENDCODE

: TABLE4: ( Vaddr -- )  \ create a table of 4 byte records
     CREATE    ,             \ compile base address into this word
     ;CODE ( n -- Vaddr')     \ RUN time
          0A24 ,  \ TOS 2 SLA,  ( tos = n x 4 )
          A118 ,  \ *W TOS ADD,
          NEXT,
     ENDCODE

: TABLE8: ( addr -- )    \ create a table of 8 byte records
     CREATE    ,
     ;CODE ( n -- Vaddr')     \ RUN time
          0A34 ,     \ TOS 3 SLA,  ( TOS 8* )
          A118 ,     \ *W TOS ADD,
          NEXT,
    ENDCODE
