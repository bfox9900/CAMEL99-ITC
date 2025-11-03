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

\ values are faster at getting a number onto the stack
NEEDS VALUE     FROM DSK1.VALUES
NEEDS DEFER     FROM DSK1.DEFER

DEFER PLOTTER

0 VALUE D
0 VALUE dx
0 VALUE dy
0 VALUE y

: SETUP ( x0 y0  x1 y1 -- )
        OVER 4 PICK - DUP>R TO dx  \  dx = x1 - x0
        DUP  3 PICK - DUP   TO dy   \  dy = y1 - y0
        2* R> - TO D                 \  D = 2*dy - dx
;

: PLOTLINE ( x0 y0  x1 y1 -- )
        SETUP
        ( -- x0 x1)
        DO
           ( -- i y ) PLOTTER
           D 0>
           IF
             1 +TO y
             D dx 2* - TO D
           THEN
           D dy 2* +   TO D
        LOOP ;
