\ rkey from FbForth 
DECIMAL
 10 CONSTANT RL         \ loop-count for re-repeats of current char
150 CONSTANT RH         \ loop-count to start repeating current char
\ BKL should be half of BKH if you change these
 60 CONSTANT BKL        \ low blink loop-count for cursor-write
120 CONSTANT BKH        \ high blink loop-count for char-write

  0 VARIABLE BLINK      \ blink loop-count accumulator
  0 VARIABLE OKEY       \ old key
  0 VARIABLE CURCHR     \ char at cursor position
  0 VARIABLE KC         \ repeat-key count
\ RLOG = RH when waiting to start repeating current char
\ RLOG = RL when waiting to repeat current char
 RH VARIABLE RLOG       \ repeat-char loop-count wait

\ Get char at cursor position
: GCH
   CURPOS @             \ get screen cursor position
   VSBR CURCHR ! ;      \ get char
\ Restore char to cursor position
: PCH
   CURCHR @             \ get current char from storage
   CURPOS @ VSBW ;      \ restore char
\ Put cursor char to cursor position
: PCUR
   30 CURPOS @ VSBW ;   \ write cursor char

: RKEY   ( -- key )  \ Stack contents are indicated by "S:..."
   BEGIN
      ?KEY              \ ASCII of key to stack    S:key|0
      -DUP              \ DUP if not 0             S:(key key)|0
      1 BLINK +!        \ inc BLINK counter
      BLINK @           \ current BLINK value      S:(key key)|0 blink
      DUP BKL < IF   \ blink < low blink-count?
         PCUR           \ yes..put cursor at cursor position
      ELSE
         PCH            \ no..restore char at cursor position
      THEN
      BKH = IF    \ blink = high blink-count?      S:(key key)|0
         0 BLINK !      \ yes..reset blink
      THEN
      IF    \ some key pressed?                    S:key
         KC @              \ repeat-key count      S:key kc
         1 KC +!           \ inc repeat-key count
         0 BLINK !         \ reset blink
         IF \ waiting to repeat (KC <> 0)?         S:key
            RLOG @         \ yes..current repeat time    S:key rlog
            KC @           \ repeat-key count      S:key rlog kc
            < IF  \ long enough to repeat char?    S:key
               RL RLOG !   \ now we're waiting for re-repeats
               1 KC !      \ set key-count to 1 for re-repeats
               1           \ exit loop at UNTIL    S:key 1
            ELSE \ not long enough to repeat char
               OKEY @      \ old key               S:key okey
               OVER = IF   \ same key, i.e., need to wait?  S:key
                  DROP     \                       S:
                  0        \ repeat loop at UNTIL  S:0
               ELSE
                  1        \ exit loop at UNTIL    S:key 1
                  DUP KC ! \ set key-count to 1 for re-repeats S:key 1
               THEN
            THEN
         ELSE \ new key                            S:
            1              \ exit loop at UNTIL    S:1
         THEN
      ELSE \ no key pressed                        S:key
         RH RLOG !         \ start repeat-loop count
         0 KC !            \ reset repeat-key count
         0                 \ repeat loop at UNTIL  S:key 0
      THEN
   UNTIL                   \                       S:key
   DUP OKEY !              \ store current key as old key
   PCH     ;               \ restore char at cursor position
