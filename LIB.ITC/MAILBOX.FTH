\ mailbox.fth  inter-task communication for Camel99 ForthHSF2000  04JAN94
\ base on article in F.D. vol7 #4 by R. W. Dobbins. Columbia ML.
DECIMAL
\ Concept:
\ Block on "SEND" until the mailbox is cleared by the receiver
\ It's like a transputer like com-link for FORTH tasks.

NEEDS TASK:  FROM DSK1.MTASK99

HEX
50 USER MAILBOX  \ one mailbox for task

: SEND-MAIL  ( n task --)
        BEGIN
           YIELD
           DUP @
        WHILE
        REPEAT
        MAILBOX LOCAL ! ;

: GET-MAIL ( -- n )
        BEGIN
          YIELD
          DUP @ ?DUP
        UNTIL
        MAILBOX OFF ;
