\ ORGEON TRAIL FILE: DSK3.OREGON3

: SONLOST
  PRINT." Your son wandered off" ...
  PRINT." Spent a day looking for him"
  1 DAY CREDIT
  2 FOOD DEBIT
;

: OXLOST
  PRINT." OX wandered off. Two days lost" ...
  PRINT." (Tie him up next time)"
  2 DAY CREDIT
  4 FOOD DEBIT
;

: TERRAIN
  PRINT." RUGGED MOUNTAINS" ...
  37 %CHANCE:
        PRINT." You got lost and loose valuable"
        PRINT." time trying to find a trail."
       2 DAY CREDIT
     OTHERWISE
        PRINT." You pushed through."
    ;CHANCE

  21 %CHANCE:
        PRINT." Wagon damaged! Lost time and supplies"
        2 RANDOM 1+ DAY CREDIT
        4 RANDOM 1+ FOOD DEBIT
        2 RANDOM MISC DEBIT
     ;CHANCE
;

: BLIZZARD
     PRINT." Blizzard in mountains at south pass" ...
     47 %CHANCE:
         PRINT." Time & supplies lost"
         2 RANDOM  1+ DAY CREDIT
         2 RANDOM MISC DEBIT
         4 RANDOM 1+ FOOD DEBIT
    OTHERWISE
        PRINT." You made it safely through"
        PRINT." South Pass. Only light snow."
        CR
    ;CHANCE
;

CASE: TRAGEDY
       | SNAKEBITE  | MASSACRE     | FROZE          | NOMEDICINE
       | BANDITS    | VERYSICK     | BUSTED-WAGON   | SWAMPED
       | FOG        | FIRE         | RAIN           | BAD-WATER
       | SONLOST    | OXLOST       | TERRAIN        | BLIZZARD
;CASE

DECIMAL
: SHITHAPPENS
        CR  ...
        PRINT." Tragegy has done commenced!"
        CR
        16 RANDOM TRAGEDY ;

: ?BROKE  CASH @ 1 < IF  PRINT." Partner, yer flat broke!"  ENDIF ;


CHOICE: ." leg"     7 HEALTH DEBIT  ;
CHOICE: ." arm"     5 HEALTH DEBIT  ;
CHOICE: ." belly"  10 HEALTH DEBIT ;
CHOICE: ." backside :-)"  PRINT." (sorry, 't ain't funny)"  8 HEALTH DEBIT ;
CHOICE: ." head..."  HEALTH OFF ;
CASE: ANATOMY   4 CHOICES,   ;CASE

: BODYPART    4 RANDOM ANATOMY ;

: DOCTOR?
     PRINT." Wanna see a doctor?"
     Y/N?
     IF    SEE-DOCTOR
     ELSE  PRINT." Ok, it's yer funeral."
     ENDIF
;

: ?HEALTH
      20 %CHANCE:  ( don't report this all the time)
      HEALTH @ 20 <
      IF CR PRINT." You don't look so good partner."  DOCTOR?  ENDIF
 
      HEALTH @ 20 30 BETWEEN
      IF CR PRINT." You gotta look after yerself better."  ENDIF

      HEALTH @ 31 49 BETWEEN
      IF CR PRINT." You feelin' ok? Ya looks kinda pale." ENDIF

      HEALTH @ 49 >
      IF CR PRINT." Yer still lookin' purty healthy"  ENDIF

     ;CHANCE

;

: ?SEE-DOCTOR
     CR
     PRINT." Wanna have a doc look at you?"
     Y/N?
     IF
       SEE-DOCTOR
       60 %CHANCE:
            PRINT." He patched you up!"
            10 RANDOM HEALTH CREDIT
            WOUNDED OFF
          ELSE PRINT." He fixed it but yer still hurtin'"
            WOUNDED OFF
           10 HEALTH DEBIT
          ;CHANCE
     ENDIF 
     ?DEAD ;

: GOTSHOT
          PRINT." OUCH! You got shot in the " BODYPART
          ?DEAD
          WOUNDED ON
          5 RANDOM MISC DEBIT
          20 RANDOM 2+ AMMO DEBIT

          25 %CHANCE:
             PRINT." and they took one of your oxen."
             1 OXEN DEBIT
         ;CHANCE
        
         ?SEE-DOCTOR
;

: ?GOTSHOT
         WOUNDED @ IF  GOTSHOT  ENDIF ;

: WANNAEAT  ( -- n)
          CR
          PRINT." How do you wanna eat?"
          PRINT."   (1) POORLY"
          PRINT."   (2) OK"
          PRINT."   (3) WELL? "
          QUALITY 1 3 VALID-INPUT
;

: RUNNING 
          PRINT." You are running away" ...
          40 RANDOM 1+ MILEAGE CREDIT
          10 RANDOM HEALTH DEBIT
          20 OXEN DEBIT

           2 RANDOM DAY CREDIT

          15 %CHANCE: WOUNDED ON ;CHANCE
          12 %CHANCE: GOTSHOT    ;CHANCE

;

: ATTACK    PRINT."  You are attacking " ...
            55 %CHANCE:
                GOTSHOT
            ELSE
               PRINT." You scared them off!"
               PRINT." and found their money and food"
               CR
               60 RANDOM 10 FOOD CREDIT
              120 RANDOM 30 CASH CREDIT
               15 RANDOM HEALTH CREDIT
           ;CHANCE
;

: CONTINUE  CR
            PRINT."  Continuing " ...
            20 RANDOM 1+ MILEAGE CREDIT
            2 RANDOM HEALTH DEBIT
            10 RANDOM 2+ OXEN DEBIT
            1 RANDOM DAY CREDIT

            2 %CHANCE: WOUNDED ON ;CHANCE
;

: DEFEND    PRINT." We circled the wagons" ...
            PRINT." and let 'em have it!" ...
            20 RANDOM 2+ AMMO DEBIT
            AMMO @ 0= IF  MASSACRE  ENDIF

            65 %CHANCE:
               CR
               PRINT." You are a pretty good shot!"
               PRINT." They took off and left us alone"
               CR
               10 HEALTH CREDIT
                5 OXEN CREDIT
               10 RANDOM 1+ AMMO DEBIT

            ELSE
               CR
               PRINT." We took some hits but survived"
               20 RANDOM AMMO DEBIT
               10 HEALTH DEBIT
               30 %CHANCE: GOTSHOT  ;CHANCE

            ;CHANCE
;

CASE: REACTION  ( n -- )
       | RUNNING | ATTACK  | CONTINUE  | DEFEND
;CASE

: HOSTILE-DECIDE ( -- )
         PRINT." They look hostile!"
         PRINT." Whaddya reckon we should do?"
         PRINT."   (1) RUN"
         PRINT."   (2) ATTACK"
         PRINT."   (3) CONTINUE"
         PRINT."   (4) DEFEND"
         ACTION 1 4 VALID-INPUT DROP
         CR ...
         ACTION @ 1- REACTION
         ?GOTSHOT
;

\ ======================================
\ random names for food
CHOICE: ." eatin'" ;
CHOICE: ." food" ;
CHOICE: ." viddles" ;
CHOICE: ." grub" ;
CASE: FOODS  4 CHOICES,  ;CASE
: FOODSTUFF  4 RANDOM FOODS ;

\ ======================================
\ game animals
CHOICE: ." deer"     
        PRINT." We got food for days!" CR 
        100 FOOD CREDIT ;

CHOICE: ." possum"
        PRINT." Ain't much food but better than nothin'" CR
         10 FOOD CREDIT ;

CHOICE: ." squirrel"
        PRINT." We is gonna be hungry" CR
         5 FOOD CREDIT ;

CHOICE: ." duck"
        PRINT." A little greasy, but fillin'" CR
        15 FOOD CREDIT ;

CHOICE: ." turkey"
        PRINT." Now that's some good viddles" CR
         25 FOOD CREDIT  ;

CASE: VARMINTS  5 CHOICES,   ;CASE

: ANIMAL    5 RANDOM VARMINTS ;

: HUNT
        PRINT." You are hunting"
        PRINT." Be vaarrwee quiet " ...
        PRINT." Press space bar to fire"
        BEGIN KEY? BL = UNTIL
        CR PRINT." BANG!" CR 

        ACCURACY @ HEALTH @ *    \  HEALTH affect accuracy
        55 MAX %CHANCE:
             PRINT." You shot a " ANIMAL
        OTHERWISE
             PRINT." You missed."
            PRINT." Yer gonna be hungry tonight." ...
             5 FOOD DEBIT
             3 HEALTH DEBIT
       ;CHANCE

       4 RANDOM 1+ AMMO DEBIT
;
