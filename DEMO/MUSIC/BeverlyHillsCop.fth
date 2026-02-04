\ using Camel99 Forth MUSICWRITER to try some hard music.
\ Apr 2024 Brian Fox

NEW-TUNES

DECIMAL
\ Key is Ab
: MELODY-LINE1
    105 BPM
    SOPRANO

  ||: 4/4 NORMAL
       1/4 F3  1/8. Ab3 1/8 F3 1/16 F3 1/8 Bb3 F3 Eb3          |
    |  1/4 F3  1/8. C4  1/8 F3 1/16 F4 1/8 Db4 C4 Ab3          |
    |  F3  C4  F4  1/16 F3 1/8 Eb3 1/16 Eb3 1/8 C3 G3 LEGATO   |
    |  1/2 F3 / / :||

  ||
;


TASK1 SLEEP
' MELODY-LINE1 TASK1 ASSIGN

: GO    TASK1 RESTART ;
