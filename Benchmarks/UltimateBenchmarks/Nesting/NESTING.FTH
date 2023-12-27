\ For  ASMForth II 

\ Amstrad 6128+ Z80A 4Mhz	Uniforth  Nesting 1Mil  3:26
\ ZX Spectrum 2+  FIG-Forth 1.1a	  Nesting 1Mil  3:15
\ C64 (normal)	  Forth64	          Nesting 1Mil	6:20
\ PDP11           FIG-Forth 1.3       Nesting 1Mil  0:49

\ TI99            Camel99 Forth       Nesting 1Mil  2:30.7
\                 w/tail-call optimization          1.54.6

\                 TurboForth 1.21     Nesting 1Mil  2:29

\                 ASMForth II         Nesting 1Mil  1:28.7
\                 W/tail-call optimization          0:54.23
HOST INCLUDE DSK1.ELAPSE 

ASMFORTH 
: BOTTOM ;
: 1st BOTTOM BOTTOM ;  : 2nd 1st 1st ;      : 3rd 2nd 2nd ;
: 4th 3rd 3rd ;        : 5th 4th 4th ;      : 6th 5th 5th ;
: 7th 6th 6th ;        : 8th 7th 7th ;      : 9th 8th 8th ;
: 10th 9th 9th ;       : 11th 10th 10th ;   : 12th 11th 11th ;
: 13th 12th 12th ;     : 14th 13th 13th ;   : 15th 14th 14th ;
: 16th 15th 15th ;     : 17th 16th 16th ;   : 18th 17th 17th ;
: 19th 18th 18th ;     : 20th 19th 19th ;   

CODE RUN    20th  ;CODE 

HOST 
:  1MILLION   CR ."  1 million nest/unnest operations" RUN ;

CR .( enter 1million or 32million )
\ ELAPSE 1MILLION 

NEEDS -; FROM DSK1.TAILCALL

\ recompile with tailcall optimization operator ( -; )
ASMFORTH 
: BOTTOM  ;  \ can't optimze this one because there is no function in it. 
: 1ST BOTTOM BOTTOM -;  : 2ND 1ST 1ST -;      : 3RD 2ND 2ND -;
: 4TH 3RD 3RD -;        : 5TH 4TH 4TH -;      : 6TH 5TH 5TH -;
: 7TH 6TH 6TH -;        : 8TH 7TH 7TH -;      : 9TH 8TH 8TH -;
: 10TH 9TH 9TH -;       : 11TH 10TH 10TH -;   : 12TH 11TH 11TH -;
: 13TH 12TH 12TH -;     : 14TH 13TH 13TH -;   : 15TH 14TH 14TH -;
: 16TH 15TH 15TH -;     : 17TH 16TH 16TH -;   : 18TH 17TH 17TH -;
: 19TH 18TH 18TH -;     : 20TH 19TH 19TH -;   

CODE RUN    20TH  ;CODE 

HOST 
:  1MILLION2   CR ." Optimized 1M nest/unnest operations" RUN ;
