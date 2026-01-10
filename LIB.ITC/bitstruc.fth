\ bitstruc.fth

NEEDS BIT@ FROM DSK1.BOOLEAN

: BIT:  ( addr n ) CONSTANT ;

8 BITS: INT-CTRL
    0 BIT: LEVEL-0
    1 BIT: LEVEL-1
    2 BIT: LEVEL-2
    3 BIT: LEVEL-3
    4 BIT: LEVEL-4
    5 BIT: LEVEL-5
    6 BIT: LEVEL-6
    7 BIT: LEVEL-7

\ Usage: