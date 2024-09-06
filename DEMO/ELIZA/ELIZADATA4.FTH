 CR .( === ELIZA REPLY LISTS === )
 CR .(  for use with Eliza 3.0 )

 HERE JOB ! 
 HEX 2000 DP !   ( put this data in low ram )
DECIMAL
 
\
    KEY" CAN YOU"    
    { :: CR ." Don't you believe that I can " <TOPIC?> ;
      :: CR ." Perhaps you would like to be able to " <TOPIC?> ;
      :: CR ." You want me to be able to " <TOPIC?> ;
    } REPLY: CANYOU

    KEY" CAN I"      
    { :: CR ." Perhaps you don't want to " <TOPIC> '.' ;
      :: CR ." Do you want to be able to " <TOPIC?> ;
    } REPLY: CANI

    KEY" YOU ARE"    
    { :: CR ." What makes you think I am " <TOPIC?> ;
      :: CR ." Does it please you to believe that I am " <TOPIC?> ;
      :: CR ." Perhaps you would like to be " <TOPIC> '.' ;
      :: CR ." Do you sometimes wish you were " <TOPIC?> ;
    } REPLY: YOUARE

\ anytime we need new keywords with the same replies
\ we just make a synonym Forth word.
      KEY" YOU'RE"  : YOURE  YOUARE ;

    KEY" WE"      
    { :: CR ." I keep patient relationships professional." ;
      :: CR ." There is no 'We' here." CR ." You are my patient." ;
      :: CR ." No! We cannot " <TOPIC> ." !" ;

      :: CR ." Hey!!" 
         CR ." I am your doctor. Nothing more." ;
     } REPLY: WE

    KEY" IF 
    { :: CR ." Do you really think its likely that you " <TOPIC?> ;
      :: CR ." Do you wish that you " <TOPIC?> ;
      :: CR ." What do you think when you say " CR '"' <TOPIC?> '"' ; 
      :: CR ." Really-- if you " <TOPIC?> ; 
    } REPLY: IF 

    KEY" I DON'T"    
   { :: CR ." You really don't " <TOPIC?> ;
     :: CR ." Why don't you " <TOPIC?> ;
     :: CR ." Me neither. Does that matter to you?." ;
   } REPLY: IDONT

    KEY" I FEEL"     
   { :: CR ." Does that trouble you?" ;
     :: CR ." Tell me more about such feelings." ;
     :: CR ." Do you often feel " <TOPIC?> ;
     :: CR ." Do you enjoy feeling " <TOPIC?> ;
   } REPLY: IFEEL

    KEY" I HAVE"     
   { :: CR ." How long have you had "  <TOPIC?> ;
     :: CR ." I think that's normal." ;
     :: CR ." Many people have "  <TOPIC> '.' ;
   } REPLY: IHAVE

    KEY" I'VE"  : IVE   IHAVE ;

    KEY" WHY DON'T YOU"   
    { :: CR ." Do you really believe I don't " <TOPIC?> ;
      :: CR ." Perhaps in good time I will " <TOPIC>  '.' ;
      :: CR ." Do you want me to "  <TOPIC?> ;
      :: CR ." Do you think you should be able to " <TOPIC?> ;
    } REPLY: WHYDONTYOU

    KEY" WHY CAN'T I"   
    { :: CR ." I don't know, why can't you " <TOPIC?> ;
      :: CR ." Have you really tried to " <TOPIC?> ;
      :: CR ." You can. you just don't know it yet." ;
    } REPLY: WHYCANTI

    KEY" ARE YOU"    
    { :: CR ." Why are you interested in whether or not I am " <TOPIC?> ;
      :: CR ." Would you prefer if I were not "  <TOPIC?>  ;
      :: CR ." Perhaps in your fantasies I am "  <TOPIC> '.'  ;
    } REPLY: AREYOU

    KEY" I CAN'T"    
    { :: CR ." How do you know you can't "  <TOPIC?> ;
      :: CR ." Have you tried to "  <TOPIC?> ;
      :: CR ." Do you think everyone can "  <TOPIC?> ; 
    } REPLY: ICANT

    KEY" I AM"       
    { :: CR ." Did you come to me because you are " <TOPIC?> ;
      :: CR ." How long have you been " <TOPIC?> ;
      :: CR ." Do you believe it is normal to be " <TOPIC?> ;
      :: CR ." Do you enjoy being " <TOPIC?> ;
    } REPLY: IAM

    KEY" I'M"  : IM   IAM ;
    
    KEY" I NEED" 
   { :: CR ." Do you really need " <TOPIC?>   ;
     :: CR ." In my experience everybody needs " <TOPIC> '.' ;
     :: CR ." What would it mean if you got " <TOPIC?> ;
   } REPLY: INEED

    KEY" REALLY"  
   { :: CR ." Sounds serious. Tell me more." ;
     :: CR ." I have no reason to be dishonest with you." ;
     :: CR ." You don't trust me yet do you?" ;
   } REPLY: REALLY

    KEY" I REMEMBER"  
   { :: CR ." Do you often think of " <TOPIC?> ; 
     :: CR ." Does thinking of " <TOPIC> ." bring anything else to mind?" ;
     :: CR ." What else do you remember?" ;
     :: CR ." Why do you recall " <TOPIC> ." right now?" ;
     :: CR ." What in the present situation reminds you of " <TOPIC?> ;
     :: CR ." What is the connection between me and " <TOPIC?> ;
   } REPLY: IREMEMBER

    KEY" DO YOU REMEMBER"   
   { :: CR ." Did you think I would forget " <TOPIC?> ;
     :: CR ." Why do you think I should recall " <TOPIC> ." now" ;
     :: CR ." What about " <TOPIC?> ." You mentioned " <TOPIC> ;
   } REPLY: DOYOUREMEMBER 

    KEY" YOU"        
   {  :: CR ." We were discussing you -- not me." ;
      :: CR ." Let's keep talking about your issues." ;
      :: CR ." You're not really talking about me, are you?" ;
   } REPLY: YOU

    KEY" I WANT"     
   { :: CR ." What would it mean if you got " <TOPIC?>   ;
     :: CR ." Why do you want " <TOPIC?> ;
     :: CR ." Suppose you soon got " <TOPIC?> ;
     :: CR ." What if you never got " <TOPIC?> ;
     :: CR ." Sometimes i think i want " <TOPIC> '.' ;
     :: CR ." Doesn't everybody?" ;
   } REPLY: IWANT


    KEY" WHAT"    
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
    KEY" HOW"     : HOW    WHAT ;
    KEY" WHO"     : WHO    WHAT ;
    KEY" WHERE"   : WHERE  WHAT ;
    KEY" WHEN"    : WHEN   WHAT ;
    KEY" WHY"     : WHY    WHAT ;


    KEY" TI-99"    
   {  :: CR ." TI-99! That's my favourite machine!" ;

      :: CR ." I sure hope you program that thing in " 
         CR ." FORTH" ;

      :: CR ." Do you have secret dreams about C64?" ;
      :: CR ." Do people tease you because your TI-99 is slow?" ;
   } REPLY: TI99

    KEY" NAME"       
   { :: CR ." Names don't interest me." ;
     :: CR ." I don't care about names. Go on." ;
   } REPLY: NAME

    KEY" CAUSE"      
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

    KEY" DREAM"      
    { :: CR ." What does that dream suggest to you?" ;
      :: CR ." Do you dream often?" ;
      :: CR ." What persons appear in your dreams?" ;
      :: CR ." Are you disturbed by your dreams?" ;
    } REPLY: DREAM

    KEY" DREAMT"  : DREAMT  DREAM ;


    KEY" MAYBE"      
    { :: CR ." You don't seem quite certain." ;
      :: CR ." Why the uncertain tone?" ;
      :: CR ." Can't you be more positivE?" ;
      :: CR ." You aren't sure?" ;
      :: CR ." Don't you know?" ;
    } REPLY: MAYBE

    KEY" NO" 
    { :: CR ." Are you saying that just to be negative?" ;
      :: CR ." You are being a bit negative." ;
      :: CR ." Why not?" ;
      :: CR ." Are you sure?" ;
      :: CR ." Why not?" ;
    } REPLY: NO

    KEY" YOUR"       
    { :: CR ." Why are you concerned about my " <TOPIC?> ;
      :: CR ." What about your own " <TOPIC?> ;
    } REPLY: YOUR

    KEY" I THINK"   
    { :: CR ." Can you think of a specific example?" ;
      :: CR ." What made you think about <TOPIC?>" ;
      :: CR ." Really, You think " <TOPIC> ." always?" ;
      :: CR ." Do you really think so?" ;
      :: CR ." But are you sure about that?" ;
      :: CR ." Do you ever doubt that " <TOPIC?> ;
    } REPLY: ITHINK

    KEY" THINK"   : THINK   ITHINK ;

    KEY" ALIKE"      
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

    KEY" OK"       
   { :: CR ." What is OK about it?" ;
     :: CR ." Alright then." 
        CR ." Tell me about your mother" ;

      :: CR ." Is that all you have to say?" ;
      :: CR ." You are just agreeing with me now" ;
      :: CR ." You need to open up to make this work." ;
    } REPLY: OK

    KEY" ALWAYS"     
    { :: CR ." Are you over-generalizing?" ;
      :: CR ." Don't you mean 'sometimes' ?" ;
      :: CR ." Really? Always?" ;
    } REPLY: ALWAYS

    KEY" MY"         
    { :: CR ." Really! Your " <TOPIC?> ;
      :: CR ." Do you know why your " <TOPIC?> ;

      :: 3 0 DO CR '"' ." My " <TOPIC> '"' LOOP 
         CR ." Get over it." ;
    } REPLY: MY

    KEY" FRANCAIS"      
    { :: CR ." I only work in English." ;
      :: CR ." Need I remind you to speak English" ;
      :: CR ." Please use English" ;
    } REPLY: FRANCAIS
\ ALL these words respond the same
    KEY" ITALIANO"    : ITALIANO     FRANCAIS ;
    KEY" ESPANOL"     : ESPANOL      FRANCAIS ;
    KEY" DEUTSCH"     : DEUTSCH      FRANCAIS ;
    KEY" NEDERLANDS"  : NEDERLANDS   FRANCAIS ;

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

DECIMAL
: END_SESSION
      CR 
      CR ." OK. Thanks for chatting."
      CR ." Bye bye!"  700 MS
      CR ." ...Oh and by the way..."
      1000 MS
      CR
      CR ." My bill is $400.00." 500 MS 
      CR ." (I accept Paypal)"  300 MS 
      CR ." :-)"   2000 MS 
      BYE ;

 \   Keyword       Forth word that is called     
    KEY" BYE"      : BYE       END_SESSION ;
    KEY" GOODBYE"  : GOODBYE   END_SESSION ;

\ bad words list
    KEY" SHIT"       
   { :: CR ." Hey now."  CR ." We don't use that kind of language here." ;
     :: CR ." I told you to watch your language!" ;
     :: CR ." That's enough! I don't have to listen to this!"
              1000 MS END_SESSION ;
   } REPLY: SHIT 

\ all these words cause SHIT to happen :-)
    KEY" SHUTUP"  : SHUTUP   CR CR ." That's rude!"  1000 MS BYE ;
    KEY" DICK"    : DICK     SHIT ;
    KEY" FUCK"    : FUCK     SHIT ;
    KEY" ASSHOLE" : ASS      SHIT ;
    KEY" BASTARD" : BASTARD  SHIT ;
    KEY" HELL"    : HELL     SHIT ;

    KEY" CONSOLE" : CONSOLE   
                    CR
                    CR ." Exiting ELIZA ..."
                    CR ." CAMEL99 FORTH"
                    CR  QUIT ;

\ =======================================================
\ A minimal set of key words are needed to compile the program

\ Replies for unknown token
    { :: CR ." What does that suggest to you?" ;
      :: CR ." I see." ;
      :: CR ." I'm not sure I understand you fully." ;
      :: CR ." Topic shift: How is your love life?" ;
      :: CR ." Can you expand on that a bit?" ;
      :: CR ." Go on ..." ;
      :: CR ." Very interesting. Tell me more." ;
      :: CR ." Are you being honest?" ;
      :: CR ." Do you feel strongly about discussing such things?" ;
    } REPLY: TAPDANCE

HERE H !     \ record allocation of low RAM 
JOB @ DP !   \ restore dictionary back into high RAM 

\ ------------------[ replies end ]-----------------
\ /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
