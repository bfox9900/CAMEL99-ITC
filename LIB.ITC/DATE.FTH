\ DATES.FTH     all kinds of date formatting words    02MAR91  FOX
\ changed to create strings for more flexibility

INCLUDE DSK1.TOOLS
\ NumberofDays = (1461∗Year)4 + (153∗Month)5 + Day
 : #DAYS ( dd mm yyyy -- century_day )
  1461 4 */  >R
  153  5 */  + R> + ;

DECIMAL
\ From Rosseta Code
\ Zeller's Congruence for Julian Calendar.
: ZELLER ( m -- days since march 1 )  9 + 12 MOD 1-   26 10 */ 3 + ;

: WEEKDAY ( d m y -- 0..6 )   \ Monday..Sunday
  OVER 3 < IF 1- THEN
  DUP    4 /
  OVER 100 / -
  OVER 400 / +  +
  SWAP ZELLER + +
  1+ 7 MOD ;
