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

\  for x from x0 to x1
\    plot(x,y)
\    if D > 0
\       y = y + 1
\       D = D - 2*dx
\    end if
\    D = D + 2*dy

\ Input the two endpoints of the line. Save the left endpoint as (x0, y0).
\ Plot the first point (x0, y0).
\ Calculate the constants Δx, Δy, 2Δy, and (2Δy - 2Δx).
\ Calculate the initial decision parameter: p0 = 2Δy - Δx
\ For each xk along the line, starting with k = 0:
\ If pk < 0, plot (xk+1, yk) and set pk + 1 = pk + 2Δy
\ Otherwise, plot (xk+1, yk+1) and set pk+1 = pk + 2Δy - 2Δx
\ Repeat step 5 until you reach the end point.


0 VALUE D
0 VALUE dx
0 VALUE dy
0 VALUE 2DY



: SETUP ( x0 y0  x1 y1 -- x0 Y0)
    2>R 2DUP 2R> ( -- x0 y0 x0 y0 x1 y1)
    ROT - ABS TO dy
    - ABS TO dx

;

: PLOTLINE ( x0 y0  x1 y1 -- )
        SETUP ( -- x0 x1)
        DO
           ( -- i y ) PLOTTER
           D 0>
           IF
             1 +TO y
             D dx 2* - TO D
           THEN
           D dy 2* +   TO D
        LOOP ;
