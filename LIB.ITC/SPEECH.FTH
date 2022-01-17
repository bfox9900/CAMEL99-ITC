\ SPEECH.FTH   Interface to the speech synthesize on the TI-99
      **WORK_IN_PROGRESS**
\  Binary byte  hex  Operation
\  x111xxxx      7x    Reset
\  x100aaaa      4x    Load-Address (needs 4 more bytes)
\  x101xxxx      5x    Speak
\  x110xxxx      6x    Speak-External (accepts an unlimited number of data bytes)
\  x001xxxx      1x    Read-Byte
\  x011xxxx      3x    Read-and-Branch
\  x0x0xvrr     Load-Frame-Rate (rr=rate code, v=0:use rr, 1: variable) TMS5520C only.

\

HEX
9000 CONSTANT SPCHRD
9400 CONSTANT SPCHWR

  16 CONSTANT spchread  \ 'read data' command code
  AA CONSTANT ssflag    \ 'speech synth present' check code
  50 CONSTANT spkROM    \ 'speak from ROM' command code

: 4CMD     ( nibble -- cmd ) 40 +  SPCHWR C! ;
: SPEAK    ( nibble -- )
: >NIB     ( c -- nib nib) DUP F AND SWAP 4 SRA SWAP ;

: >NIBBLES ( n -- n n n n) SPLIT >NIB SWAP >NIB  2SWAP ;

: SPCHADR!  ( addr -- )
            >NIBBLES
            0 4CMD
            4CMD 4CMD 4CMD 4CMD
            0 4CMD ;


2 BASE !
: SPCH.RESET  01110000  SPCHWR C! ;

: SPEAK       01010000  SPCHWR C! ;



;[ TALKING? ( -- flag )
; returns 0 if speech synth is idle, else returns 1
; Upon testing, it appears that the synth reports idle *just before* it really
; is finished.
; This causes a problem, as TurboForth is fast enough to start feeding new data
; immediately when it detects the synth as idle, thus chopping off the end of
; streamed speech.
; To protect against this, it uses the hardware busy signal from the synth,
; *and* the number of bytes/words currently outstanding in any data that is
; currently being fed to the synth. If either>0 then a busy is returned.
 _spkng  dect stack                  ; make space on data stack
        mov @synyes,r0              ; synth fitted?
        jeq nspk                    ; if not then just return 'not speaking'
        bl @spstat                  ; else get status from speech synth
        mov @spdata,r0              ; get the data from speech synth
        andi r0,>8000               ; isolate busy bit
        a @spcnt,r0                 ; add words/bytes remaining in speech buffer
        jeq nspk                    ; not speaking
        seto *stack                 ; speaking
        jmp sayxit                  ; return via r15
nspk    clr *stack                  ; not speaking
        jmp sayxit
;]

;[ SAY ( addr count -- )
; feeds count words to the speech synth, starting at addr. Used to speak words
; from the built in speech rom. The data fed to the synth should be the entry
; addresses of speech rom words, as found in the editor assembler manual.
_say    mov *stack+,@spcnt          ; pop speech buffer count
        mov *stack+,@spadr          ; pop speech buffer address
        mov @synyes,r0              ; check if speech synth is fitted
        jeq sayxit                  ; if not, just exit immediately
        li r0,romspk                ; else get address of rom-speak routine
        mov r0,@spcsvc              ; load into speech service routine pointer
sayxit  b @retB0
;]

;[ STREAM ( addr count -- )
; feeds addr bytes to the speech synth, starting at addr. Used to stream raw
; speech data to the speech synth.
_strem  mov *stack+,r0              ; pop speech buffer count
        sla r0,1                    ; convert to byte count
        mov r0,@spcnt               ; store it
        mov *stack+,@spadr          ; pop speech buffer address
        mov @synyes,r0              ; check if speech synth is fitted
        jeq sayxit                  ; just exit if not
        li r0,strspk                ; else get address of stream-speak routine
                                    ; (defined in 1-01-ISR.a99)
        mov r0,@spcsvc              ; load into speech service routine pointer
        jmp sayxit
;]

;[ speech support routines
; routine to see if speech synth is fitted
; on exit sets r0: 0=not detected >ffff=detected
isspch  clr @synyes                 ; assume no speech synth detected
        clr r0                      ; check address 0 in speech synth
        bl @readsp                  ; read byte from the speech synth in r0 msb
        cb r0,@ssflag               ; is the speech synth here?
        jeq spyes                   ; speech synth is detected
        jmp sayxit                  ; see ya
spyes   seto @synyes                ; found speech synth
spchx   jmp sayxit                  ; gtf outta here


; routine to read a byte from the speech synth
; Inputs: R0=address in speech synth to read
; Outputs R0=byte read from speech synth in MSB
readsp  mov r11,r8                  ; save return address
        bl @spaddr                  ; load address into speech synth (in r0)
        movb @spread,@spchwt        ; send read data command
        src r0,12                   ; 12uS delay
        clr r0                      ; prepare for byte operations
        movb @spchrd,r0             ; read the byte from the speech synth
        b *r8                       ; return to caller


; routine to load an address into the speech synth's address register
; the address to load is passed in r0
spaddr  li r2,4                     ; 4 nybbles to load
loadlp  src r0,4                    ; start with least significant nybble
        mov r0,r1                   ; copy it
        src r1,4                    ; get target nybble into correct position
        andi r1,>0f00               ; mask out the nybble of interest
        ori r1,>4000                ; put in 4x00 format for speech synth
        movb r1,@spchwt             ; send it to the speech synth
        dec r2                      ; finished?
        jne loadlp                  ; do next nybble repeat if not
        li r1,>4000                 ; signal to speech synth that we finished...
        movb r1,@spchwt             ; ...sending the address.
        rt                          ; return to caller
;]

;[ (DATA) - runtime code for DATA
_data   dect stack              ; make stack entry
        mov pc,*stack           ; current address to stack
        inct *stack             ; plus 2
        dect stack              ; stack entry
        mov *pc+,r1             ; number of data items...
        mov r1,*stack           ; ...to stack
        sla r1,1                ; compute byte offset past data
        a r1,pc                 ; adjust program counter
        b @retB0
;]
