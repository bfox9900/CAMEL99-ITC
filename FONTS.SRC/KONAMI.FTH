\ Taken from TIME PILOT SOURCE CODE, translated for CAMEL99 FORTH
\ ***************************************************************
\ * KONAMI Game Font - from Konami's Athletic Land for MSX
\ * Letter A-Z
\ ****************************************************************
INCLUDE DSK1.DATABYTE
INCLUDE DSK1.GRAFIX

HEX
CREATE KONAMI
      BYTE  00,1C,36,63,63,7F,63,63    \     A
      BYTE  00,7E,63,63,7E,63,63,7E    \     B
      BYTE  00,3E,63,60,60,60,63,3E    \     C
      BYTE  00,7C,66,63,63,63,66,7C    \     D
      BYTE  00,7F,60,60,7E,60,60,7F    \     E
      BYTE  00,7F,60,60,7E,60,60,60    \     F
      BYTE  00,3E,63,60,67,63,63,3F    \     G
      BYTE  00,63,63,63,7F,63,63,63    \     H
      BYTE  00,3C,18,18,18,18,18,3C    \     I
      BYTE  00,1F,06,06,06,06,66,3C    \     J
      BYTE  00,63,66,6C,78,7C,6E,67    \     K
      BYTE  00,60,60,60,60,60,60,7F    \     L
      BYTE  00,63,77,7F,7F,6B,63,63    \     M
      BYTE  00,63,73,7B,7F,6F,67,63    \     N
      BYTE  00,3E,63,63,63,63,63,3E    \     O
      BYTE  00,7E,63,63,63,7E,60,60    \     P
      BYTE  00,3E,63,63,63,6F,66,3D    \     Q
      BYTE  00,7E,63,63,62,7C,66,63    \     R
      BYTE  00,3E,63,60,3E,03,63,3E    \     S
      BYTE  00,7E,18,18,18,18,18,18    \     T
      BYTE  00,63,63,63,63,63,63,3E    \     U
      BYTE  00,63,63,63,63,36,1C,08    \     V
      BYTE  00,63,63,6B,6B,7F,77,22    \     W
      BYTE  00,63,76,3C,1C,1E,37,63    \     X
      BYTE  00,66,66,7E,3C,18,18,18    \     Y
      BYTE  00,7F,07,0E,1C,38,70,7F    \     Z

\ ***************************************************************
\ * KONAMI Game Font - from Konami's Athletic Land for MSX
\ * Digits 0-9, SPACE and HYPHEN
\ ***************************************************************
CREATE KONAMI#
      BYTE  00,1C,22,63,63,63,22,1C    \     0
      BYTE  00,18,38,18,18,18,18,7E    \     1
      BYTE  00,3E,63,03,0E,3C,70,7F    \     2
      BYTE  00,3E,63,03,0E,03,63,3E    \     3
      BYTE  00,0E,1E,36,66,66,7F,06    \     4
      BYTE  00,7F,60,7E,63,03,63,3E    \     5
      BYTE  00,3E,63,60,7E,63,63,3E    \     6
      BYTE  00,7F,63,06,0C,18,18,18    \     7
      BYTE  00,3E,63,63,3E,63,63,3E    \     8
      BYTE  00,3E,63,63,3F,03,63,3E    \     9
      BYTE  00,00,00,00,00,00,00,00    \     SPACE
      BYTE  00,00,00,7E,00,00,00,00    \     -

DECIMAL
KONAMI   CHAR A ]PDT  26 8* VWRITE
KONAMI#  CHAR 0 ]PDT  12 8* VWRITE

: TEST
     PAGE ." WE HAVE KONAMI FONT"
     CR
     CR   ." FOR CAMEL99 FORTH"
     KEY DROP
;

INCLUDE DSK1.LOADSAVE
S" DSK3.KONAMI" SAVE-FONT
