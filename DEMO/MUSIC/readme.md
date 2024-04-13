# Music Notation Experiment 

The files in this folder are an experiement to create a music notation system.
That was simple in Forth. Word definitions were created to identify the notes and
the notes play when executed. Other words were created using music terminology
to define "temp", dynamics ( piano, forte) and so on.  Putting these words
together in a "colon" definition gives you a word that plays a piece of music.

The second part of the project was to use the CAMEL99 Forth multi-tasker
(MTASK99) to play three lines of music simultaneously. This failed. 

 In theory we could use the cooperative multi-tasker to play three
 voices of music at the same time. In reality the TI-99 struggles to
 keep the music sycnhronized. 

 The solution is to offload some of the work to the user defined 
 interrupt service routine (ISR).  

 The ISR runs every 16 milli-seconds. The code in MUTINGISR.FTH creates four
 timers in workspace registers. It holds the "mute" code for each
 of the four sound channels in four other registers. When a timer register is loaded
 it immediately begins decrementing every 16mS. When it hits zero the ISR sends the 
 "mute" code to the sound matching chip channel. That's all it does. 

 With MUTINGISR your program is free from the job of doing the counting down
 the time to leave a sound playing on the sound chip. Rather in this system 
 your program loads the appropriate workspace register in the ISR workspace
 and then runs a "WAIT" routine that checks for the timer to hit zero.
 The magic part is that while WAIT is looping it runs PAUSE continously.
 PAUSE gives time to the next task in the multi-tasker's list of tasks.
 So the other voices in the music can do their thing. 

 Here is the code for WAIT. It is because WAIT is so simple that we can
 handle real-time syncronization of the music voices. 

 ```
: WAIT ( timer-addr -- ) 
    BEGIN DUP @   \ registers are in memory so we can use '@' to read them
    WHILE PAUSE   \ while timer<>0 give somebody else time to run
    REPEAT      
    DROP ;        \ clean up the stack 
```


