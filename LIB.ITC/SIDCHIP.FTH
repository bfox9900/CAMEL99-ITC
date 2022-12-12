--BLOCK-00005---------
\ SID chip support code. M.Wills, May 16th, 2011
: ]L    ]  POSTPONE LITERAL ;

$5800 CONSTANT SID
: DUMMY ( -- ) [ SID $32 + ]L 0 C! ;
: W>SID ( addr word --) DUP 2+ 2 PICK >< SWAP C! C! DUMMY ;
: B>SID ( addr byte --) SWAP C! ;
: SIDF ( freq  ch# --) 14 * [ SID ]L + W>SID ;
: SIDP ( pulse ch# --) 14 * [ SID 4 +  ]L + W>SID ;
: SIDW ( wform ch# --) 14 * [ SID 8 +  ]L + B>SID ;
: SIDA ( atdec ch# --) 14 * [ SID 10 + ]L + B>SID ;
: SIDS ( susrl ch# --) 14 * [ SID 12 + ]L + B>SID ;
: SFIL ( value --) [ SID $2A + ]L W>SID ;
: SRES ( reson --) [ SID $2E + ]L B>SID ;
: SVOL ( vol   --) [ SID $30 + ]L B>SID ;
CR
.( SID support loaded.)
.( Note: This is un-tested code)
