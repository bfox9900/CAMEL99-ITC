\ SPLIT & FUSE  handy words

 CODE SPLIT  ( AABB --  BB AA )     \ used in \LIB\SOUND.FTH
              C204 ,      \ TOS W MOV,   \ make a copy
              0984 ,      \ TOS 8 SRL,   \ slide 'AA' to the right
              0248 , FF , \ W FF ANDI,          \ mask out AA from the copy
              0646 , 
              C588 ,      \ W PUSH,
              NEXT,
              ENDCODE

 CODE FUSE   ( BB  AA -- AABB )    \ FUSE 2 bytes into a 16 bit word
              06C4 ,     \ TOS SWPB,
              A136 ,     \ *SP+  TOS ADD,
              NEXT,
              ENDCODE