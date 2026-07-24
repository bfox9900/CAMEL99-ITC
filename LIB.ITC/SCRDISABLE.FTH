\ disable screen by writing >A2 to VDP register 1

HEX
: SCREENOFF  A2 1 VWTR ;
: SCREENON   E2 1 VWTR ;

DECIMAL