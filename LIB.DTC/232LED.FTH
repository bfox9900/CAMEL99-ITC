
CODE LED-ON    ( CFA=CEF2)
    0647 , C5CC , 020C , 1300 , 1D07 , C337 ,
    NEXT,
END-CODE



CODE LED-OFF    ( CFA=CEF2)
    0647 , C5CC , 020C , 1300 , 1E07 , C337 ,
    NEXT,
END-CODE

\ CODE LED-ON
\          R12 RPUSH,
\          R12 RS232/1 LI,
\          7 SBO,
\          R12 RPOP,
\          NEXT,
\          ENDCODE

\ CODE LED-OFF
\          R12 RPUSH,
\          R12 RS232/1 LI,
\          7 SBZ,
\          R12 RPOP,
\          NEXT,
\          ENDCODE
