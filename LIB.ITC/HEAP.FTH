\ simple low memory heap control for CAMEL99

\ Using the 8K block of low memory in TI-99 we can create
\ simple memory heap. Allocation will be like the Forth dictionary.
\ Allocations are linear upward.
\ To deallocated use a negative value. No safety net is provided.
\

\ VARIABLE H      \ LOW memory HEAP pointer defined in the KERNEL

: HEAP   ( -- addr)  H @ ;  \ equivalent to HERE in HI memory
: HALLOT ( n -- )    H +! ; \ equivalent to ALLOT in HI memory
: HALIGN ( -- )   HEAP ALIGNED H ! ;

\ heap number "compilers". Put a number in memory & advance the pointer
: H,     ( n -- )  HEAP !   2 HALLOT ;
: HC,    ( n -- )  HEAP C!  1 HALLOT ;

\ Usage examples:
\ : INT:      CREATE  HEAP ,  0 H,           DOES> @ ;
\ : DOUBLE:   CREATE  HEAP ,  0 H, 0 H,      DOES> @ ;
\ : HBUFFER:  CREATE  HEAP ,  HALLOT HALIGN  DOES> @ ;

