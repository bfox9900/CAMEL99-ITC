\ Miser's Case
\ http://dxforth.mirrors.minimaltype.com/miser.html#CONTINUE
\ A general purpose Forth case statement.
\
\ Revision  2014-03-08
\ Edited for Camel99 Forth   Mar 30 2021 Fox
\
\ -------------------------------------------------------------
\ History
\ - RANGE changed to use BETWEEN.
\   Add CONTINUE for C-style switching.
\ - Examples revised. Minor text changes.
\ - Add THENS END-CASE.
\ - EQUAL RANGE re-coded for optimizers.
\ - Text and example re-worded to emphasize use of
\   COND THENS while deprecating Forth-94 CASE.
\ - Add custom implementations
\ -------------------------------------------------------------
\
\ Sample implementation only
\
\ The high-level implementation makes assumptions about the
\ control flow stack which may not be applicable to your forth:
\ control flow is on the data stack; control flow items are 1,
\ 2 or 3 cells wide; the number 0 (single cell) is used as a
\ sentinel.
\
\ For all but the best optimizing Forth compilers, the run-time
\ should be replaced with machine-code primitives for maximum
\ performance.
\
\ COND THENS is per Wil Baden and provides the mechanism for
\ resolving nested conditionals.
\
\ Tested on SwiftForth, VFX, Win32Forth, Gforth and others.
\
\ This code is public domain. Use at your own risk.
\
\ Keywords:
\
\   COND OF IF ELSE THENS CONTINUE EQUAL RANGE WHEN
\
\ Syntax:
\
\   COND ( x1)
\      x2           OF         ... ELSE
\      COND <tests> WHEN       ... ELSE
\      <test>       IF ( DROP) ... ELSE
\      ( x1) ( DROP) ... ( default )
\   THENS
\
\ COND ... THENS is analogous to CASE ... ENDCASE with
\ the exception that THENS does not automatically DROP x1.
\
\ OF performs the same function as the Forth-94 word but
\ in addition may be used with ELSE or THEN. ( x1) x2 OF
\ is the short-form of ( x1) COND x2 EQUAL WHEN.
\
\ COND <tests> WHEN where <tests> may consist of one or
\ more of the following:
\
\    x2    EQUAL  ( test if x1 equals x2 )
\    x2 x3 RANGE  ( test if x1 is in the range x2..x3 )
\
\ Miser's COND ... WHEN generates compact efficient code
\ comparable with other language compilers.
\
\ <test> IF where <test> can be any code which leaves x1
\ and a flag for IF. IF ... ELSE is for expansion allowing
\ user-defined tests including those where x1 is not
\ necessarily an integer.
\
\ CONTINUE redirects program flow from previously matched
\ tests that would otherwise pass to THENS. It provides a
\ 'fall-through' capability akin to C's switch statement.
\ CONTINUE may be placed anywhere within:
\
\   OF ... ELSE
\   WHEN ... ELSE
\   IF ( DROP) ... ELSE
\

0 CONSTANT COND  IMMEDIATE

: THENS   BEGIN  ?DUP WHILE  POSTPONE THEN  REPEAT ; IMMEDIATE

\ Camel Forth, Swiftforth
: WHEN      POSTPONE ELSE  >R  POSTPONE THENS  R>  POSTPONE DROP ; IMMEDIATE
: CONTINUE  >R  POSTPONE THENS  POSTPONE COND  R> ; IMMEDIATE

\ GFORTH -------------------
\ : WHEN  POSTPONE ELSE  >R >R >R  THENS  R> R> R>  POSTPONE DROP ; IMMEDIATE
\ : CONTINUE   >R >R >R  POSTPONE THENS  POSTPONE COND  R> R> R> ; IMMEDIATE

\ - other forths
\ : WHEN  POSTPONE ELSE  2>R  POSTPONE THENS  2R>  POSTPONE DROP ;   IMMEDIATE
\ : CONTINUE  2>R  POSTPONE THENS  POSTPONE COND  2R> ; IMMEDIATE

: EQUAL   POSTPONE OVER  POSTPONE <>  POSTPONE IF ; IMMEDIATE

\ RANGE is based on  : BETWEEN OVER - -ROT - U< 0= ;
\ Values may be signed or unsigned.
: (RANGE)    2 PICK -ROT OVER - -ROT - U< ;

: RANGE   POSTPONE (RANGE)  POSTPONE IF ; IMMEDIATE
: OF      POSTPONE OVER  POSTPONE =  POSTPONE IF  POSTPONE DROP ; IMMEDIATE

\ Forth-94 compatibility words
: CASE     POSTPONE COND ; IMMEDIATE
: ENDOF    POSTPONE ELSE ; IMMEDIATE
: ENDCASE  POSTPONE DROP  POSTPONE THENS ; IMMEDIATE

HEX
: TEST1 ( n --)  SPACE
  COND
    COND
          00 1F RANGE
          7F    EQUAL  WHEN  ." Control char "       ELSE
    COND
          20 2F RANGE
          3A 40 RANGE
          5B 60 RANGE
          7B 7E RANGE  WHEN  ." Punctuation "        ELSE
    COND  30 39 RANGE  WHEN  ." Digit "              ELSE
    COND  41 5A RANGE  WHEN  ." Upper case letter "  ELSE
    COND  61 7A RANGE  WHEN  ." Lower case letter "  ELSE
      DROP ." Not a character "
  THENS ;

DECIMAL
