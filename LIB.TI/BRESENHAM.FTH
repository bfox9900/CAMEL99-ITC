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

\ promiscuous variables make it simpler, but not re-entrant
VARIABLE D
VARIABLE dx
VARIABLE dy
VARIABLE y

: SETUP ( x0 y0  x1 y1 -- )
        OVER 4 PICK - DUP >r dx !   \  dx = x1 - x0
        DUP  3 PICK - DUP dy !      \  dy = y1 - y0
        2* R> - D!                  \  D = 2*dy - dx



: PLOTLINE ( x0 y0  x1 y1 -- )
        SETUP
        ( -- x0 x1) 
        DO
           ( -- i y ) PLOT
           D @ 0>
           IF
             1 y +!
             D @ dx @ 2* - D !
           THEN
           D @ dy @ 2* +  D !
        LOOP ;