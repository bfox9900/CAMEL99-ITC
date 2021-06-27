\ vdp memory manager lexicon    BJF     Jan 29 2021

\ VDP Memory Usage in Camel99 Forth when this file is loaded
\ |  VDP screen   |  VDP >0000
\ + --------------|
\ |   RESERVED    |    sprites, patterns color tables
\ |---------------|
\ |  >460..7FF    |  *FREE 928 bytes in TEXT mode only*
\ |---------------|
\ |  >800..       |  *Pattern descriptor table*
\ +---------------+  HEX 1000, VDP HEAP start
\ |    VHERE      |  VDP heap moves upwards
\ |      .        |
\ |      .        |
\ |      .        |
\ |      .        |
\ |               |
\ |               |
\ |               |        ^^^^^^^
\ |   ^^^^^^^     |  move downwards
\ |  PAB stack    |  PABs start here
\ +---------------+ <-- VDPTOP returns this address
\ | 99 O/S space  |
\ |---------------| VDP >3FFF

\ INCLUDE DSK1.TOOLS  \ debugging only

\ VARIABLE VP    ( moved to kernel for V2.55 )

HEX 1000 VP !   \ "VDP pointer" start of free VDP RAM
: VHERE   ( -- addr) VP @ ;   \ FETCH the value in VDP pointer
: VALLOT  ( n -- )   VP +! ;  \ add n to the value in VDP pointer
: VC,     ( n -- )   VHERE VC!  1 VALLOT ;
: V,      ( n -- )   VHERE V!   2 VALLOT ;
: VCOUNT  ( vdp$adr -- vdpadr len ) DUP 1+ SWAP VC@ ;
: VCREATE ( <text> -- ) VHERE CONSTANT  ; \ address when <text> invoked
\ : VPLACE   ( $addr len Vaddr -- )  \ like PLACE for VDP RAM. In KERNEL 2.6
\           2DUP VC! 1+ SWAP VWRITE ;
