\ VDP to VDP move using allocated buffer

NEEDS MALLOC  FROM DSK1.MALLOC

HEX
: VCMOVE ( vaddr1 vaddr2 n --) \ VDP2VDP mem. move
        >R                       \ save n
        SWAP                     \ reverse addresses
        R@ DUP MALLOC 2DUP 2>R   ( R-- n heap n)
        SWAP VREAD               \ copy vaddr1 to heap
        2R> -ROT  VWRITE         \ copy heap to vaddr2
        R> MFREE                 \ restore heap
;
