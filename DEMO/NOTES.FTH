\ NOTES.FTH gives you a table of note frequencies     Feb 1 2024  B Fox 

\ these are as accurate to pitch as TI-99 can produce
CREATE NOTES[]   \ create a name for the data
\ put the number into memory with the comma operator
\ FREQ    MIDI Note 
\ ----    ---- ----
  110 , \  45	A2   
  117 , \  46	A#2/Bb2
  123 , \  47	B2
  131 , \  48	C3
  139 , \  49	C#3/Db3
  147 , \  50	D3
  156 , \  51	D#3/Eb3
  165 , \  52	E3
  175 , \  53	F3
  185 , \  54	F#3/Gb3
  196 , \  55	G3
  208 , \  56	G#3/Ab3
  220 , \  57	A3
  233 , \  58	A#3/Bb3
  247 , \  59	B3
  262 , \  60	C4 (middle C)
  277 , \  61	C#4/Db4
  294 , \  62	D4
  311 , \  63	D#4/Eb4
  330 , \  64	E4
  349 , \  65	F4
  370 , \  66	F#4/Gb4
  392 , \  67	G4
  415 , \  68	G#4/Ab4
  440 , \  69	A4 concert pitch
  466 , \  70	A#4/Bb4
  494 , \  71	B4
  523 , \  72	C5
  554 , \  73	C#5/Db5
  587 , \  74	D5
  622 , \  75	D#5/Eb5
  659 , \  76	E5
  698 , \  77	F5
  740 , \  78	F#5/Gb5
  784 , \  79	G5
  831 , \  80	G#5/Ab5
  880 , \  81	A5
  932 , \  82	A#5/Bb5
  988 , \  83	B5
  1047 , \  84	C6
  1109 , \  85	C#6/Db6
  1175 , \  86	D6
  1245 , \  87	D#6/Eb6
  1319 , \  88	E6
  1397 , \  89	F6
  1480 , \  90	F#6/Gb6
  1568 , \  91	G6
  1661 , \  92	G#6/Ab6
  1760 , \  93	A6
  1865 , \  94	A#6/Bb6
  1976 , \  95	B6
  2093 , \  96	C7
  2217 , \  97	C#7/Db7
  2349 , \  98	D7
  2489 , \  99	D#7/Eb7
  2637 , \ 100	E7
  2794 , \ 101	F7
  2960 , \ 102	F#7/Gb7
  3136 , \ 103	G7
  3322 , \ 104	G#7/Ab7
  3520 , \ 105	A7
  3729 , \ 106	A#7/Bb7
  3951 , \ 107	B7
  4186 , \ 108	C8

\ make word that indexes into the table and fetches the frequency
: ]NOTE ( n -- freq) CELLS NOTES[] +  @ ;
