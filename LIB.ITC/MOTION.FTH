\ Direct Sprite motion control  BJF Jun 15 2018
\ This method creates a "motion" table in CPU RAM call ]VECTOR
\ See: SPRITEDEMO for usage example
\ Mar 2023  re-write to fix VECT+ and SP.MOVE 

.( .)
\ INCLUDE DSK1.TOOLS  \ debugging

NEEDS SPRITE FROM DSK1.DIRSPRIT
NEEDS TABLE4: FROM DSK1.TABLES

HERE
DECIMAL 
\  32 sprites * 4 bytes for each x,y vector 
32 4* CONSTANT SMT.SIZE 

\ create space for a sprite motion table in RAM 
CREATE SMT    SMT.SIZE ALLOT 

\ 
\ TABLE4: creates a fast table of "4 BYTE" records. 
\ Use 2@ and 2! to fetch and store the motion vectors
SMT TABLE4: ]VECTOR    

\ init all vectors to zero
: CLR-MOTION ( -- ) 0 ]VECTOR  SMT.SIZE  0 FILL ;

\ Vector addition of x,y with a vector dx,dy
\ Masked to 8 bits 
HEX 
: VECT+ (  x y dx dy -- x' y') 
    ROT + 0FF AND >R 
    +     0FF AND R> ;

\ uses V@ and V! to read/write 16 bits to sprite location table
DECIMAL 
: SP.MOVE ( spr# -- )
    DUP SP.Y DUP>R V@       ( -- spr# xy  ) ( r-- vaddr)
    SPLIT                   ( -- spr# x y ) ( r-- vaddr)
    ROT ]VECTOR 2@ VECT+    ( --  x' y')    ( r-- vaddr)
\ "fuse" x y into one integer 
    FUSE                    ( --  xy)       ( r-- vaddr)
    R> V!                   \ store the integer in sprite location
;

.( .)
: ALL-SPRITES ( -- 1st last) 0 SPR# @ ;  \ syntax sugar :-)

\ translate in the mathematical sense, moves sprites
\ 0 4 TRANSLATE moves sprites 0..3  
\ ALL-SPRITES TRANSLATE moves all of them 
: TRANSLATE ( 1st last  -- ) 1+ SWAP DO  I SP.MOVE  LOOP ;

\ This works like motion in BASIC. It stores motion bytes in ]VECTOR array
\ The difference is that that dx dy values will be added to
\ the sprite's position only when call SP.MOVE or TRANSLATE
HEX 
: MOTION     ( dx dy spr# --) ]VECTOR 2! ;

\ *NEW* Plural version defines same motion for a range of sprites
: MOTIONS ( dy dx first last -- )  1+ SWAP DO   2DUP I MOTION   LOOP 2DROP ;
.( .)
CLR-MOTION  \ init-motion
DECIMAL
HERE SWAP - . .( bytes)

