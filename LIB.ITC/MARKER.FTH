\ MARKER a word to restore dictionary
\ Use:  MARKER EMPTY
\       < ... make new words ... >
\       EMPTY   removes all new words including the word EMPTY

: MARKER  ( -- )
   LATEST @  HERE        \ get latest word NFA and dictionary position
   CREATE  ,   ,         \  save here & latest
   DOES>  2@  DP ! LATEST !  ;
   
\ lock the current dictionary for COLD boots
: LOCK     DP @ ORGDP !   LATEST @ ORGLAST ! ;