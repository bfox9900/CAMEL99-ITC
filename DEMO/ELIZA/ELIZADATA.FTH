\   === ELIZA REPLY LISTS ===
\
    ${ $" Don't you believe that i can~"
       $" Perhaps you would like to be able to~"
       $" You want me to be able to~"
     }$ REPLY: CANYOU

    ${ $" Perhaps you don't want to~"
       $" Do you want to be able to~"
     }$ REPLY: CANI

    ${ $" What makes you think i am~"
       $" Does it please you to believe that i am~"
       $" Perhaps you would like to be~"
       $" Do you sometimes wish you were~"
     }$ REPLY: YOUARE

\ anytime we need new keywords with the same replies
\ we just make a synonym Forth word.
     : YOURE  YOUARE ;

    ${ $" I keep patient relationships professional."
       $" There is no 'We' here. You are my patient."
       $" No! We cannot~"
       $" Hey! I am your doctor. Nothing more."
     }$ REPLY: WE


    ${ $" You really don't~"
       $" Why don't you~"
       $" Me neither. Does that matter to you?."
     }$ REPLY: IDONT


    ${ $" Does that trouble you?"
       $" Tell me more about such feelings."
       $" Do you often feel~"
       $" Do you enjoy feeling~"
     }$ REPLY: IFEEL

    ${ $" How long have you had~"
       $" I think that's normal."
       $" Many people have~"
     }$ REPLY: IHAVE

: I'VE   IHAVE ;

    ${ $" Do you really believe i don't~"
       $" Perhaps in good time i will~"
       $" Do you want me to~"
       $" Do you think you should be able to~"
     }$ REPLY: WHYDONTYOU

    ${ $" I don't know, why can't you~"
       $" Have you really tried to~"
       $" You can. you just don't know it yet."
     }$ REPLY: WHYCANTI

    ${ $" Why are you interested in whether or not i am~"
       $" Would you prefer if i were not~"
       $" Perhaps in your fantasies i am~"
     }$ REPLY: AREYOU

    ${ $" How do you know you can't~"
       $" Have you tried~"
       $" Do you think everyone can~"
     }$ REPLY: ICANT

    ${ $" Did you come to me because you are~"
       $" How long have you been~"
       $" Do you believe it is normal to be~"
       $" Do you enjoy being~"
     }$ REPLY: IAM

: IM   IAM ;

     ${ $" Do you really need~"
        $" In my experience everybody needs~"
        $" What would it mean if you got~"
      }$ REPLY: INEED

     ${ $" We were discussing you -- not me."
        $" Let's keep talking about your issues."
        $" You're not really talking about me, are you?"
      }$ REPLY: YOU

     ${ $" What would it mean if you got~"
        $" Why do you want~"
        $" Suppose you soon got~"
        $" What if you never got~"
        $" Sometimes i think i want~"
        $" Doesn't everybody?"
      }$ REPLY: IWANT

    ${ $" Why do you ask?"
       $" Does that question interest you?"
       $" What answer would please you the most?"
       $" What do you think?"
       $" Are such questions on your mind often?"
       $" What is it you really want to know?"
       $" Have you asked anyone else this question?"
       $" Have you asked such questions before?"
       $" What else comes to mind when you ask that?"
     }$ REPLY: WHAT

\ all questions give the same answers
         : HOW    WHAT ;
         : WHO    WHAT ;
         : WHEN   WHAT ;
         : WHERE  WHAT ;
         : WHY    WHAT ;

    ${ $" Names don't interest me."
       $" I don't care about names. Go on."
     }$ REPLY: NAME

    ${ $" Is that the real reason?"
       $" Do any other reasons come to mind?"
       $" Does that reason explain anything else?"
       $" What other reason might there be?"
     }$ REPLY: CAUSE

    ${ $" Please don't apologise."
       $" Apologies are not necessary."
       $" What feelings do you get when you apologise?"
       $" Don't be so defensive!"
     }$ REPLY: SORRY

    ${ $" What does that dream suggest to you?"
       $" Do you dream often?"
       $" What persons appear in your dreams?"
       $" Are you disturbed by your dreams?"
     }$ REPLY: DREAM

    ${ $" How do you do ... Please state your problem."
       $" Hello again :-)"
     }$ REPLY: HELLO

    : HI     HELLO ;
    : BONJOUR  HELLO ;

      ${ $" You don't seem quite certain."
         $" Why the uncertain tone?"
         $" Can't you be more positivE?"
         $" You aren't sure?"
         $" Don't you know?"
       }$ REPLY: MAYBE

      ${ $" Are you saying that just to be negative?"
         $" You are being a bit negative."
         $" Why not?"
         $" Are you sure?"
         $" Why not?"
       }$ REPLY: NO


     ${ $" Why are you concerned about my~"
        $" What about your own~"
      }$ REPLY: YOUR


      ${ $" Can you think of a specific example?"
         $" When?"
         $" What are you thinking of?"
         $" Really, always?"
         $" Do you really think so?"
         $" But are you sure you~"
         $" Do you doubt you~"
       }$ REPLY: THINK


      ${ $" In what way?"
         $" What resemblance do you see?"
         $" What does the similarity suggest to you?"
         $" What other connections do you see?"
         $" Could there really be some connection?"
         $" How?"
       }$ REPLY: ALIKE


      ${ $" You seem quite positive."
         $" Are you sure?"
         $" I see."
         $" I understand."
       }$ REPLY: YES


      ${ $" Why do you bring up the topic of friends?"
         $" Do your friends worry you?"
         $" Do your friends pick on you?"
         $" Are you sure you have any friends?"
         $" Do you impose on your friends?"
         $" Perhaps your love for friends worries you?"
         $" Do computers worry you?"
         $" Are you talking about me in particular?"
       }$ REPLY: FRIEND


      ${ $" Are you frightened by machines?"
         $" Why do you mention computers?"
         $" What do you think computers have to do with your problem?"
         $" Don't you think computers can help people?"
         $" What is it about machines that worries you?"
         $" Say, do you have any psychological problems?"
       }$ REPLY: COMPUTER


      ${ $" Alright then. Tell me about your mother"
         $" Is that all you have to say?"
         $" You are just agreeing with me now"
       }$ REPLY: OK


      ${ $" Are you over-generalizing?"
         $" Don't you mean 'sometimes' ?"
         $" Really? Always?"
       }$ REPLY: ALWAYS

    ${ $" I only work in English."
       $" Need I remind you to speak English"
       $" Please use English"
     }$ REPLY: FRANCAIS

\ ALL these words respond the same
         : NEDERLANDS   FRANCAIS ;
         : DEUTSCH      FRANCAIS ;
         : ESPANOL      FRANCAIS ;
         : ITALIANO     FRANCAIS ;
         : JE           FRANCAIS ;
         : ICH          FRANCAIS ;
         : HABLA        FRANCAIS ;
         : PARLEZ       FRANCAIS ;
         : SPRECHEN     FRANCAIS ;
         : SPREKEN      FRANCAIS ;

      ${ $" I am not a ROBOT. I am a Phsychiatrist."
         $" Do you have a ROBOT fetish?"
         $" Does it matter if I am a ROBOT?"
       }$ REPLY: ROBOT


: ROBOTS  ROBOT ;

      ${ $" Sounds serious. Tell me more."
         $" I have no reason to be dishonest with you."
         $" You don't trust me yet do you?"
       }$ REPLY: REALLY

      ${ $" Tell me about your~"
         $" How do you feel about your~"
         $" Stop talking about your~"
       }$ REPLY: MY

\ ------------------[ replies end ]-----------------
\ /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
