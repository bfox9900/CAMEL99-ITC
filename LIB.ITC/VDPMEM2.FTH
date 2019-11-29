\ vdp memory manager lexicon V2              Sept 2 2019  BJF

\ This version keeps a record of the VDP memory used at in the first VDP cell.
\ This allows us to save and restore the entire 8K VDP heap in 1 second
\ and restore the size of the heap as well.
\ *Advanced data stuctures could use a linked list of data that begins at
\ the contents of VDP>1000

\ VDP Memory Usage in Camel99 Forth when this file is loaded
\ |  VDP screen   |
\ + --------------|
\ |   RESERVED    |    sprites, patterns color tables
\ |               |
\ +---------------+  HEX 1000, VDP HEAP start
\ |    VHERE      |  VDP heap moves upwards
\ |      .        |
\ |      .        |
\ |      .        |
\ |      .        |
\ |               |
\ |               |
\ |               |
\ |   ^^^^^^^     |  move downwards
\ |  PAB stack    |  PABs start here
\ +---------------+ <-- VDPTOP returns this address
\ | 99 O/S space  |
\ |---------------|

\ INCLUDE DSK1.TOOLS   ( debug)

VARIABLE VP

HEX
1000 CONSTANT VDPSTART
2000 CONSTANT 8K

VDPSTART VP !   \ "VDP pointer" start of free VDP RAM

: VHERE   ( -- addr) VP @ ;   \ FETCH the value in VDP pointer
: VALLOT  ( n -- )
          DUP VP +!                    \ add n to the value in VDP pointer
          VDPSTART V@ + VDPSTART V! ;  \ update local VDP variable also

: VC,     ( n -- )   VHERE VC!  1 VALLOT ;
: V,      ( n -- )   VHERE V!   2 VALLOT ;
: VCOUNT  ( vdp$adr -- vdpadr len ) DUP 1+ SWAP VC@ ;
: VCREATE ( <text>) (  -- Vaddr) VHERE CONSTANT  ; 

: INIT-VDP  ( -- )  VDPSTART VP !   0 VHERE V!  2 VALLOT  ;

