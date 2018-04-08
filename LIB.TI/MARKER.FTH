
\ MARKER create word to restore dictionary

\ Use:  MARKER FENCE
\ < ... make new words ... >
\ FENCE  removes all new words including the word FENCE

: MARKER  ( -- )
   LATEST @ HERE         \ get latest word NFA and location of HERE
   ALIGN                 \ align new word to even boundary
   CREATE  ,   ,         \  save here & latest
   
   DOES>  2@  LATEST ! DP ! ;
