\ VSCAN.FTH Camel99 Forth. Like SCAN but for VDP memory   Mar 21 2012 Brian 

HEX
\ Find the VDP read address subroutine in the kernel. Cheeky shit this.
\ "carnal" knowledge :)
' VC@ 2 CELLS + @ CONSTANT VRMODE  

8800 CONSTANT VDPRD          \ vdp read-data port address

HEX 
CODE VSCAN
  C204 ,   06C8 ,  C036 , C136 , 06A0 ,
  VRMODE , 0203 , VDPRD , D093 , 9202 , 
  1304 ,   0584 ,  0600 , 1301 , 10F9 , 
  0646 ,   C584 ,  C100 , 0300 , 0002 , 
  NEXT,
ENDCODE

\ NEEDS MOV, FROM DSK1.ASM9900 

\ CODE VSCAN ( VDP-addr count char -- addr)
\ SETUP the input registers used by VSCAN 
\         TOS W MOV,
\            W SWPB,           \ W=char in correct byte order now
\            R0 POP,           \ R0=count
\           TOS POP,           \ pop VDPaddr to TOS  
\           
\        VRMODE @@ BL,         \ call subroutine to setup VDP READ address  
\ scan of VDP RAM            
\        R3 VDPRD LI,          \ vdp addr. in a reg. makes this 12.9% faster
\        BEGIN,      
\           R3 ** R2 MOVB,     \ read a byte from vdp ram, vdp auto-increments the address
\           R2 W CMPB,         \ compare byte to W 
\        NE WHILE,    
\           TOS INC,           \ TRACK the VDP address increments  
\           R0 DEC,            \ dec the loop count
\        NE WHILE, 
\        REPEAT,
\        ENDIF,  

\ return results to FORTH data stack 
\        TOS PUSH,
\        R0 TOS MOV, 
\        2 LIMI,               \ turn interrupts on again 
\        NEXT,
\ ENDCODE
DECIMAL 