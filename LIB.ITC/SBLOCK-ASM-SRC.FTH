\ SAMS memmory access as BLOCK from Forth.  Source code   Brian Fox

NEEDS DUMP FROM DSK1.TOOLS
NEEDS MOV, FROM DSK1.ASM9900
NEEDS ELAPSE FROM DSK1.ELAPSE 

NEEDS SAMSINI  FROM DSK1.SAMSINI

HERE
VARIABLE SEG \ holds first page of active segment 

:  SEGMENT  ( n -- ) 4 LSHIFT SEG ! ;

1 SEGMENT   \ set SAMS to be in 64K above console memory. 


HEX
VARIABLE USE                       \ holds the last window used 
CREATE PAGES       0 ,    0 ,      \ SAMS page#s in the RAM
CREATE WINDOWS  2000 , 3000 ,      \ windows in Low CPU RAM

\ >REAL converts a virtual segment address to a real address
CODE >REAL ( virtual -- real_addr)
\ this does  4096 /MOD       
      TOS R5 MOV,      \ dup 
      R5 0FFF ANDI,    \ MOD 4096
      R5 PUSH,         \ push REMAINDER 
      TOS 0C SRL,      \ divide by 4096
      SEG @@ TOS ADD,  \ add start page of active segment 

\ tests to see if SAMS is already paged in       
      R0  PAGES LI,     \ WINDOW 0 search
      R0 ** TOS CMP,
      EQ IF,
            TOS 2000 LI,  \ set window 0
            *SP+ TOS ADD, \ add the offset 
            NEXT,         \ Return to Forth
      ENDIF,

            R0 INCT,       \ WINDOW 1 search
      R0 ** TOS CMP,
      EQ IF,
            TOS 3000 LI,   \ set window 1
            *SP+ TOS ADD,  \ add the offset 
            NEXT,          \ Return to Forth
      ENDIF,
\ page is not in memory ... 
\ toggle the last window used 
      W    0001 LI,
      USE @@  W XOR,
      W  USE @@ MOV,   \ update the use variable 
      W       1 SLA,   \ W 2* is index into PAGES
  TOS PAGES (W) MOV,   \ store the PAGE we will use in PAGES

\ compute SAMS register to use 
 WINDOWS (W) R1 MOV,   \ get the window to use
       R1    0B SRL,   \ divide by 2048
       R1  4000 AI,    \ convert to SAMS register address

\ turn on the SAMS card        
       R12 1E00 LI,    \ set cru address of SAMS card
              0 SBO,   \ SAMS card on
\ map in the new page 
           TOS  SWPB,  \ swap bytes on bank value
      TOS R1 ** MOV,   \ load bank into register
              0 SBZ,   \ SAMS card off

WINDOWS (W) TOS MOV,   \ return buffer on TOS

       *SP+ TOS ADD,   \ add the offset  
                NEXT,
ENDCODE
 
\ "long" memory store and fetch 
: !L    ( n virtual --) >REAL ! ;
: C!L   ( c virtual --) >REAL C! ;
: @L    ( virtual -- n) >REAL @ ;
: C@L   ( virtaul -- c) >REAL C@ ;

\ test code 
HEX 
2000 CONSTANT 4K 
-1 CONSTANT 64K 
DECIMAL 
\ write 32K cells to RAM address
: 32KRAM     32768 0 DO  I  3000  !  2 +LOOP ;  \ 4.43 

\ write 32K cells to SAMS virtual address
: 32KSAMS    32768 0 DO  I  3000 !L  2 +LOOP ;  \ 7.88
