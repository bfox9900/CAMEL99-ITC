\ isr sound list player using TI-99 internal system
\ ASM Code courtesty Lee Stewart, Atariage

\ * load sound table CDATA into VDP RAM
\ BP    LI   R0,BUFFER         You do not need to CLR R0,R1,R2
\       LI   R1,CDATA          ...before loading them.
\       LI   R2,13
\       LIMI 0                 Disable interrupts while we mess with VRAM and sound setup.
\       BLWP @VMBW

\ * play the sound table
\       LI   R10,BUFFER
\       MOV  R10,@>83CC
\       SOCB @H01,@>83FD
\       MOVB @H01,@>83CE
\       LIMI 2                 Enable interrupts so sound table will be processed.

\ * wait until it's done
\ LOOP   MOVB @>83CE,@>83CE     Wait until sound table
\       JNE  LOOP              ...has finished.
\       LIMI 0
\       MOVB R0,@STATUS
\       RT


\ TI sound list player using VDP RAM   CAMEL99 Forth V2
\ ========================================================
INCLUDE DSK1.TOOLS
INCLUDE DSK1.ASM9900
INCLUDE DSK1.VDPMEM

\ interrupt control from Forth
CODE 0LIMI  0300 , 0000 , NEXT, ENDCODE
CODE 2LIMI  0300 , 0002 , NEXT, ENDCODE

\ turn off all sounds, (just in case)
HEX
: SILENT ( --)  9F SND!  BF SND!  DF SND! FF SND! ;

\ ========================================================
\ VDP byte string compiler
: ?BYTE ( n -- ) FF00 AND  ABORT" Not a byte" ;

: VBYTE ( -- )
         BEGIN
          [CHAR] , PARSE-WORD DUP
         WHILE
            EVALUATE DUP ?BYTE  VC,
         REPEAT
         2DROP ;

: /VEND   0 VC, 0 VC, ;   \ end the list with 2 bytes

HEX
: PLAYTBL ( vdpaddress --)
         0LIMI
         83CC !
         83FD C@ 1 OR 83FD C!
         1 83CE C!
         2LIMI
         BEGIN 83CE C@ 0= UNTIL
;


\ * play the sound table
CODE PLAYIT
        0 LIMI,
        TOS 83CC @@ MOV,  \  MOV  R10,@>83CC
        R1 0100 LI,
        R1 83FD @@ SOCB,
        R1 83CE @@ MOVB,
        2 LIMI,
\ * wait until it's done
        BEGIN,
           83CE @@ 83CE @@ MOVB, \ Wait until sound table
        EQ UNTIL,                \ ...has finished.
        0 LIMI,
        R0 837C @@ MOVB,         \ why R0?
        TOS POP,
        NEXT,
        ENDCODE

VCREATE NOKIA ( -- VDPaddress)
       VBYTE 01,9F,20
       VBYTE 03,90,85,05,09
       VBYTE 02,8F,05,09
       VBYTE 02,87,09,12
       VBYTE 02,87,08,12
       VBYTE 02,85,06,09
       VBYTE 02,81,07,09
       VBYTE 02,8E,0B,12
       VBYTE 02,8A,0A,12
       VBYTE 02,81,07,09
       VBYTE 02,8F,07,09
       VBYTE 02,8A,0C,12
       VBYTE 02,8A,0A,12
       VBYTE 02,8F,07,24
       VBYTE 01,9F,00
/VEND

