\ EXPERIMENTAL MACHINE FORTH PRIMITIVES

\ This macros are used to create CODE words that run at near hand coded speed
\ The biggest speed up is when used with structured assembler loops.
\ Forth loops is always 5X slower than native code loops

NEEDS  BEGIN,   FROM DSK1.ASM9900

 : CALL,     ( dst -- )   \ 6 bytes per call
              R11 RPUSH,       \ 28 save R11 on forth return stack
            ( addr) @@ BL,     \ 16   branch & link saves the PC in R11
;

: RET,        R11 RPOP,        \  6 bytes per return
              R11 ** B,
;

\ CALL/RET Overhead:   ITC vs STC on 9900
\                     -----------------------
\                      98     82   STC is 16% faster

\ but bigger code is generated.


\ ==========================================================================
CR .( M E M O R Y  F E T C H  &  S T O R E)

\ ** colon words ill be compiled inline unless  **
\ ** SUB: / END-SUB words create run-time code  **

: !,      ( n addr -- )
             *SP+ *TOS MOV,                        \ 20
              TOS POP,                             \ 22
              ;

: @,      ( a -- w )
             *TOS  TOS MOV,
             ;

: 2!,     ( d addr -- )
             *SP+ *TOS  MOV,    \ the top # of D is stored at the lower adrs
             *SP+ 2 (TOS) MOV,  \ next # stored 1 cell higher (addr+2)
              TOS POP,
              ;

: 2@,     ( addr -- d)
              2 (TOS) PUSH,         \ 36
             *TOS TOS MOV,          \ 28
              ;

: C!,       ( c addr -- )
             *SP+  W MOV,
              W SWPB,
              W *TOS MOVB,
              TOS POP,
              ;

: C@,      ( addr -- c )                         \ this is code for C@ interleaved with COUNT (saves 2 bytes)
            *TOS TOS MOVB,
             TOS 8 SRL,
             ;

: COUNT,  ( addr -- addr' u)
             TOS PUSH,                             \ make a copy of addr
             *SP INC,                              \ inc. past the count byte
             C@                                   \ compile code for C@ here
             ;

: +!,      ( n addr --)
             *SP+ *TOS ADD,                        \ 14+8+4 = 26 cycles
              TOS POP,                             \          22 cycles
              ;

: 1+!,      ( addr -- ) *TOS INC, ;
: 2+!,      ( addr -- ) *TOS INCT, ;
: 1-!,      ( addr -- ) *TOS DEC, ;
: 2-!,      ( addr -- ) *TOS DECT, ;


: @@?       ( var var -- ) \ compare 2 variables
             @@ SWAP @@ SWAP CMP, ;

\ ===================================================================
CR .( D A T A   S T A C K)

: SP@,     ( -- a )
              TOS PUSH,
              SP TOS MOV,
              ;

: SP!,     ( a -- )
              TOS SP MOV,
              TOS POP,
              ;

: DROP,    ( w -- )
              TOS POP,
              ;

: NIP,     ( n n' -- n')
              SP INCT,
              ;

: DUP,    ( w -- w w )
             TOS PUSH,
             ;

: OVER,      ( w1 w2 -- w1 w2 w1 )
              TOS PUSH,             \ 28
              2 (SP) TOS MOV,       \ 22
              ;

: SWAP,    ( w1 w2 -- w2 w1 )
              TOS   W MOV,          \ 14
             *SP  TOS MOV,          \ 18
              W   *SP MOV,          \ 18
              ;

: ROT    ( n1 n2 n3 --  n2 n3 n1)
              2 (SP)    W MOV,      \ move bottom n1 to TEMP             14+8 =   22
             *SP   2 (SP) MOV,      \ move n2 to bottom position         14+4+8 = 26
              TOS     *SP MOV,      \ n3 moves to second                 14+4   = 18
              W       TOS MOV,      \ n1 goes to top of stack register   14+0   = 14
              ;


: ><,      ( n -- n )            \ swap bytes in n
              TOS SWPB,             \ handy and only 1 instruction
              ;

: SPLIT,  ( AABB --  BB AA )     \ needed to create V!  VDP store integer
             TOS W MOV,             \ make a copy
             TOS 8 SRL,             \ slide 'AA' to the right
             W 00FF ANDI,           \ mask out AA from the copy
             W PUSH,
             ;

\ used in number conversion. Same size as DROP DROP Much faster as CODE
: 2DROP,   ( n n -- )
              SP INCT,
              TOS POP,
              ;

\ used 10x in the CAMEL Forth Kernel. Provides good speedup on some critical words
: 2DUP,   ( n1 n2 -- n1 n2 n1 n2 )
              *SP W MOV,           \ copy n1
              TOS PUSH,            \ copy n2 onto stack
              W PUSH,              \ push onto task
              ;

: 2SWAP   ( n1 n2 n3 n4-- n3 n4 n1 n2)
              TOS       R0 MOV,     \ n4  14
             *SP        R1 MOV,     \ n3  14
              2 (SP)   TOS MOV,     \ n2  22
              4 (SP)   *SP MOV,     \ n1  26
              R0    2 (SP) MOV,     \     22
              R1    4 (SP) MOV,     \     22
              ;

: 2OVER  ( d1 d2 -- d1 d2 d1)
             *SP W MOV,             \ d2 lsb -> temp                             18
              W   PUSH,             \ push temp                                  28
              TOS PUSH,             \ push d2 MSBits                             28
              4 (SP) TOS MOV,       \ pick 4th item, d1 MSBits to TOS            22
              6 (SP) *SP MOV,       \ pick 6th item, d1 LSBits to next on stack  26
              ;

: PICK   ( n -- n)             \ interesting: GForth ITC takes 10 intel instructions for PICK
              TOS W MOV,
              W 1 SLA,   \ 2*
              SP W ADD,
             *W TOS MOV,
              ;

\ ==========================================================================
CR .( R E T U R N   S T A C K)

: RP@,     ( -- a )
              TOS PUSH,
              RP TOS MOV,
              ;

: RP!,     ( a -- )
              TOS RP MOV,
              TOS POP,
              ;

: >R,      ( w -- )
              TOS RPUSH,            \ 28
              TOS POP,              \ 22
              ;              \ 50 vs 36 in TurboForth

: R>,      ( -- w )
              TOS PUSH,             \ 28
             *RP+ TOS MOV,          \ 22
              ;              \ 50 vs 36 in TurboForth


: R@,      ( -- w )
              TOS PUSH,
             *RP TOS MOV,
              ;

\ ==========================================================================
CR .( Shift right & left)

: RSHIFT  ( n bits -- n')
              TOS R0  MOV,            \ 14 the shift bits MUST be in R0 to do this
             *SP+ W   MOV,            \ 22
              W   R0 SRL,             \ x
              W   TOS MOV,            \ 14
              ;

: LSHIFT  ( n bits -- n')
               TOS R0 MOV,            \ the shift bits MUST be in R0 to do this
              *SP+ W  MOV,
               W  R0  SLA,
               W TOS  MOV,
               ;

\ ===================================================================
CR .( A R I T H M E T I C)
                                     \ All TOS in place math is 40% faster with TOS in register
: 1+,      ( n -- n)
              TOS INC,
              ;

: 1-,      ( n -- n)
              TOS DEC,
              ;

: 2+,      ( n -- n)
              TOS INCT,
              ;

: 2-,      ( n -- n)
              TOS DECT,
              ;

: 2*,      ( n -- n)
              TOS TOS ADD,             \ mpy instruction is 52 clocks minimum
              ;

: 2/,      ( n -- n)                \ div instruction is 52 clocks minimum
              TOS 1 SRA,
              ;

: INVERT,  ( w w -- w)
              TOS INV,
              ;

: UM+,    ( u u -- u cy )          \ or ( u u -- ud )
              W CLR,
             *SP TOS ADD,
              OC POSTPONE IF,
                 W INC,
              POSTPONE ENDIF,
              W *SP MOV,
              ;  IMMEDIATE

: +,       ( u1 u2 -- u )
             *SP+ TOS ADD,
              ;


: M+,      ( d n -- d )   \ add single to double
              TOS  2 (SP) ADD,
              OC POSTPONE IF,
               *SP INC,
              POSTPONE ENDIF,
              *SP+  TOS  MOV,
              ; IMMEDIATE


: UM*,     ( n n -- d)
             *SP  TOS MPY,
              R5  *SP MOV,
              ;

: *,      ( n n -- n)
             *SP+ TOS MPY,
              R5  TOS MOV,
              ;

: UM/MOD,  ( ud u1 -- u2 u3 )
             *SP+ R1 MOV,
             *SP  R2 MOV,
              TOS R1 DIV,
              R1 TOS MOV,
              R2 *SP MOV,
              ;





