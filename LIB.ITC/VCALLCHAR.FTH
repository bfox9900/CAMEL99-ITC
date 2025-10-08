\ VDP CALLCHAR compiles FONT source code directly to VDP RAM
\ Usage: S" 0123456789ABCDEDEF" 65 CALLCHAR

NEEDS V, FROM DSK1.VDPMEM

: ]pdt  ( ascii -- Vaddr) 8* 800 + ;  \ Compute pattern address of ascii

: >UINT32 ( addr len -- d ) 0 0 2SWAP >NUMBER  ABORT" bad #" DROP ;

: VD,     ( d -- ) V, V, ;

: CHOP   ( addr len n -- addr len addr' len' )
          >R                  \ Rpush n
          OVER R@             \ make copy with length n
          2SWAP               \ put original $ on top
          R> /STRING ;        \ cut off front string

: HEX64V,  ( addr len addr len -- )
    BASE @ >R  HEX  >UINT32 VD,  >UINT32 VD,   R> BASE ! ;

: CALLCHAR ( addr len char --)
         VP @ >R
         ]pdt VP !          \ set VDP memory pointer to pattern descriptor
         8 CHOP 2SWAP HEX64V,
         R> VP ! ;
