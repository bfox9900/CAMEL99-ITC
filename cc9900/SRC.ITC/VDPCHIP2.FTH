\ vdp driver in Forth using a few optimizers

TARGET-COMPILING
\ VDP set-address sub-routines

\ ** NOTE **
\ R1 is set to the workspace address.
\ This is assumed to true in other VDP routines to access user variables
\ code primtitives used for efficiency
CODE 0LIMI  0 LIMI,  NEXT, ENDCODE
CODE 2LIMI  2 LIMI,  NEXT, ENDCODE

\ optimizers
CODE DUP>VDP ( 0c00 --0c00) \ Char must be in low byte
    TOS VDPWD @@ MOV,
    NEXT,
ENDCODE

CODE *DUP>VDP ( addr -- addr)
    *TOS+ VDPWD @@ MOVB,
    NEXT,
ENDCODE

CODE VDP>*TOS+ ( addr -- addr)
    VDPRD @@ *TOS+ MOVB,
    NEXT,
ENDCODE


: VDPRA! ( Vaddr -- ) 0LIMI  DUP  VDPWA C! >< VDPWA C! ;
: VDPWA! ( Vaddr -- ) 4000 OR VDPRA! ;

\ read & write to VDP data ports & auto-increment address
: VC@+   ( -- char)  VDPRD C@ ;
: VC!+   ( char --)  VDPWD C! ;

: VC@    ( VDPadr -- char) VDPRA! VC@+  2LIMI ;
: VC!   ( char VDPadr --)  VDPWA! VC!+  2LIMI ;

\ integer fetch/store. Used in Camel99 Forth for File I/O
: V@    ( VDPadr -- n) VDPRA! VC@+ ><  VC@+  2LIMI ;
: V!    ( n VDPadr --) VDPWA! >< SPLIT VC!+ VC!+  2LIMI ;

: VFILL ( Vaddr len char --)
    ><  -ROT     \ swap char byte and move to bottom
    SWAP VDPWA!  \ set write address
    0 DO
        DUP>VDP  \ 1 instruction
    LOOP
    DROP ;

: VWRITE ( addr Vaddr len --)
    SWAP VDPWA!
    0 DO
       *DUP>VDP  \ 1 instruction
    LOOP
    DROP
;

: VREAD  ( Vaddr addr len -- )
    ROT VDPRA!
    0 DO
        VDP>*TOS+
    LOOP
    DROP
;

: VWTR ( c reg --)
        FUSE
        0LIMI
        8000 OR VDPWA!
        2LIMI
;

: C/L@  C/L @ ;
