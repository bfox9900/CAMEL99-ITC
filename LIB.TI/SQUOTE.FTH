\ SQUOTE S" extension for Forth 2012 to include interpretation
\ and multiple input strings.  It can handle 256 bytes total.

\ The following code will output 2 different stack strings 
\ as expected.
\  S" This is STRING1"  S" This is STRING2"  ( -- adr1 len1 adr2 len2)

\ SEE:  11.3.4 Other transient regions
\ This version will uses HEAP space in TI-99 low memory

\ *** LOAD THIS AT START OF PROGRAM IF YOU USE THE HEAP DYNAMICALLY
\ It needs the HEAP buffer forever once it is allocated
HEX
120 MALLOC CONSTANT SBUF	 \ allocate a pool buffer	
           VARIABLE $P              \ string pool pointer

: POOL    ( -- addr) SBUF $P @ + ;   \ current pool address
: POOL++  ( n -- ) FF AND $P +!  ;   \ circular pointer 

: S"           ( -- )
               [CHAR] " PARSE   ( -- adr len)
               STATE @
               IF     COMPILE (S")  S, \ action when COMPILING

               ELSE   
	              POOL PLACE       \ place string in Pool
                      POOL COUNT       \ return the address and length
                      DUP 1+ ALIGNED POOL++  \ update pool address

               THEN ; IMMEDIATE
