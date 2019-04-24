\ catch throw for ANS Forth
VARIABLE HANDLER

: CATCH ( execution-token -- error# )  \ 0 means no error
        SP@ >R                         \ push the param stack
        HANDLER @ >R                   \ push the handler on the stack
        RP@ HANDLER !
        EXECUTE
        R> HANDLER !
        R> DROP
        0
;

: THROW  ( ??? error# -- ??? error#)
        ?DUP IF
          IF  HANDLER @ RP! ( err#)
              R> SWAP >R
              SP!
              DROP
              R>
          THEN
        THEN ;

\ Mitch Bradley’s implementation of CATCH and THROW is very simple when
\ understood.

\ CATCH saves the data stack pointer, the address of the nearest
\ enclosing other CATCH frame on the return stack, and saves the address
\ of the return stack frame it just created in the global variable
\ HANDLER. It then executes the word denoted by it’s execution token
\ argument. If that word completes normally (without THROWing), control
\ returns to CATCH via the normal Forth unnesting mechanism, CATCH
\ removes the stuff that it put on the return stack, restores the handler
\ variable to its previous contents, pushes a zero on the data stack, and
\ returns to its caller.

\ If, on the other hand, THROW is executed (with a non-zero argument),
\ THROW locates the nearest enclosing CATCH frame (whose address is in
\ handler), cleans off the return stack down to and including that CATCH
\ frame, restores the data stack pointer to the value saved in that
\ frame, pushes the throw value on the stack, and returns to CATCH’s
\ caller.

\ Milendorf, M., CATCH and THROW
\ When CATCH returns zero (meaning that 0 THROW was executed, or that no
\ THROW was executed at all), the state of the stack underneath that
\ zero is exactly as it would have been had CATCH’s argument been
\ executed with EXECUTE. When CATCH returns a non-zero value (meaning
\ that THROW was executed with a non-zero value), the depth of the
\ stack, not counting the throw value itself, is the same as it was just
\ before CATCH’s argument word was executed. It should be emphasized
\ that it is only the depth of the stack that is preserved, not the
\ contents of the stack (more literally, the data stack pointer itself
\ is restored without regard to the contents of the stack).
