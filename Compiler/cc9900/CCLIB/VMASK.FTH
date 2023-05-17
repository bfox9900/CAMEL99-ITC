
NEEDS .S    FROM DSK1.TOOLS
NEEDS MOV,  FROM DSK1.ASM9900

MARKER /TEST


HEX
A758 CONSTANT WMODE
A75C CONSTANT  RMODE
8800 CONSTANT VDPRD               \ vdp ram read data
8802 CONSTANT VDPSTS              \ vdp status
8C00 CONSTANT VDPWD               \ vdp ram write data


 CODE  VAND ( vdpa mask -- ) \ mask contents of VDPA with mask
       TOS     SWPB,
       *SP+    R0  MOV,    \ pab flag address->r0
       RMODE @@    BL,     \ make it the VDP address
       VDPRD @@ W MOVB,
       WMODE @@     BL,    \ Change R0 to write mode
       TOS     INV,        \ invert mask for SZC instruction
       TOS     W    SZC,   \ mask error codes
       W  VDPWD @@ MOVB,   \ write back to PAB in VDP
       TOS POP,
       NEXT,
       ENDCODE
