\ Simple VDP RAM manager
\ Works the same way as the Forth dictionary
\ Best for static allocation

VARIABLE VP    \ VDP memory pointer (4K block)

HEX 1000 VP !   \ start of free VDP RAM

: VHERE   ( -- addr) VP @ ;   \ FETCH the value in VDP pointer
: VALLOT ( n -- )    VP +! ;  \ add n to the value in VDP pointer

\ VDP number "compilers". Put a number or character in VDP RAM 
\ and advance the VP pointer by the proper amount (2 or 1)
: V,     ( n -- )  VHERE V!   2 VALLOT ;
: VC,    ( n -- )  VHERE VC!  1 VALLOT ;

: VCONST:  ( n -- <text>)
            CREATE VHERE , ( n) V,  \ compile time: VDP address in CPU RAM, put n in VDP RAM
            DOES> @ V@ ;            \ run time: fetch the VDP address,
                                    \ then fetch the const from that VDP address

: VAR:     ( -- vaddr)   VHERE CONSTANT    0 V,
: DIM      ( n -- vaddr) VHERE CONSTANT   VALLOT ;

\ see: \DEMO\VDPSTRINGS.FTH  for a real application example



