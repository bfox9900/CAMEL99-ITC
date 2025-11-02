\ 1STBIT.FTH
\ sourec: https://forth.sourceforge.net/algorithm/firstbit/index.html

\ explanation:
\ Let us consider the 1st set bit. On the first step, DUP 1 RSHIFT OR,
\ it gets copied to the bit that follows it. On the 2nd step, it gets
\ copies to the two bits that follow the two bits mentioned on the
\ previous step. And so on. Finally, all bits below the first set bit
\ become set.
\ Then, 1 RSHIFT XOR clears all set bits except the very 1st one.
DECIMAL
: FIRSTBIT ( number -- firstbit )
        DUP  1 RSHIFT OR
        DUP  2 RSHIFT OR
        DUP  4 RSHIFT OR
        DUP  8 RSHIFT OR
        DUP 16 RSHIFT OR
        DUP  1 RSHIFT XOR
;

NEEDS MOV, FROM DSK1.LOWTOOLS

\ tms9900 code version using machine Forth macros
: DUP,     TOS PUSH,  ;
: RSHIFT,  ( n --) TOS SWAP SRA, ;
: OR,      *SP+ TOS SOC, ;
: XOR,     *SP+ TOS XOR, ;

CODE 1STBIT ( n -- bit)
        DUP,   1 RSHIFT,  OR,
        DUP,   2 RSHIFT,  OR,
        DUP,   4 RSHIFT,  OR,
        DUP,   8 RSHIFT,  OR,
        DUP,  16 RSHIFT,  OR,
        DUP,   1 RSHIFT,  XOR,
        NEXT,
ENDCODE