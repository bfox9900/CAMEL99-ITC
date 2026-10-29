\ NOTES.FTH  calculating semi-tones with integer math  Oct 2026 Brian Fox

NEEDS HZ  FROM DSK1.SOUND

\ In BASIC we can use floating point math to compute
\ a valid note on the musical scale.

\ 160 N=INT(24*RND+1)
\ 170 note=110*(2^(1/12))^N

\ This is a bit more challenging with 16 bit integer math.
\ Fortunately Forth's */ operator lets us scale numbers with
\ 32bit math internally.

\ First we discover that:  2^1/12 ≈ 1.059463

\ So we can multiply a frequency number by 1.0594 and scale it with */
: NOTE+ ( freq -- 'freq) 10594 10000 */ ; \ compute next semitone

\ We can simulate the ^N term with a loop
: NOTE ( n -- freq) 110 SWAP 0 ?DO  NOTE+ LOOP  ;

\ play semi-tones and show frequency
: SEMI-TONES  ( n -- )
    0 ?DO
        GEN1
        I NOTE DUP HZ .  0 DB
        200 MS
    LOOP
    MUTE  ;

\ The result is not perfect but close.
\ From a base frequency of 110 Hz it gives
\ 224Hz and 438Hz for the octaves
: OCTAVES ( -- ) 13 *  CR SEMI-TONES ;

\ USAGE:  2 OCTAVES

: ^  ( n power -- n')
    DUP 0= IF  2DROP 1  EXIT THEN
    OVER SWAP 1 ?DO  OVER * LOOP NIP ;
