\ D I C T I O N A R Y   S E A R C H
TARGET-COMPILING

\ used to compute 4way hash of words for fast dictionary searches

HASHING [IF]
CODE HASH  ( string wid-pfa -- thread-addr )
         *SP+ R1 MOV,        \ Address of the STRING
          R1     INC,
         *R1  R1 MOVB,       \ fetch first character
          R1   8 SRA,        \ switch to other side
          R1  03 ANDI,       \ use to LSB bits
          R1  R1 ADD,        \ 2* to make a cell offset
          R1 TOS ADD,        \ addr to base PFA
          NEXT,              \ 16 bytes
          ENDCODE
[THEN]

 VARIABLE CONTEXT  [CC]  0 T, 0 T, 0 T, 0 T, 0 T, 0 T, 0 T, 0 T, [TC]
\ *G Array of Root + 8 wordlists to control search order

 VARIABLE CURRENT
\ ** wordlist where definitions will be added

: <FIND>  ( caddr --  caddr  0  if not found)
\                    xt    1  if immediate,
\                    xt   -1  if "normal"
            CONTEXT @ ( HASH) @ (FIND) ;

VARIABLE 'FIND   \ *G vector for the action of find

: FIND    'FIND PERFORM ;

: '        ( -- xt) BL WORD FIND 0= ?ERR ;
: [']      ( -- <name> ) ?COMP  '  T[COMPILE] LITERAL ; XIMMEDIATE

 : POSTPONE ( <name> -- ) \ *G replaces COMPILE and [COMPILE]
          ?COMP
          BL WORD FIND DUP 0= ?ERR
          0< IF   COMPILE COMPILE
          THEN  COMPILE, ;  XIMMEDIATE
