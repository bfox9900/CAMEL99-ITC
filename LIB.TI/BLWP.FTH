\ BLWP  allows you to create your own subprograms

\ Usage:
\ CREATE WKSP2    16 CELLS ALLOT ( this is for registers)
\ CREATE MYVCTR   WKSP2 ,  ' PROGRAM >BODY ,
\ MYWKSP BLWP

CODE BLWP  ( daddr -- )  \ "BULLWHIP" takes a 2VARIABLE as input arg.
           *TOS BLWP,     \ BLWP loads the workspace and program counter into CPU
            TOS POP,      \ refill Forth TOS when we get back from our journey
            NEXT,
            ENDCODE
