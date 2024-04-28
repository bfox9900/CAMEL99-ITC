\ CROSS COMPILER Extensions tell the compiler how to build ITC data types

\ ========================================================================
\ T A R G E T   C O D E - W O R D   C R E A T I O N

\ create SMART "code" words in the Target segment
\ They CANNOT run on the HOST system but abort with an error

CROSS-COMPILING

: TCODE-ERR     TRUE ABORT" Host cannot run Target CODE words" ;

: ?code-ERR   sp@ csp @ -
              IF
                 CR CR ." CODE word incomplete!"
                 CR ." DATA Stack-> " .S
                 TRUE ABORT" Compile halted"
              THEN ;

: +CODE        !CSP              \ used to allow jumping between CODE/ENDCODE
               TCREATE:
               THERE 2+ CFA,
               tcodewords 1+!
               DOES> TCODE-ERR ;


: CODE         NEW-JMPTABLE      \ init the jump table
               +CODE ;

: ENDCODE      ?CODE-ERR  ;

\ ============================================================================
\ C R O S S   C O M P I L E R   W O R D   " C R E A T O R S "

\ These words are in the COMPILER vocabulary. When TARGET-COMPILING is invoked
\ they will be found before the same words in the HOST Forth system.

CROSS-COMPILING
: CREATE
                TCREATE:             \ compile time: create a dual header and record the Target NFA in Host Forth
                'DOVAR  cfa,         \ compile the XT of 'dovar' into the TARGET CFA
                                     \ (PFA is empty)
                DOES> @ nfa>PFA ;    \ Run-time: fetch the nfa we stored and convert to PFA (pointer to the data)

: VARIABLE
                TCREATE:             \ compile time: create a dual header and record the Target NFA in Host Forth
                'DOVAR  cfa,         \ compile the XT of 'dovar' into the TARGET CFA
                0 T,                 \ compile a zero into the PFA

                DOES> @ nfa>PFA ;    \ Run-time: fetch the nfa we stored and convert to PFA (pointer to the data)

: 2VARIABLE
                TCREATE:             \ compile time: create a dual header and record the Target NFA in Host Forth
                'DOVAR cfa,         \ compile the XT of 'dovar' into the TARGET CFA
                0 T, 0 T,            \ make space for 2 cells and init them to 0

                DOES> @ nfa>PFA ;    \ Run-time: fetch the LFA we stored and convert to PFA (pointer to the data)

: CONSTANT                          \ CONSTANT: words are used like a normal constant for debugging and compiling on the HOST
                TCREATE:             \ compile time: create a dual header and record the Target NFA in Host Forth
\ compile into the target word header
                'DOCON  cfa,         \ compile the 'docon' XT into this CFA
                ( n) T,              \ compile the actual number into the next CELL which is the TARGET word's PFA

                DOES> @ nfa>PFA T@ ; \ Run-time: fetch the nfa we stored and convert to PFA & fetch the data


\ =======================================================================
\ TMS9900 and user variables under CAMEL99

\ USER variables are used in Multi-tasking Forth systems.
\ They are "local" to a specific task and usually reference by a pointer
\ called 'UP' (user pointer)
\ CAMEL99 does not have a user pointer. It uses the TMS9900 WP register
\ Cool trick, but it means we can't read a value from the TARGET system
\ for the cross-compiler to use.

\ So we have to create a variable UP(t) and assign the value of the for
\ of the WP register for the Cross compiler to calculate a USER variable's
\ Address.

\ For TI-994a our primary workspace is at at HEX 8300
HOST-COMPILING VARIABLE UP(t)   HEX 8300 UP(t) !

CROSS-COMPILING
: USER
                TCREATE:                       \ compile time: create a dual header and record the Target LFA in Host Forth
                'DOUSER cfa,                   \ CROSS-compile the 'DOUSER' XT into this CFA
                ( n) T,                        \ compile the user variable no. in the PFA of the word.

                DOES> @ nfa>PFA t@  UP(t) @ + ;  \ reads parameter field (PFA) add it to the address of target UP


\ create smart TARGET colon words that abort if you try to run them
: <colon:>
                TCREATE:                       \ create a dual header and record the Target CFA in Host Forth
                'DOCOL  cfa,                   \ compile the DOCOL XT into this CFA
                                               \ PFA will contain the XTs of other words that are compiled into a new word.

                DOES> true abort" Cannot run a TARGET colon definition" ;
