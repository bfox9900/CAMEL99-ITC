\ VLOAD VSAVE  fast file transfer into VDP memory

INCLUDE DSK1.ANSFILES

HEX

: VLOAD  ( cadr len  -- ior )
          NEWHNDL DUP >R NEWPAB       \ copy handle & assign PAB
            [PAB BL 0 VFILL                \ erase the VDP PAB to be safe.
            2DUP MAKEPAB ( -- $addr len)
            14   [PAB FLG]    VC!          \ MODE: INPUT,DISPLAY,VARIABLE
            50   [PAB RECLEN] VC!          \ 80 bytes/record
            NEWFILE                    \ setup new file

           5 FILEOP ?FILERR ;
