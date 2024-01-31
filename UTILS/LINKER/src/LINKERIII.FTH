* VDP library code that interfaces to LINKERIII
* Original Code by mathew180  @atariage.com
 
* Camel99 Forth Environment 
* R0,R1,R2,R3 and R5 and R8 are free to use
* R4 is RESERVED as the top of stack cache register
* Return stack is maintained by R7
* DATA stack is maintained in R6
* DATA stack parameters can be popped into registers with:
*       MOV *R6+,Rx
 
*********************************************************************
* declare sub-routines for external use
        DEF  VSBW,VFILL,VMBW,VSBR,VMBR,VWTR
 
* VDP chip ports 
*
VDPRD  EQU  >8800             * VDP read data
VDPSTA EQU  >8802             * VDP status
VDPWD  EQU  >8C00             * VDP write data
VDPWA  EQU  >8C02             * VDP set read/write address
 
* Workspace
WRKSP  EQU  >8300             * Forth's Workspace
R0LB   EQU  WRKSP+1           * R0 low byte req'd for VDP routines
 
*********************************************************************
*
* VDP Single Byte Write
*
* R0   Write address in VDP RAM
* R1   MSB of R1 sent to VDP RAM
*
* R0 is modified, but can be restored with: ANDI R0,>3FFF
*
VSBW  MOVB @R0LB,@VDPWA      * Send low byte of VDP RAM write address
      ORI  R0,>4000          * Set read/write bits 14 and 15 to write (01)
      MOVB R0,@VDPWA         * Send high byte of VDP RAM write address
      MOVB R1,@VDPWD         * Write byte to VDP RAM
      B    *R11
*// VSBW
 
*********************************************************************
*
* VFILL VDP Single Byte Multiple Write
*
* R0   Starting write address in VDP RAM
* R1   MSB of R1 sent to VDP RAM
* R2   Number of times to write the MSB byte of R1 to VDP RAM
*
* R0 is modified, but can be restored with: ANDI R0,>3FFF
*
VFILL  MOVB @R0LB,@VDPWA      * Send low byte of VDP RAM write address
       ORI  R0,>4000          * Set read/write bits 14 and 15 to write (01)
       MOVB R0,@VDPWA         * Send high byte of VDP RAM write address
VFILLP MOVB R1,@VDPWD         * Write byte to VDP RAM
       DEC  R2                * Byte counter
       JNE  VFILLP            * Check if done
       B    *R11
*// VFILL
 
*********************************************************************
*
* VDP Multiple Byte Write
*
* R0   Starting write address in VDP RAM
* R1   Starting read address in CPU RAM
* R2   Number of bytes to send to the VDP RAM
*
* R0 is modified, but can be restored with: ANDI R0,>3FFF
*
VMBW   MOVB @R0LB,@VDPWA      * Send low byte of VDP RAM write address
        ORI  R0,>4000         * Set read/write bits 14 and 15 to write (01)
        MOVB R0,@VDPWA        * Send high byte of VDP RAM write address
VMBWLP MOVB *R1+,@VDPWD       * Write byte to VDP RAM
        DEC  R2               * Byte counter
        JNE  VMBWLP           * Check if done
        B    *R11
*// VMBW
 
*********************************************************************
*
* VDP Single Byte Read
*
* R0   Read address in VDP RAM
* R1   MSB of R1 set to byte from VDP RAM
*
VSBR  MOVB @R0LB,@VDPWA      * Send low byte of VDP RAM write address
      MOVB R0,@VDPWA         * Send high byte of VDP RAM write address
      MOVB @VDPRD,R1         * Read byte from VDP RAM
      B    *R11
*// VSBR
 
*********************************************************************
*
* VDP Multiple Byte Read
*
* R0   Starting read address in VDP RAM
* R1   Starting write address in CPU RAM
* R2   Number of bytes to read from VDP RAM
*
VMBR   MOVB @R0LB,@VDPWA     * Send low byte of VDP RAM write address
       MOVB R0,@VDPWA        * Send high byte of VDP RAM write address
VMBRLP MOVB @VDPRD,*R1+      * Read byte from VDP RAM
       DEC  R2               * Byte counter
       JNE  VMBRLP           * Check if finished
       B    *R11
*// VMBR
 
*********************************************************************
*
* VDP Write To Register
*
* R0 MSB    VDP register to write to
* R0 LSB    Value to write
*
VWTR  MOVB @R0LB,@VDPWA      * Send low byte (value) to write to VDP register
      ORI  R0,>8000          * Set up a VDP register write operation (10)
      MOVB R0,@VDPWA         * Send high byte (address) of VDP register
      B    *R11
*// VWTR
 
      END
 
