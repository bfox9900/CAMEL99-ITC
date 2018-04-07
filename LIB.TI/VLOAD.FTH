\ VLOAD VSAVE  fast file transfer into VDP memory

HEX
: VLOAD  ( cadr len  vdpadr  cnt -- ior )
         3EDF ^PAB !
         [PAB 20 0 VFILL    \ erase the PAB

         14 [PAB FLG] VC!   \ DV80
         [PAB REC#] V!      \ store the cnt
         [PAB FBUFF] V!     \ set the buffer address
         [PAB FNAME] VPLACE
         
         5 FILEOP ;
