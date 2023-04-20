\ T A R G E T   S Y S T E M   D E F I N I N G   W O R D S
\                    text    runtime-action   parameter
\                   -------  --------------- -----------
 : CONSTANT  ( n --)  HEADER  COMPILE DOCON     COMPILE, ;
 : USER      ( n --)  HEADER  COMPILE DOUSER    COMPILE, ;
 : CREATE    ( -- )   HEADER  COMPILE DOVAR              ;
 : VARIABLE  ( -- )   CREATE                  0 COMPILE, ;

\ (:noname) came from studying gforth. It's a nice factor.
: (:NONAME) ( -- )  T['] DOCOL @ COMPILE,  HIDE  ]  ;
