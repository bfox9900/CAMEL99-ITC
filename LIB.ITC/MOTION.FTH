\ Direct Sprite motion control  BJF Jun 15 2018                                 
\ This method creates a "motion" table in CPU RAM call ]VECTOR                  
\ See: SPRITEDEMO for usage example                                             
\ Mar 2023  re-write converted ]VECTOR to table of cells                        
                                                                                
.( .)                                                                           
\ INCLUDE DSK1.TOOLS  \ debugging                                               
NEEDS SPRITE FROM DSK1.DIRSPRIT                                                 
NEEDS TABLE2: FROM DSK1.TABLES                                                  
HERE                                                                            
HEX                                                                             
\ create array of direction vectors in dictionary                               
\ to hold x y vectors for each sprite (64 BYTES)                                
HERE  MAX.SP 1+ CELLS ALLOT TABLE2: ]VECTOR                                     
                                                                                
\ init all vectors to zero                                                      
: CLR-MOTION ( -- ) 0 ]VECTOR  MAX.SP 1+ CELLS  0 FILL ;                        
                                                                                
\ Vector addition of current postion with offset                                
\ : VECT+ ( dx dy x y -- x' y') ROT +  -ROT +  SWAP ;                           
HEX                                                                             
CODE VECT+ ( dx dy x y -- x' y')  \ 6x FASTER than Forth version                
           C236 , \ *SP+ W MOV,                                                 
           A136 , \ *SP+ TOS A,                                                 
           A588 , \  W  *SP  A,                                                 
           NEXT,                                                                
           ENDCODE                                                              
                                                                                
\ SP.MOVE is critical for fast speed.                                           
\ Uses V@ V! SPLIT VECT+ and FUSE CODE words                                    
\ - V@ (256 uS) reads both X and Y bytes from VDP as an cell                    
\   This is faster than using VC@ VC@  (405uS)                                  
\ - SPLIT breaks them into 2 ints on the stack                                  
\ - VECT+ adds the offsets to X & Y                                             
\ - FUSE puts them back together as 1 cell                                      
\ - V! puts the single cell back into VDP ram                                   
: SP.MOVE ( spr# -- )                                                           
          DUP SP.Y                                                              
          DUP>R V@ SPLIT ( -- spr# x y ) ( r-- vaddr)                           
          ROT ]VECTOR @ SPLIT                                                   
          VECT+    ( --  x' y')    ( r-- vaddr)                                 
          FUSE R> V!                                                            
;                                                                               
.( .)                                                                           
: ALL-SPRITES ( -- 1st last) 0 SPR# @ ;  \ syntax sugar :-)                     
                                                                                
\ translate in the mathematical sense, update all the sprites                   
: TRANSLATE ( 1st last  -- ) 1+ SWAP DO  I SP.MOVE  LOOP ;                      
                                                                                
\ This works like motion in BASIC. It stores motion bytes in ]VECTOR            
\ The difference is that that dx dy values will be added to                     
\ the sprite's position each time you call SP.MOVE or TRANSLATE                 
                                                                                
\ compensate for 9918 chip                                                      
: ?NEGX      ( dx dy -- dx dy' ) OVER 0< IF 1+ THEN ;                           
: MOTION     ( dx dy spr# --)  >R  ?NEGX  FUSE  R> ]VECTOR ! ;                  
                                                                                
\ *NEW* Plural version defines same motion for a range of sprites               
: MOTIONS ( dy dx first last -- )                                               
   1+ SWAP DO   2DUP I MOTION   LOOP 2DROP ;                                    
.( .)                                                                           
CLR-MOTION  \ init-motion                                                       
DECIMAL                                                                         
HERE SWAP - . .( bytes)                                                         
                                                                                
                                                                                
