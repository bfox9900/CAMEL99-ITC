\ FOXSHELL.FTH   CAMEL99 shell for disk file management
\ Oct 2020:  built with SAVESYS to create stand alone program

NEEDS DUMP       FROM DSK1.TOOLS
NEEDS OPEN-FILE  FROM DSK1.ANSFILES
NEEDS VALUE      FROM DSK1.VALUES
NEEDS CASE       FROM DSK1.CASE
NEEDS BUFFER:    FROM DSK1.BUFFER
NEEDS MALLOC     FROM DSK1.MALLOC
NEEDS COMPARE    FROM DSK1.COMPARE
NEEDS U.R        FROM DSK1.UDOTR   \ right justified printing


CR .( Compiling FOXSHELL )

VARIABLE WARNINGS   WARNINGS ON
VARIABLE #BYTES

\ busy spinner to show activity
VARIABLE SPIN#
CREATE SCHARS   CHAR | C, CHAR / C, CHAR - C, CHAR \ C,
: GETXY    ( -- col row) VROW 2@ ;
: SPINCHAR ( -- char ) SPIN# @ 1+ 3 AND DUP SPIN# ! SCHARS + C@  ;
: SPINNER  ( -- )      SPINCHAR GETXY >VPOS VC! ;

\ simplified file language
\ Usage example:  S" DSK2.MYFILE" R/W OPEN AS: #1
HEX .( .)
0 VALUE #1   0 VALUE #2   0 VALUE #3

: AS:  ( n -- <value> )  POSTPONE TO ;  IMMEDIATE

: OPEN  ( addr len -- hndl ) OPEN-FILE ?FILERR ;
: CLOSE ( hndl -- )         CLOSE-FILE ?FILERR ;
: READH ( hndl -- )         READ-LINE ?FILERR 2DROP ;

DECIMAL
\ CR if near end of screen
: ?CR     ( n -- ) LINES @ 3 MOD 0= IF CR THEN ;
.( .)
HEX
\ string helpers
 : ARG$     ( -- addr len ) BL PARSE-WORD ?FILE ;
 : $.       ( $addr -- ) COUNT TYPE ;
 : $.LEFT   ( $ width -- ) OVER C@ - >R $.  R> SPACES ;
 : NEXT$    ( addr len -- addr' len') + COUNT ;
\  : +PLACE  ( addr n $ -- ) 2DUP 2>R  COUNT +  SWAP CMOVE 2R> C+! ;
.( .)
HEX
: CLOSE-ALL ( --)  4 1 DO  I ]FID @ IF  I CLOSE-FILE DROP THEN   LOOP ;

\ ?break closes all open files.
: ?BREAK ( ? -- ) IF  CLOSE-ALL   TRUE ABORT" *BREAK*"   THEN ;

\ Modify key to allow it to break and close files
: FKEY    ( -- char)
           VPOS VC@ >R
           BEGIN                  \ start the loop
              CURS @              \ fetch 2 char cursor (space & _ )
              TMR@ 1FFF <         \ compare hardware timer to 1FFF
              IF DROP R@ THEN VPUT   \ swap cursor for screen char, write
              ?TERMINAL ?BREAK    \ test for Break key
              KEY?                \ check the keyboard
              ?DUP                \ DUP IF <> 0
            UNTIL                 \ loop until a key pressed
            R>  VPUT ;            \ put the space char on screen

\ screen control
: SPACE?   ( -- ?) KEY? BL = ;
: SPACEBAR ( -- ) SPACE? IF    FKEY DROP    THEN ;

.( .)
: OPEN-CATFILE ( adr len -- hndl) RELATIVE 100 FIXED R/O BIN OPEN ;

\ 3 DIGIT BCD to int convertor. Limited to 999
HEX
: F>INT   ( addr len -- addr len n)
          OVER C@  ( -- mantissa)
          CASE
            0 OF  0                    ENDOF
           40 OF  OVER 1+ C@           ENDOF
           41 OF  OVER 1+ C@ 64 * >R
                  OVER 2+ C@  R> +     ENDOF
           ( default)  -1  \ bad # indicator
           ENDCASE ;

DECIMAL
: DIR.TYPE  ( addr -- )
          F>INT
          CASE
             1 OF ." Txt/Fix"  ENDOF
             2 OF ." Txt/Var"  ENDOF
             3 OF ." Bin/Fix"  ENDOF
             4 OF ." Bin/Var"  ENDOF
             5 OF ." Program"  ENDOF
             ." ????"
          ENDCASE ;
.( .)
: HEAD.REC ( addr -- )
          DECIMAL
          DUP  7 $.LEFT SPACE COUNT ( addr len)
          NEXT$
          ."  Size " NEXT$ F>INT 5 U.R   ."  Used " NEXT$ F>INT 5 U.R
          2DROP ;

: DIR.REC ( addr -- )
          DUP  11 $.LEFT SPACE COUNT ( addr len)
          NEXT$ DIR.TYPE
          NEXT$ F>INT 7 U.R
          NEXT$ F>INT 7 U.R
          2DROP ;

: FILE.REPORT  CR LINES @ . ." lines, " #BYTES @ . ." bytes" ;

\ ========================================
\ *
\ * User commands: CAT DIR MORE DEL COPY
\ *

: CAT  ( <DSK?.> )   \  needs the '.' ONLY shows file name
          BASE @ >R DECIMAL
          ARG$ OPEN-CATFILE >R  \ store file handle

          PAD 80 R@ READH
          CR PAD HEAD.REC
          CR 13 SPACES  ." -type-  -sect- -b/rec-"

          LINES OFF
          BEGIN
             PAD DUP 80 R@ READH
           ( PAD)  C@   \ do while length > 0
          WHILE
             CR PAD DIR.REC
             1 LINES +!
             SPACEBAR
             ?TERMINAL ?BREAK
          REPEAT
          R> CLOSE
          CR LINES @ . ." files" CR
          R> BASE ! ;
.( .)
HEX
: DIR  ( <DSK?.> )
          ARG$
          OPEN-CATFILE >R  \ push handle
          PAD 50 R@ READH
          CR PAD HEAD.REC
          CR

          LINES OFF
          BEGIN
            PAD DUP 80 R@ READH
          ( PAD) C@   \ do while length <> 0
          WHILE
             PAD 0D $.LEFT ?CR
             1 LINES +!
             SPACEBAR
            ?TERMINAL ?BREAK
          REPEAT
          R> CLOSE
          DECIMAL
          CR LINES @ . ." files" CR
          HEX ;

.( .)
: MORE  ( <filename>)
          LINES OFF  #BYTES OFF
          ARG$ DV80 R/O OPEN >R
          BEGIN
             PAD DUP 50 R@ READ-LINE ?FILERR ( adr len flag)
          WHILE
             DUP #BYTES +!
             CR TYPE
             LINES 1+!
             SPACEBAR
             ?TERMINAL ?BREAK
          REPEAT
          R> CLOSE
          2DROP
          FILE.REPORT
;

HEX
: TOUPPER ( char -- upperchar ) 5F AND ;

: SURE?  ( -- ?)
         WARNINGS @
         IF
           CR ." Are you sure? (Y/N)"
           KEY TOUPPER [CHAR] Y =
         THEN ;

: .CANCEL  CR ." Cancelled" CR ;

: DEL   ( <filename>)
         ARG$ 2DUP R/W OPEN-FILE ?FILERR
         CR ." Delete " TYPE
         SURE?
         IF  7 FILEOP ?FILERR
              CLOSE-FILE 2DROP
              CR ." Done"
         ELSE
            DROP  .CANCEL
         THEN ;

: MOVE-FILE ( buff-size -- buff-size)
        #BYTES OFF
        DUP MALLOC >R
        LINES OFF
        SPACE
        BEGIN
          R@  50  #1 READ-LINE ?FILERR ( -- #bytes eof?)
        WHILE
          DUP #BYTES +!
          R@ SWAP #2 WRITE-LINE ?FILERR
          LINES 1+!
          SPINNER
        REPEAT
        R> DROP                 \ DROP buffer address from rstack
        MFREE
;
.( .)
DECIMAL

: COPY  ( <file1> <file2> )
        ARG$ ARG$
        SURE?
        IF
          DV80 W/O OPEN AS: #2
          DV80 R/O OPEN AS: #1
          52 MOVE-FILE
          #2 CLOSE
          #1 CLOSE
          BASE @ >R
          DECIMAL
          CR ." Copy complete. "
          FILE.REPORT
          R> BASE !
        ELSE
           2DROP 2DROP  .CANCEL
        THEN
;

: W/O+  ( -- fam ) APPEND FAM @  ;  \ TI-99 file access mode: write/append

HEX
: APND  ( <file1> <file2> )
        ARG$  ARG$
        DV80 W/O+ OPEN AS: #2
        DV80 R/O  OPEN AS: #1
        52 MOVE-FILE
        #2 CLOSE
        #1 CLOSE
        BASE @ >R
        DECIMAL
        CR ." Append complete"
        FILE.REPORT
        R> BASE ! ;

: CLS   PAGE ;

: HELP  CR
        CR ." Commands"
        CR ." --------------------"
        CR ." HELP Show this list"
        CR ." DIR  <DSK?.> show file names"
        CR ." CAT  <DSK?.> show files and types"
        CR ." MORE <path>  show contents of DV80 file"
        CR ." DEL  <path>  delete file at path"
        CR ." COPY <path1> <space> <path2> "
        CR ."      Copy file at path1 to path2"
        CR ." APND <path1> <space> <path2"
        CR ."      Append file1 to file2"
        CR ." WAITFOR <path> Paste to Classic99"
        CR ." CLS  Clear screen"
        CR ." BYE  Return to Home screen"
        CR ." WARNINGS OFF   Disables 'Are you sure?'"
        CR ." ------------------"
        CR ." SPACE bar will stop scrolling"
        CR ." FNCT 4 halts operations"
;


\ re-write accept to use new KEY. ( could patch it but this is clearer)
: FACCEPT     ( c-addr +n -- +n')
             OVER + OVER
             BEGIN
               FKEY DUP 0D <>
             WHILE
                DUP EMIT
                DUP 8 =
                IF   DROP 1-  3 PICK  UMAX  \ changed to use: 3 PICK   B.F.
                ELSE OVER C!  1+ OVER UMIN
                THEN
             REPEAT
             DROP NIP SWAP - ;
.( .)
: RCV  ( caddr len --  )
      DV80 W/O OPEN AS: #1
      BEGIN
        PAD DUP 50 FACCEPT ( addr len) #1 WRITE-LINE ?FILERR
      AGAIN ;

\ USED WITH Classic99. Pastes text into DV80 FILE
: WAITFOR  ( <PATH> )
        ARG$
        CR ." Waiting for file " 2DUP TYPE
        CR ." Press FCTN 4 to halt & SAVE"
        CR RCV ;

: SHELL
       WARM
       PAGE ." Fox Shell V1.2, Brian Fox Sep2021"
       DECIMAL
       HELP
       WARNINGS ON
       ABORT ;
\ LOCK to current dictionary position on WARM boot
DP @        ORGDP !
LATEST  @ ORGLAST !
CR .( Save as EA5 binary files)

INCLUDE DSK1.SAVESYS
 ' SHELL  SAVESYS DSK2.FOXSHELL
