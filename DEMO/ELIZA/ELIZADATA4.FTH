 CR .( === ELIZA REPLY LISTS === )
 CR .(  for use with Eliza 3.0 )

 HERE JOB ! 
 HEX 2000 DP !   ( put this data in low ram )
DECIMAL
 
    KEY" CAUSE"      
    KEY" DREAM"      
    KEY" DREAMT"      
    KEY" ALIKE"      
    KEY" CAN I"      
    KEY" YOU ARE"    
    KEY" YOU'RE"      
    KEY" NAME"       
    KEY" WHY DON'T YOU"   
    KEY" WHY CAN'T I"   
    KEY" I REMEMBER"  
    KEY" DO YOU REMEMBER"   
    KEY" I DON'T"    
    KEY" I FEEL"     
    KEY" ARE YOU"    
    KEY" I CAN'T"    
    KEY" I AM"       
    KEY" I'M"        
    KEY" YOUR"       
    KEY" I WANT"     
    KEY" MY"         
    KEY" MAYBE"      
    KEY" I NEED"     
    KEY" I THINK"   
    KEY" THINK"    
    KEY" YOU"        
    KEY" I HAVE"     
    KEY" I'VE"       
    KEY" REALLY"  

    KEY" WHAT"    
    KEY" HOW"     
    KEY" WHO"     
    KEY" WHERE"  
    KEY" WHEN"    
    KEY" WHY"     
    
    KEY" NO"      
    KEY" WE"      
    KEY" OK"       
 \ this word conflicts with IF in Forth. :-) Need a vocabulary
 \   KEY" IF"   
\
 \ foreign language cue words       
    KEY" FRANCAIS"      
    KEY" ITALIANO"      
    KEY" ESPANOL"     
    KEY" DEUTSCH"      
    KEY" NEDERLANDS"   

\
    KEY" CAN YOU"    
    { :: CR ." Don't you believe that I can " <TOPIC?> ;
      :: CR ." Perhaps you would like to be able to " <TOPIC?> ;
      :: CR ." You want me to be able to " <TOPIC?> ;
    } REPLY: CANYOU

    { :: CR ." Perhaps you don't want to " <TOPIC> '.' ;
      :: CR ." Do you want to be able to " <TOPIC?> ;
    } REPLY: CANI

    { :: CR ." What makes you think I am " <TOPIC?> ;
      :: CR ." Does it please you to believe that I am " <TOPIC?> ;
      :: CR ." Perhaps you would like to be " <TOPIC> '.' ;
      :: CR ." Do you sometimes wish you were " <TOPIC?> ;
    } REPLY: YOUARE

\ anytime we need new keywords with the same replies
\ we just make a synonym Forth word.
     : YOURE  YOUARE ;

    { :: CR ." I keep patient relationships professional." ;
      :: CR ." There is no 'We' here." CR ." You are my patient." ;
      :: CR ." No! We cannot " <TOPIC> ." !" ;

      :: CR ." Hey!!" 
         CR ." I am your doctor. Nothing more." ;
     } REPLY: WE


\    { :: CR ." Do you really think its likely that you " <TOPIC?> ;
\      :: CR ." Do you wish that you " <TOPIC?> ;
\      :: CR ." What do you think when you say " CR '"' <TOPIC?> '"' ; 
\      :: CR ." Really-- if you " <TOPIC?> ; 
\    } REPLY: IFI 


    { :: CR ." You really don't " <TOPIC?> ;
      :: CR ." Why don't you " <TOPIC?> ;
      :: CR ." Me neither. Does that matter to you?." ;
     } REPLY: IDONT


    { :: CR ." Does that trouble you?" ;
      :: CR ." Tell me more about such feelings." ;
      :: CR ." Do you often feel " <TOPIC?> ;
      :: CR ." Do you enjoy feeling " <TOPIC?> ;
    } REPLY: IFEEL

    { :: CR ." How long have you had "  <TOPIC?> ;
      :: CR ." I think that's normal." ;
      :: CR ." Many people have "  <TOPIC> '.' ;
    } REPLY: IHAVE

   : I'VE   IHAVE ;

    { :: CR ." Do you really believe I don't " <TOPIC?> ;
      :: CR ." Perhaps in good time I will " <TOPIC>  '.' ;
      :: CR ." Do you want me to "  <TOPIC?> ;
      :: CR ." Do you think you should be able to " <TOPIC?> ;
    } REPLY: WHYDONTYOU

    { :: CR ." I don't know, why can't you " <TOPIC?> ;
      :: CR ." Have you really tried to " <TOPIC?> ;
      :: CR ." You can. you just don't know it yet." ;
    } REPLY: WHYCANTI

    { :: CR ." Why are you interested in whether or not I am " <TOPIC?> ;
      :: CR ." Would you prefer if I were not "  <TOPIC?>  ;
      :: CR ." Perhaps in your fantasies I am "  <TOPIC> '.'  ;
    } REPLY: AREYOU

    { :: CR ." How do you know you can't "  <TOPIC?> ;
      :: CR ." Have you tried to "  <TOPIC?> ;
      :: CR ." Do you think everyone can "  <TOPIC?> ;
    } REPLY: ICANT

    { :: CR ." Did you come to me because you are " <TOPIC?> ;
      :: CR ." How long have you been " <TOPIC?> ;
      :: CR ." Do you believe it is normal to be " <TOPIC?> ;
      :: CR ." Do you enjoy being " <TOPIC?> ;
    } REPLY: IAM

: IM   IAM ;

     { :: CR ." Do you really need "  <TOPIC?>   ;
       :: CR ." In my experience everybody needs "  <TOPIC> '.'  ;
       :: CR ." What would it mean if you got "  <TOPIC?>   ;
     } REPLY: INEED
 
     { :: CR ." Sounds serious. Tell me more." ;
       :: CR ." I have no reason to be dishonest with you." ;
       :: CR ." You don't trust me yet do you?" ;
     } REPLY: REALLY

    { :: CR ." Do you often think of " <TOPIC?> ; 
      :: CR ." Does thinking of " <TOPIC> ." bring anything else to mind?" ;
      :: CR ." What else do you remember?" ;
      :: CR ." Why do you recall " <TOPIC> ." right now?" ;
      :: CR ." What in the present situation reminds you of " <TOPIC?> ;
      :: CR ." What is the connection between me and " <TOPIC?> ;
    } REPLY: IREMEMBER

    { :: CR ." Did you think I would forget " <TOPIC?> ;
      :: CR ." Why do you think I should recall " <TOPIC?> ." now" ;
      :: CR ." What about " <TOPIC?> ." You mentioned " <TOPIC> ;
    } REPLY: DOYOUREMEBER 

    { :: CR ." We were discussing you -- not me." ;
       :: CR ." Let's keep talking about your issues." ;
       :: CR ." You're not really talking about me, are you?" ;
    } REPLY: YOU

    { :: CR ." What would it mean if you got " <TOPIC?>   ;
      :: CR ." Why do you want " <TOPIC?> ;
      :: CR ." Suppose you soon got " <TOPIC?> ;
      :: CR ." What if you never got " <TOPIC?> ;
      :: CR ." Sometimes i think i want " <TOPIC> '.' ;
      :: CR ." Doesn't everybody?" ;
    } REPLY: IWANT

    { :: CR ." Why do you ask?" ;
      :: CR ." Does that question interest you?" ;
      :: CR ." What answer would please you the most?" ;
      :: CR ." What do you think?" ;
      :: CR ." Are such questions on your mind often?" ;
      :: CR ." What is it you really want to know?" ;
      :: CR ." Have you asked anyone else this question?" ;
      :: CR ." Have you asked such questions before?" ;
      :: CR ." What else comes to mind when you ask that?" ;
    } REPLY: WHAT

\ all questions give the same answers
    : HOW    WHAT ;
    : WHO    WHAT ;
    : WHEN   WHAT ;
    : WHERE  WHAT ;
    : WHY    WHAT ;

    KEY" TI-99"    
   {  :: CR ." TI-99! That's my favourite machine!" ;

      :: CR ." I sure hope you program that thing in " 
         CR ." FORTH" ;

      :: CR ." Do you have secret dreams about C64?" ;
      :: CR ." Do people tease you because your TI-99 is slow?" ;
   } REPLY: TI99

   { :: CR ." Names don't interest me." ;
      :: CR ." I don't care about names. Go on." ;
   } REPLY: NAME

   { :: CR ." Is that the real reason?" ;
      :: CR ." Do any other reasons come to mind?" ;
      :: CR ." Does that reason explain anything else?" ;
      :: CR ." What other reason might there be?" ;
   } REPLY: CAUSE

    KEY" SORRY"         
    { :: CR ." Please don't apologise." ;
      :: CR ." Apologies are not necessary." ;
      :: CR ." What feelings do you get when you apologise?" ;
      :: CR ." Don't be so defensive!" ;
    } REPLY: SORRY
 
    { :: CR ." What does that dream suggest to you?" ;
      :: CR ." Do you dream often?" ;
      :: CR ." What persons appear in your dreams?" ;
      :: CR ." Are you disturbed by your dreams?" ;
    } REPLY: DREAM
    : DREAMT  DREAM ;

    { :: CR ." You don't seem quite certain." ;
      :: CR ." Why the uncertain tone?" ;
      :: CR ." Can't you be more positivE?" ;
      :: CR ." You aren't sure?" ;
      :: CR ." Don't you know?" ;
    } REPLY: MAYBE

    { :: CR ." Are you saying that just to be negative?" ;
      :: CR ." You are being a bit negative." ;
      :: CR ." Why not?" ;
      :: CR ." Are you sure?" ;
      :: CR ." Why not?" ;
    } REPLY: NO


    { :: CR ." Why are you concerned about my " <TOPIC?> ;
      :: CR ." What about your own " <TOPIC?> ;
    } REPLY: YOUR


    { :: CR ." Can you think of a specific example?" ;
      :: CR ." When?" ;
      :: CR ." What are you thinking of?" ;
      :: CR ." Really, always?" ;
      :: CR ." Do you really think so?" ;
      :: CR ." But are you sure you " <TOPIC?> ;
      :: CR ." Do you ever doubt that you " <TOPIC?> ;
    } REPLY: ITHINK

: THINK   ITHINK ;


   { :: CR ." In what way?" ;
     :: CR ." What resemblance do you see?" ;
     :: CR ." What does the similarity suggest to you?" ;
     :: CR ." What other connections do you see?" ;
     :: CR ." Could there really be some connection?" ;
     :: CR ." How?" ;
   } REPLY: ALIKE

    KEY" YES"        
   { :: CR ." You seem quite positive." ;
     :: CR ." Are you sure?" ;
     :: CR ." I see." ;
     :: CR ." I understand." ; 
    } REPLY: YES
 
    KEY" FRIEND"     
   { :: CR ." Why do you bring up the topic of friends?" ;
     :: CR ." Do your friends worry you?" ;
     :: CR ." Do your friends pick on you?" ;
     :: CR ." Are you sure you have any friends?" ;
     :: CR ." Do you impose on your friends?" ;
     :: CR ." Perhaps your love for friends worries you?" ;
     :: CR ." Do computers worry you?" ;
     :: CR ." Are you talking about me in particular?" ;
   } REPLY: FRIEND

    KEY" COMPUTER"    
   { :: CR ." Are you frightened by machines?" ;
     :: CR ." Why do you mention computers?" ;
     :: CR ." What do you think computers have to do with your problem?" ;
     :: CR ." Don't you think computers can help people?" ;
     :: CR ." What is it about machines that worries you?" ;
   } REPLY: COMPUTER

   { :: CR ." What is OK about it?" ;
     :: CR ." Alright then." 
        CR ." Tell me about your mother" ;

      :: CR ." Is that all you have to say?" ;
      :: CR ." You are just agreeing with me now" 
      :: CR ." You need to open up to make this work." ;
    } REPLY: OK

    KEY" ALWAYS"     
    { :: CR ." Are you over-generalizing?" ;
      :: CR ." Don't you mean 'sometimes' ?" ;
      :: CR ." Really? Always?" ;
    } REPLY: ALWAYS


    { :: CR ." Really! Your " <TOPIC?> ;
      :: CR ." Do you know why your " <TOPIC?> ;

      :: 3 0 DO CR '"' ." My " <TOPIC> '"' LOOP 
         CR ." Get over it." ;
         
    } REPLY: MY

    { :: CR ." I only work in English." ;
      :: CR ." Need I remind you to speak English" ;
      :: CR ." Please use English" ;
    } REPLY: FRANCAIS

\ ALL these words respond the same
    : ITALIANO     FRANCAIS ;
    : ESPANOL      FRANCAIS ;
    : DEUTSCH      FRANCAIS ;
    : NEDERLANDS   FRANCAIS ;

    KEY" ROBOT"      
    { :: CR ." I am not a ROBOT. I am a Phsychiatrist." ;
      :: CR ." Do you have a ROBOT fetish?" ;
      :: CR ." Does it matter if I am a ROBOT?" ;
    } REPLY: ROBOT

    KEY" ROBOTS"    : ROBOTS   ROBOT ;  
    KEY" MACHINE"   : MACHINE  ROBOT ;

    KEY" HELLO"      
    { :: CR ." How do you do ... Please state your problem." ;
      :: CR ." Hello again :-)" ;
    } REPLY: HELLO

    KEY" HI"       : HI     HELLO ;
    KEY" BONJOUR"  : BONJOUR  HELLO ;

HERE H !     \ record allocation of low RAM 
JOB @ DP !   \ restore dictionary back into high RAM 

\ ------------------[ replies end ]-----------------
\ /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
