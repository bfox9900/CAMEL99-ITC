**********************

VDPWA  EQU  >8C02
VDWWD  EQU  >8C00
VDPRD  EQU  >8800
STATUS EQU  >837C
DSRLNK DATA DREGS,DSR1
HEX20  BYTE ' '
HEXAA  BYTE >AA
PERIOD BYTE '.'
       EVEN
SAVE1  DATA >0000
SAVE2  DATA >0000
SAVE3  DATA >0000
SAVE4  DATA >0000
SAVE5  DATA >0000
NAMBUF BSS  6      'SINCE WE KNOW WERE USING "DSKn."
*
H2000  DATA  >2000
CYC1   DATA  0
H1300  DATA  >1300

DSR1   MOV   *R14+,R5
       SZCB  @HEX20,R15
       MOV   @>8356,R0
       MOV   R0,R9
       AI    R9,>FFF8
       SWPB  R0
       MOVB  R0,@VDPWA
       SWPB  R0
       MOVB  R0,@VDPWA
       NOP
       MOVB  @VDPRD,R1
       MOVB  R1,R3
       SRL   R3,>8
       SETO  R4
       LI    R2,NAMBUF
DLOOP1 INC   R0
       INC   R4
       C     R4,R3
       JEQ   DJUMP1
       SWPB  R0
       MOVB  R0,@VDPWA
       SWPB  R0
       MOVB  R0,@VDPWA
       NOP
       MOVB  @VDPRD,R1
       MOVB  R1,*R2+
       CB    R1,@PERIOD
       JNE   DLOOP1
DJUMP1 MOV   R4,R4
       JEQ   DJUMP6
       CI    R4,>0007
       JGT   DJUMP6
       CLR   @>83D0
       MOV   R4,@>8354
       MOV   R4,@SAVE3
       INC   R4
       A     R4,@>8356
       MOV   @>8356,@SAVE4
SROM   LWPI  >83E0
       CLR   R1
       MOV   @H2000,@CYC1
       LI    R12,>1100
       JMP   DLOOP2
SROM1  LI    R12,>0F00
       MOV   @H1300,@CYC1

DLOOP2 MOV   R12,R12
       JEQ   DJUMP2
       SBZ   >00
DJUMP2 AI    R12,>0100
       CLR   @>83D0
       CI    R12,>2000
       JEQ   SROM1
       C     R12,@CYC1
       JEQ   DJUMP5
       MOV   R12,@>83D0
       SBO   >00
       LI    R2,>4000
       CB    *R2,@HEXAA
       JNE   DLOOP2
       A     @5*2+DREGS,R2
       JMP   DJUMP3
DLOOP3 MOV   @>83D2,R2
       SBO   >00
DJUMP3 MOV   *R2,R2
       JEQ   DLOOP2
       MOV   R2,@>83D2
       INCT  R2
       MOV   *R2+,R9
       MOVB  @>8355,R5
       JEQ   DJUMP4
       CB    R5,*R2+
       JNE   DLOOP3
       SRL   R5,>8
       LI    R6,NAMBUF
DLOOP4 CB    *R6+,*R2+
       JNE   DLOOP3
       DEC   R5
       JNE   DLOOP4
DJUMP4 INC   R1
       MOV   R1,@SAVE5
       MOV   R9,@SAVE2
       MOV   R12,@SAVE1
       BL    *R9
       JMP   DLOOP3
       SBZ   >00
       LWPI  DREGS
       MOV   R9,R0
       SWPB  R0
       MOVB  R0,@VDPWA
       SWPB  R0
       MOVB  R0,@VDPWA
       NOP
       MOVB  @VDPRD,R1
       SRL   R1,>D
       JNE   DJUMP7
       RTWP
DJUMP5 LWPI  DREGS
DJUMP6 CLR   R1
DJUMP7 SWPB  R1
       MOVB  R1,*R13
       SOCB  @HEX20,R15
       RTWP
