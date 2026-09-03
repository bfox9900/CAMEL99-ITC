\ GNOMESORT.FTH
\ Gnome sort is a sorting algorithm which is similar to Insertion sort,
\ except that moving an element to its proper place is accomplished by a
\ series of swaps, as in Bubble Sort.

\The pseudocode for the algorithm is:
\
\ function gnomeSort(a[0..size-1])
\    i := 1
\    j := 2
\    while i < size do
\        if a[i-1] <= a[i] then
\            // for descending sort, use >= for comparison
\            i := j
\            j := j + 1
\        else
\            swap a[i-1] and a[i]
\            i := i - 1
\            if i = 0 then
\                i := j
\                j := j + 1
\            endif
\        endif
\    done


\
\ NEEDS SORTTESTSUITE.FTH
\
NEEDS DEFER FROM DSK1.DEFER

DEFER PRECEDES
DEFER EXCHANGE

' < IS PRECEDES

: XCHG  ( addr1 addr2 -- ) 2DUP @ SWAP @  ROT ! SWAP ! ;

' XCHG IS EXCHANGE

: GNOMESORT ( A N)
  SWAP >R 1                   ( N C)
  BEGIN                       ( N C)
    OVER OVER >               ( N C F)
  WHILE                       ( N C)
    DUP IF                    ( N C)
      DUP DUP 1- OVER OVER R@ PRECEDES
      IF  R@ EXCHANGE 1-
      ELSE DROP DROP 1+
      THEN
    ELSE 1+
    THEN              ( N C)
  REPEAT
  DROP DROP
  R> DROP    ( --)
;
