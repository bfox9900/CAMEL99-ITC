\ D I C T I O N A R Y   C R E A T I O N
\ * UN-COMMENT HASH and you get 4-way hashed dictionary for 3..4x faster lookups.
: HEADER, ( addr len --)
      ALIGN
      CURRENT @  DUP>R   \ Fetch CURRENT wid, make a copy for later
\ === compile the header fields ===
      @ ,                  \ fetch the NFA & compile in the LFA field
      0 C,                 \ compile the precedence byte (immediate flag)
      HERE DUP LATEST !   \ HERE is now a new NFA, store NFA in LATEST
      R>  !                \ & also in the current 'WID' we saved earlier
      S, ;                 \ compile the (addr len) string as the name.

: HEADER   BL PARSE-WORD HEADER, ;
