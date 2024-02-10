\ SAM 1M memory card INIT & common code  Nov24 2022 Brian Fox                   
\ update Feb 2024                                                               
DECIMAL                                                                         
  24 USER 'R12  \ address of R12 in any Forth workspace                         
HEX                                                                             
: SAMSCARD  ( -- ) 1E00 'R12 ! ; \ select sams card CRU addr.                   
                                                                                
HEX                                                                             
\ *set the CRU address in 'R12 before using these words*                        
  CODE 0SBO  ( -- ) 1D00 ,  NEXT, ENDCODE                                       
  CODE 0SBZ  ( -- ) 1E00 ,  NEXT, ENDCODE                                       
  CODE 1SBO  ( -- ) 1D01 ,  NEXT, ENDCODE                                       
  CODE 1SBZ  ( -- ) 1E01 ,  NEXT, ENDCODE                                       
                                                                                
: SAMS-ON   ( -- ) SAMSCARD 1SBO ;  \ enable mapper                             
: SAMS-OFF  ( -- ) SAMSCARD 1SBZ ;  \ disable mapper                            
                                                                                
HEX                                                                             
4000 CONSTANT SAMSREGS                                                          
                                                                                
\ * SAMSINI sets card to "pass-through" condition                               
\   Tests the size of the SAMS card upto 1.4 Mbytes                             
DECIMAL                                                                         
: SAMSINI ( -- )                                                                
  CR ." 1M SAMS card "                                                          
    SAMSCARD                                                                    
    0SBO                                                                        
    0                     \ register value                                      
    SAMSREGS  22 CELLS    \ registers base address, # SAMS regs                 
    BOUNDS ( -- >4030 >4000)                                                    
    DO                                                                          
        DUP >< I !    \ swap bytes and write 16 bits to reg                     
        I C@  OVER <>  ABORT" failed"                                           
        1+                                                                      
    2 +LOOP                                                                     
    DROP                                                                        
    0SBZ                                                                        
    ." initialized"                                                             
;                                                                               
                                                                                
SAMSINI                                                                         
                                                                                
                                                                                
                                                                                
