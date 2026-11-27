\ PHOTO-TORPEDO weapon

NEEDS SPRITE FROM DSK1.DIRSPRIT
NEEDS DB     FROM DSK1.SOUND

2 CONSTANT #PHOTON

: LASER-ON    GEN1 141 HZ 14 DB     GEN2 143 HZ 14 DB ;
: LASER-OFF   GEN1 MUTE             GEN2 MUTE ;

DECIMAL
: EXPLODE ( spr# -- )
    5 NOISE 0 DB         \ impact sound
    LASER-OFF            \ kill the laser beam
    150 MS
    6 NOISE 4 DB
    17 1 DO
        PAUSE
        GEN4 I DB        \ fade impact noise
        I OVER SP.COLOR  \ change spr# color
        3400 TICKS
    LOOP
    DROP
    SILENT
;

: FIRE_TORPEDO
    4 NOISE 0 DB                  \ initial shot NOISE
    300 TICKS                     \ brief ontime
    LASER-ON
    4 NOISE 10 DB                 \ HISS noise at cruise volume.
;

: CONTACT?  ( -- ?) #PHOTON POSITION >XY GCHAR BL <> ;
