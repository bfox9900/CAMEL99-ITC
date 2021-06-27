\ DATES.FOX     all kinds of date formatting words    02MAR91  FOX
\ changed to create strings for more flexibility

INCLUDE DSK1.TOOLS

DECIMAL

\ "This is an algorithm I've carried with me for 35 years,
\  originally in Assembler and Fortran II."
\  It counts the number of days from March 1, 1900."
\                                    Wil Baden R.I.P

: UNDER+  ( a b c -- a+c b )  ROT + SWAP ;

\ *****************************************************
\ **WARNING** only good until 2078 on 16 bit machine **
\ *****************************************************
: CDAY    ( dd mm yyyy -- century_day )
      -3 UNDER+  OVER  0< 
      IF   12 UNDER+  1-   THEN
      1900 -  1461 4 */   SWAP 306 *  5 +  10 /  + +  ;


: DOW     ( cday -- day_of_week )
           2 + 7 MOD 1+ ;             ( 7 is Sunday)

