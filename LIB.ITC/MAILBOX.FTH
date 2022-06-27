\ mailbox.fth  inter-task communication for HSF2000  04JAN94
\ base on article in F.D. vol7 #4 by R. W. Dobbins. Columbia ML.
\ For CAMEL99 Forth Jun 2022

DECIMAL
\ Concept:
\ Block on "SEND" until the mailbox is cleared by the receiver
\ It's like a TRANSPUTER com-link for FORTH tasks.

NEEDS FORK  FROM DSK1.MTASK99

HEX
50 USER MAILBOX  \ one 16 bit mailbox per task

: SEND-MAIL  ( n PID --) \ PID (process ID) is task's workspace address
        BEGIN
           DUP MAILBOX LOCAL @   \ check PID mailbox is empty
        WHILE
           PAUSE                 \ if not pass control to the next task
        REPEAT
        MAILBOX LOCAL ! ;        \ store n into PID's mailbox

: GET-MAIL ( -- n ) \ read mailbox of the active task
        BEGIN
          PAUSE
          MAILBOX @ ?DUP
        UNTIL
        MAILBOX OFF ;
