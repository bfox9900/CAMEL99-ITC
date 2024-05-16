\ https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm
\ plotLine(x0,y0, x1,y1)
\  dx = x1 - x0
\  dy = y1 - y0
\  D = 2*dy - dx
\  y = y0

\  for x from x0 to x1
\    plot(x,y)
\    if D > 0
\       y = y + 1
\       D = D - 2*dx
\    end if
\    D = D + 2*dy

\ FASTER using values 
NEEDS VALUE FROM DSK1.VALUES 

: ->  POSTPONE TO ; IMMEDIATE 
: +->  POSTPONE +TO ; IMMEDIATE 

\ promiscuous variables make it simpler, but not re-entrant
0 VALUE D
0 VALUE dx
0 VALUE dy
0 VALUE y

: SETUP ( x0 y0  x1 y1 -- )
        OVER 4 PICK - DUP>R -> dx   \  dx = x1 - x0
        DUP  3 PICK - DUP -> dy     \  dy = y1 - y0
        2* R> - -> D                \  D = 2*dy - dx
        2 PICK -> y                 \  y = y0
;

: PLOTLINE ( x0 y0  x1 y1 -- )
        SETUP ( -- x0 x1) 
        DO
           ( -- i y ) PLOT
           D 0> 
           IF
             1 +-> y 
             D dx 2* - -> D 
           THEN
           D dy 2* +   -> D
        LOOP ;