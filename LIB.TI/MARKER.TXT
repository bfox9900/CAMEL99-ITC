\ MARKER create word to restore dictionary

\ Use:  MARKER RESTORE
\ < ... make new words ... >
\ FENCE  removes all new words including the word RESTORE

: MARKER  ( -- )
   LATEST @ HERE         \ get latest word NFA and location of HERE
   ALIGN                 \ align new word to even boundary
   CREATE  ,   ,         \  save here & latest
   
   DOES>  2@  LATEST ! DP ! ;