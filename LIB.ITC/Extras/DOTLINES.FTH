\ .LINES   display no. of lines compiled.
: .LINES    BASE @ >R
            DECIMAL
            LINES @ . ."  lines"
            R> BASE ! ;

CR CR .( Remember to use 'LINES OFF' first)