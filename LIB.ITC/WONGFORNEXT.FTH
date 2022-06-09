\ Leo Wong  21 June 02004 02003 fyj +
\ fexit fleave for next

MACRO FOR " ( +U -- )  BEGIN ?DUP WHILE 1- >R"
MACRO NEXT " ( -- )   R> REPEAT"
MACRO FEXIT  " ( -- )  R> DROP EXIT"
MACRO FLEAVE " ( -- )   R> DROP 0 >R"
