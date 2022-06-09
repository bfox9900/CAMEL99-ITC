\ *********************************************************************
\ *
\ * Boot tracking
\ *
\ * Code copied more or less verbatim from:
\ * 1.7. The Art Of Assembly Part 7. Why A Duck?
\ * By Bruce Harrison 1991
\ *
\ * THE SECTION HERE AT LABEL OPEN PERFORMS "BOOT TRACKING"
\ * THAT IS, IT TELLS OUR PROGRAM WHICH DRIVE IT WAS LOADED FROM
\ *
\ BOOTTR MOV  @>83D0,R12          * GET THE CRU BASE IN R12
\        MOV  @>83D2,R9           * GET THE ROM ADDRESS FOR \DEVICE
\        SBO  0                   * ENABLE THE ROM
\        AI   R9,4                * ADDING FOUR PUTS US AT THE LENGTH BYTE
\        MOVB *R9+,R4             * PLACE THAT IN R4 AND INCREMENT R9
\        SRL  R4,8                * RIGHT JUSTIFY LENGTH IN R4
\        LI   R10,FILEDV          * POINT TO TEXT BUFFER
\ MOVIT  MOVB *R9+,*R10+          * MOV ONE BYTE FROM ROM TO TEXT BUFFER
\        DEC  R4                  * FINISHED?
\        JNE  MOVIT               * NO, DO ANOTHER BYTE
\        SBZ 0                    * DISABLE THE ROM (R4 IS ZERO AT THIS POINT)
\        B   *R11                 * BRANCH TO NEXT SECTION OF CODE
\ FILEDV TEXT "DSK1."             * File device

INCLUDE DSK1.TOOLS

MARKER REMOVE

HEX
24 USER 'R12  \ address of R12 in any Forth workspace
HEX
CODE 0SBO  ( -- ) 1D00 ,  NEXT, ENDCODE
CODE 0SBZ  ( -- ) 1E00 ,  NEXT, ENDCODE

HEX
: CARDON    83D0 @ 'R12 !   0SBO 83D2 @  ;

: DSK?. ( -- addr len)

          0SBZ ;
