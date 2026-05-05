; THE SPEAKER
; Published by Superior Software as SPEECH 1986
; Republished by Xavier Grossetete in CPC Infos 1991
; Retyped by NoRecess 2011
; ROM version by Chris Perver 2026

; FUNCTION CALLS
txt_output equ &bb5a
kl_curr_selection equ &b912

; IY OFFSETS
phonemeptr1         equ 0
phonemeptr2         equ 1
tonedelay           equ 2
speed               equ 3
option4             equ 4
option5             equ 5
option6             equ 6
option7             equ 7
option8             equ 8
outchannel          equ 9
option10            equ 10
option11            equ 11
option12            equ 12
option13            equ 13
option14            equ 14
option15            equ 15
option16            equ 16
option17            equ 17
option18            equ 18
option19            equ 19
option20            equ 20
option21            equ 21
option22            equ 22
option23            equ 23
initializevariable  equ 24

; BACKUP OF ORIGINAL BB5A JUMP BLOCK ADDRESS
orig_txt_output_1   equ 25
orig_txt_output_2   equ 26
orig_txt_output_3   equ 27
orig_txt_output_4   equ 28
sponenabled         equ 29
; FAR CALL ADDRESS BLOCK DATA
far_call_block_1    equ 30 ; ROUTINE ADDRESS IN ROM TO CALL
far_call_block_2    equ 31 ; ROUTINE ADDRESS IN ROM TO CALL
rombanknumber       equ 32
; COUNTER VARIABLE FOR COPYING OUTPUT CHARS
txt_counter         equ 33
phonemestringbuffer equ 34

textbuffer          equ phonemestringbuffer+100

org #C000
nolist

defb 1     ; EXPANSION TYPE
defb 1,2,0 ; VERSION

; RSX JUMP TABLE
defw name_table
jp initialize
jp setspeed             ; SPEED
jp showusage            ; SHOW USAGE
jp saycommand           ; SAY
jp rawcommand           ; SAY USING PHONEMES
jp setcentrechannel
jp setleftchannel
jp setrightchannel
jp setcentrechannel
jp enablespeechoutput   ; PATCH BB5A TO RUN OUR SPEECH FUNCTION
jp disablespeechoutput  ; DISABLE PATCH

; ROM ID
msg: defb " SPEAKER ROM 1.2",10,13,0

; INITIALIZE ROM
; INPUTS
; HL = HIMEM
; C  = ROM BANK NUMBER
initialize:
  push hl
  push de

  ; PRINT ROM NAME AT RESET
  ld hl,msg
  call printline

  pop de
  pop hl
   
  ; CLAIM RAM SPACE FOR ROM
  ; HL = HIMEM
  ; DECREMENT HL UNTIL WE GET ENOUGH SPACE FOR VARIABLES

  ; LIST OF MEMORY USED BY ROM - GRAB BYTES FROM HIMEM
  ; BASIC PASSES IY TO FUNCTIONS AS START LOCATION OF RESERVED MEMORY
  ld bc,235
  sbc hl,bc
  
  scf
ret

printline:
  ld a,(hl)
  or a
  ret z
  call txt_output
  inc hl
  jr printline

; ============================================
; RSX CODE
; --------------------------------------------
      
name_table:
  defb 'CPS RO','M'+#80    ; PREFIX FOR BAD NAME
  defb 'SPEE','D'+#80
  defb 'SPHEL','P'+#80
  defb 'SA','Y'+#80
  defb 'SPEA','K'+#80
  defb 'CENTR','E'+#80
  defb 'LEF','T'+#80
  defb 'RIGH','T'+#80
  defb 'CENTE','R'+#80
  defb 'SPO','N'+#80
  defb 'SPO','F'+#80
  defb #00

usageinfo0: defb "SPEAKER Speech Synthesizer",0
usageinfo1: defb " COMMANDS:-",0
usageinfo2: defb "  |SAY,a$   - Say a string",0
usageinfo3: defb "  |SPEAK,a$ - Say using phonemes",0
usageinfo4: defb "  |SPEED,a  - Set speed 1-20",0
usageinfo5: defb "  |CENTRE   - Set centre channel",0
usageinfo6: defb "  |LEFT     - Set left channel",0
usageinfo7: defb "  |RIGHT    - Set right channel",0
usageinfo8: defb "  |SPON     - Enable speech output",0
usageinfo9: defb "  |SPOF     - Disable speech output",0

;; A = parameter count, IX = parameter address
showusage:
  call newline  
  ld hl,usageinfo0	
  call printline
  call newline  
  call newline  
  ld hl,usageinfo1	
  call printline
  call newline  
  call newline  
  ld hl,usageinfo2	
  call printline	
  call newline
  ld hl,usageinfo3	
  call printline	
  call newline
  ld hl,usageinfo4	
  call printline	
  call newline
  ld hl,usageinfo5	
  call printline	
  call newline
  ld hl,usageinfo6	
  call printline	
  call newline
  ld hl,usageinfo7	
  call printline	
  call newline
  ld hl,usageinfo8	
  call printline	
  call newline
  ld hl,usageinfo9	
  call printline	
  jp newline

newline:			;This is a newline command - different systems may need a different command (EG TI-83)
  ld a,13			;CHR(13) Carridge return
  call txt_output
  ld a,10			;CHR(10) Newline
  jp txt_output

; ============================================
; JUMP BLOCK PATCH FOR |SPON
; --------------------------------------------

enablespeechoutput:   ; PATCH BB5A TO RUN OUR SPEECH FUNCTION
  ; ONLY PATCH IF WE HAVEN'T ALREADY PATCHED
  ld a,(iy+sponenabled)
  or a
  ret nz
  
  ; SET UP FIRMWARE JUMP BLOCK PATCH VARIABLES
  ; SAVE FUNCTION ADDRESS OF SAY COMMAND
  ld hl,txt_output_replacement
  ld (iy+far_call_block_1),hl
  ; SAVE ROM BANK NUMBER IN USE WHERE FUNCTION RESIDES
  call kl_curr_selection
  ld (iy+rombanknumber),a

  ; BACK UP ORIGINAL BB5A TXT_OUTPUT
  ld a,(txt_output) 
  ld (iy+orig_txt_output_1),a  
  ld a,(txt_output+1) 
  ld (iy+orig_txt_output_2),a  
  ld a,(txt_output+2) 
  ld (iy+orig_txt_output_3),a  
  ld a,(txt_output+3) 
  ld (iy+orig_txt_output_4),a  

  ; PATCH IN OUR JUMP BLOCK
  ld a,&DF                 ; RST 3 - FAR CALL (CALL ROM FUNCTION)
  ld (txt_output),a
  ; ADDRESS
  push iy
  pop hl
  ld bc,far_call_block_1
  add hl,bc
  ld (txt_output+1),hl
  ld a,&C9                    ; RET - STOPS &BB5D GETTING CALLED AFTER OUR FUNCTION
  ld (txt_output+3),a
  
  ld (iy+sponenabled),1
ret

disablespeechoutput:  ; DISABLE PATCH
  ; RESTORE ORIGINAL BB5A JUMP BLOCK
  ld a,(iy+orig_txt_output_1)
  ld (txt_output),a
  ld a,(iy+orig_txt_output_2)
  ld (txt_output+1),a
  ld a,(iy+orig_txt_output_3)
  ld (txt_output+2),a
  ld a,(iy+orig_txt_output_4)
  ld (txt_output+3),a
  
  ld (iy+sponenabled),0
ret

; Entry - A = character to print
; PRESERVE HL
txt_output_replacement:
  ; PRESERVE HL
  push hl
  ; COPY CHAR INTO BUFFER
  ; GET BUFFER POSITION
  push iy
  pop hl
  ld bc,textbuffer          
  add hl,bc
  ; GET CHAR OFFSET IN BUFFER
  ld b,0
  ld c,(iy+txt_counter)
  add hl,bc
  ld (hl),a ; WRITE CHAR IN BUFFER
  inc c
  ld (iy+txt_counter),c
  
  ; IF CHARACTER IS 0A (CR)
  ; THEN WE RESET TXT_COUNTER AND TELL OUR ROM TO SPEAK THE PHRASE
  
  cp &0D ; LINE FEED
  jr nz,skiplinefeed
  ld (hl)," " ; END WITH SPACE - AFFECTS PRONUNCIATION OF SOME WORDS IN DICTIONARY
  inc hl
  ld (hl),a   ; WRITE CHAR IN BUFFER
  inc (iy+txt_counter)
  
  skiplinefeed:
  cp &0A ; CARRIAGE RETURN
  ; WE REACHED END OF LINE, RESET TEXT COUNTER TO ZERO
  jr nz,skipresettextcount 
  
  ld (iy+txt_counter),0
  call dosaycommand
  ld a,&0A
  
  skipresettextcount:
  pop hl
  
  ; CONTINUE NORMAL PRINT CHAR FUNCTION
  ; CALL ORIGINAL &BB5A TXT OUTPUT
  push iy
  pop ix
  push bc
  ld bc,orig_txt_output_1
  add ix,bc
  pop bc
  jp (ix)

; ============================================
; SPEECH CODE
; --------------------------------------------

; SET START VARIABLES FOR SPEECH CODE

initializevariables:
  ld a,(iy+initializevariable)  ; HAVE WE INITIALIZED
  or a
  ret nz
  ld (iy+initializevariable),1  ; SET THAT WE HAVE INITIALIZED
  ld (iy+tonedelay),#12 
  ld (iy+speed),#12 ;(pitch)
  ld (iy+option4),4 ;(l8836),a

  ld (iy+option5),#65;a(l8839),a
  ld (iy+option6),#25;a;(l883a),a
  ld (iy+option7),#63;a;(l883b),a
  
  ld (iy+option8),#53 ;(l8842)
  ld (iy+outchannel),9 
ret
;tonedelay:          defb #12                 ; ALTERED PITCH VARIABLE FOR QUESTIONS ETC
;pitch:              defb #12                 ; MAIN PITCH VARIABLE
;l8834:              defw 0 ; l9863 ; b #63,#98   ; PTR TO SOUND SAMPLE?
;l8836:              defb #04                 ; DURATION OF SOUND?

;l8839:              defb #4c

;l883a:              db #27
;l883b:              db #4e
;l883c:              defw 0;b #1d,#87        ; BACKUP PTR TO BUFFER?
;l883e:              defw 0;b #00,#00
;l8840:              defw 0;db #19,#87       ; PTR TO BUFFER?
;l8842:              db #53                  ; COPY OF LAST LETTER OF WORD?
;outchannel:         db #09                  ; OUTPUT CHANNEL

start:
  call initializevariables ; SOUND WON'T PLAY UNLESS WE SET THESE
  di
  ;ld hl,phonemestringbuffer    ; PHONEME LIST TO SPEAK
  ; GET PHONEME STRING BUFFER POSITION
  push iy
  ld de,phonemestringbuffer;25          
  add iy,de      
  push iy
  pop hl
  pop iy
  
  ;ld (phonemeptr),hl
  ld (iy+phonemeptr1),l
  ld (iy+phonemeptr2),h
  l8820:
    ;ld hl,(phonemeptr)
    ld l,(iy+phonemeptr1)
    ld h,(iy+phonemeptr2)
    ;ld (l883c),hl
    ld (iy+option12),l
    ld (iy+option13),h
    ld a,(hl)
    cp #0d                     ; END OF PHONEME STRING?
    jr z,finishedspeech;l8830
    call l8a42
  jr l8820
  finishedspeech: ;.l8830
  ei
ret

; ===============================================
; DATA AREA
; -----------------------------------------------

;phonemeptr:         defw 0 ;l871d ; #1d,#87  ; PTR TO BUFFER?
;tonedelay:          defb #12                 ; ALTERED PITCH VARIABLE FOR QUESTIONS ETC
;pitch:              defb #12                 ; MAIN PITCH VARIABLE
;l8836:              defb #04                 ; DURATION OF SOUND?
;l8839:              defb #4c
;l883a:              db #27
;l883b:              db #4e
;l8842:              db #53                  ; COPY OF LAST LETTER OF WORD?
;outchannel:         db #09                  ; OUTPUT CHANNEL
;l8834:              defw 0 ; l9863 ; b #63,#98   ; PTR TO SOUND SAMPLE?
;l883c:              defw 0;b #1d,#87        ; BACKUP PTR TO BUFFER?
;l883e:              defw 0;b #00,#00
;l8840:              defw 0;db #19,#87       ; PTR TO BUFFER?

; DATA?

;l99be: defw 0     ; PTR TO BUFFER b #06,#9b
;l99c0: defw 0     ; PTR TO DICTIONARY ;db #f2,#a0
;l99c2: defb 0     ; COPY OF LETTER ;db #59

;l98b1: defb 0;#ad,#98,#b2,#98,#00

;phonemestringbuffer equ &8716 ; 100 BYTES - DATA BUFFER FOR PHONEMES
;textbuffer          equ &9afe ; 100 BYTES - DATA BUFFER FOR STRING


; INPUT
; A = 
l8844: ; MAKE SOUND
  ld b,#f4 
  out (c),a
  ld b,#f6
  ld a,#80
  out (c),a
  xor a
  out (c),a
ret

; INPUT
; E = REGISTER
l8852: ; SELECT SOUND CHANNEL
  ld b,#f6
  ld a,#c0
  out (c),a
  ld b,#f4
  out (c),e
  ld b,#f6
  xor a
  out (c),a
ret

l8862:
  ld hl,l9863
  call l88f9
ret

l8869:
  ld a,#03
  call l8862
ret

l886f:
  call l8ee4
  ld a,(hl)
  cp #31
  ret c
  cp #39
  ret nc
  sub #30
  push hl
  ld h,a
  ld a,(iy+tonedelay)
  add h
  sub 4
  ld (iy+tonedelay),a
  pop hl
  inc hl
  ;ld (phonemeptr),hl
  ld (iy+phonemeptr1),l
  ld (iy+phonemeptr2),h
ret


l888c:
  ld (iy+option4),a;(l8836),a
  ;ld (l8834),hl
  ld (iy+option10),l
  ld (iy+option11),h
  ld e,1 ; TONE UPPER CHANNEL A
  call l8852
  xor a
  call l8844
  ld e,0 ; TONE LOWER CHANNEL A
  call l8852
  xor a
  call l8844
  ld e,7 ; SET MIXER
  call l8852
  ld a,#3e
  call l8844
  ld e,(iy+outchannel)
  ;ld e,a
  call l8852
  ld a,(iy+option4);(l8836)
  add a
  add a
  add a
  ld d,a
  l88bc:
  call l8a17
  and #3f
  ld c,a
  ;ld hl,(l8834)
  ld l,(iy+option10)
  ld h,(iy+option11) 
  
  xor a
  ld b,0
  adc hl,bc
  ld e,8
  l88cc:
  ld a,(hl)
  nop
  nop
  nop
  and #0f
  call l8844
  
  ld b,(iy+tonedelay)
  ;ld b,a
  l88d9:
  djnz l88d9       ; DELAY TO MAKE SOUND LAST LONGER
  
  ld a,(hl)
  sra a
  sra a
  sra a
  sra a
  and #0f
  call l8844
  
  ld b,(iy+tonedelay)
  ;ld b,a
  l88ed:
  djnz l88ed       ; DELAY TO MAKE SOUND LAST LONGER
  
  inc hl
  dec e
  jp nz,l88cc
  dec d
  jp nz,l88bc
ret

l88f9:
  ld (iy+option4),a;(l8836),a
  ;ld (l8834),hl ; STORE SOUND SAMPLE PTR
  ld (iy+option10),l
  ld (iy+option11),h
  ld e,1        ; TONE UPPER CHANNEL A
  call l8852
  xor a
  call l8844
  ld e,0        ; TONE LOWER CHANNEL A
  call l8852
  xor a
  call l8844
  ld e,7        ; SET MIXER
  call l8852
  ld a,#3e
  call l8844
  ld e,(iy+outchannel)
  ;ld e,a
  call l8852
  ld d,(iy+option4);(l8836)
  ;ld d,a
  l8926:
  ;ld hl,(l8834)  ; RESTORE SOUND SAMPLE PTR TO HL
  ld l,(iy+option10)
  ld h,(iy+option11)
  ld e,#3f
  l892b:
  ld a,(hl)
  and #0f
  call l8844
  
  ld b,(iy+tonedelay)
  ;ld b,a
  l8935:
  djnz l8935     ; DELAY TO MAKE SOUND LAST LONGER
  
  ld a,(hl)
  sra a
  sra a
  sra a
  sra a
  and #0f
  call l8844
  
  ld b,(iy+tonedelay)
  ;ld b,a
  l8949:
  djnz l8949     ; DELAY TO MAKE SOUND LAST LONGER
  
  nop
  nop
  nop
  inc hl
  dec e
  jp nz,l892b
  dec d
  jp nz,l8926
ret

; SOUND SAMPLE DATA

l8958:
db #74,#ff,#ff,#04,#30,#fb,#cf,#88
db #88,#78,#45,#95,#cd,#6a,#44,#85
db #aa,#68,#65,#76,#88,#88,#88,#68
db #55,#86,#a9,#8a,#56,#65,#87,#a8
db #cb,#8a,#56,#85,#ba,#8a,#78,#87
db #88,#88,#66,#55,#76,#88,#56,#54
db #65,#65,#56,#55,#44,#54,#66,#56
db #55,#65,#56,#54,#86,#46,#44
l8997: db #99
db #58,#65,#88,#48,#a3,#ab,#76,#c9
db #4a,#21,#84,#69,#44,#c7,#4a,#52
db #a9,#48,#72,#ed,#8b,#78,#55,#24
db #32,#f4,#cf,#10,#fb,#4f,#54,#98
db #68,#74,#88,#56,#85,#89,#56,#87
db #78,#76,#98,#99,#99,#89,#68,#76
db #67,#65,#98,#78,#44,#54,#b8,#ab
db #69,#55,#76,#88,#56,#65,#98
l89d7: db #96
db #78,#78,#b9,#b8,#78,#89,#76,#65
db #78,#4b,#87,#75,#8b,#b5,#76,#a8
db #a9,#44,#5d,#49,#8b,#83,#95,#78
db #1a,#6c,#7a,#c2,#b4,#55,#7b,#85
db #a8,#78,#98,#85,#87,#c4,#85,#85
db #3b,#b8,#47,#78,#a4,#94,#68,#87
db #66,#7a,#7a,#89,#67,#c8,#a6,#83
db #7b,#c5,#c1,#b4,#98,#87,#b3

l8a17:
  ld a,(iy+option5);(l8839)
  xor #65
  adc #25
  ld (iy+option5),a;(l8839),a
  push iy
  pop hl
  ; MOVE TO OFFSET 5 IN HL
  inc hl
  inc hl
  inc hl
  inc hl
  inc hl
;  ld hl,l8839
  rl (hl)
  inc hl
  rl (hl)
  inc hl
  rl (hl)
  ld a,(hl);(l8839)
  and #0f
ret

; PICK PHONEME?
l8a42:
  ld a,(iy+speed);(pitch)
  ld (iy+tonedelay),a
  ;ld hl,(phonemeptr)
  ld l,(iy+phonemeptr1)
  ld h,(iy+phonemeptr2)
  ld a,(hl)
  cp #41 ; A
  jp z,sound_a
  cp #55 ; U
  jp z,sound_u
  cp #49 ; I
  jp z,sound_i
  cp #45 ; E
  jp z,sound_e
  cp #4f ; O
  jp z,sound_o
  cp #53 ; S
  jp z,sound_s
  cp #2f ; /
  jp z,sound_slash
  cp #44 ; D
  jp z,sound_d
  cp #43 ; C
  jp z,sound_c
  cp #54 ; T
  jp z,sound_t 
  cp #4e ; N
  jp z,sound_n
  cp #5a ; Z
  jp z,sound_z
  cp #42 ; B
  jp z,sound_b
  cp #46 ; F
  jp z,sound_f
  cp #47 ; G
  jp z,sound_g
  cp #4a ; J
  jp z,sound_j
  cp #4b ; K
  jp z,sound_k
  cp #4c ; L
  jp z,sound_l
  cp #4d ; M
  jp z,sound_m
  cp #50 ; P
  jp z,sound_p
  cp #52 ; R
  jp z,sound_r
  cp #56 ; V
  jp z,sound_v
  cp #57 ; W
  jp z,sound_w
  cp #59 ; Y
  jp z,sound_y
  cp #25 ; %
  jr z,sound_percent
  inc hl
  ;ld (phonemeptr),hl
  ld (iy+phonemeptr1),l
  ld (iy+phonemeptr2),h
  ld a,4
  call l8862
ret

sound_percent:
  inc hl
  ;ld (phonemeptr),hl
  ld (iy+phonemeptr1),l
  ld (iy+phonemeptr2),h
  ld a,2
  call l8862
ret

sound_a:
  inc hl
  ld b,(hl)
  inc hl
  ;ld (phonemeptr),hl
  ld (iy+phonemeptr1),l
  ld (iy+phonemeptr2),h
 
  call l886f
  ld a,b
  cp #59 ; Y
  jr z,sound_a_y
  cp #45 ; E
  jr z,sound_a_e
  cp #41 ; A
  jr z,sound_a_a
  cp #57 ; W
  jr z,sound_a_w
  cp #48 ; H
  jr z,sound_a_h
  cp #4f ; O
  jr z,sound_a_o
  cp #49 ; I
  jr z,sound_a_i
  dec hl
  ;ld (phonemeptr),hl
  ld (iy+phonemeptr1),l
  ld (iy+phonemeptr2),h
ret

sound_a_i:
  ld hl,l8f83
  ld a,9
  call l88f9
ret

sound_a_o:
  ld hl,l9043
  ld a,9
  call l88f9
ret

sound_a_h:
  ld hl,l9182
  ld a,7
  call l88f9
ret

sound_a_y:
  ld hl,l9311
  ld a,9
  call l88f9
  ld hl,l9392
  ld a,5
  call l88f9
  ld hl,l9353
  ld a,2
  call l88f9
ret

sound_a_w:
  ld hl,l8958
  ld a,9
  call l88f9
  ld hl,l92d2
  ld a,6
  call l88f9
ret

sound_a_e:
  ld hl,l8958
  ld a,7
  call l88f9
ret

sound_a_a:
  ld hl,l8f43
  ld a,9
  call l88f9
ret

sound_e:
  inc hl
  ld b,(hl)
  inc hl
  ;ld (phonemeptr),hl
  ld (iy+phonemeptr1),l
  ld (iy+phonemeptr2),h
  call l886f
  ld a,b
  cp #45 ; E
  jr z,sound_e_e
  cp #48 ; H
  jr z,sound_e_h
  cp #52 ; R
  jr z,sound_e_r
  dec hl
  ;ld (phonemeptr),hl
  ld (iy+phonemeptr1),l
  ld (iy+phonemeptr2),h
ret

sound_e_r:
  ld hl,l9510
  ld a,9
  call l88f9
ret

sound_e_e:
  ld hl,l9083
  ld a,7
  call l88f9
ret

sound_e_h:
  ld hl,l97e3
  ld a,7
  call l88f9
ret

sound_i:
  inc hl
  ld b,(hl)  
  inc hl
  ;ld (phonemeptr),hl
  ld (iy+phonemeptr1),l
  ld (iy+phonemeptr2),h
  call l886f
  ld a,b
  cp #59 ; Y
  jr z,sound_i_y
  cp #58 ; X
  jr z,sound_i_x
  cp #48 ; H
  jr z,sound_i_h
  dec hl
;  ld (phonemeptr),hl
  ld (iy+phonemeptr1),l
  ld (iy+phonemeptr2),h
ret

sound_i_h:
  ld hl,l9392
  ld a,7
  call l88f9
ret

sound_i_y:
  ld hl,l8f43
  ld a,9
  call l88f9
  ld hl,l9392
  ld a,6
  call l88f9
ret

sound_i_x:
  ld hl,l9392
  ld a,5
  call l88f9
ret

sound_o:
  inc hl
  ld b,(hl)
  inc hl
  ;ld (phonemeptr),hl
  ld (iy+phonemeptr1),l
  ld (iy+phonemeptr2),h
  call l886f
  ld a,b
  cp #57 ; W
  jr z,sound_o_w
  cp #59 ; Y
  jr z,sound_o_y
  cp #48 ; H
  jr z,sound_o_h
  cp #4f ; O
  jr z,sound_o_o
  dec hl
;  ld (phonemeptr),hl
  ld (iy+phonemeptr1),l
  ld (iy+phonemeptr2),h
ret

sound_o_o:
  ld hl,l94d0
  ld a,8
  call l88f9
ret

sound_o_w:
  ld hl,l9491
  ld a,9
  call l88f9
  ld hl,l92d2
  ld a,5
  call l88f9
ret

sound_o_y:
  ld hl,l9043
  ld a,9
  call l88f9
  ld hl,l9392
  ld a,4
  call l88f9
  ld hl,l9353
  ld a,2
  call l88f9
ret

sound_o_h:
  ld hl,l9491
  ld a,8
  call l88f9
ret

sound_u:
  inc hl
  ld b,(hl)
  inc hl
  ;ld (phonemeptr),hl
  ld (iy+phonemeptr1),l
  ld (iy+phonemeptr2),h
  call l886f
  ld a,b
  cp #58 ; X
  jr z,sound_u_x
  cp #57 ; W
  jr z,sound_u_w
  cp #48 ; H
  jr z,sound_u_h
  cp #55 ; U
  jr z,sound_u_u
  dec hl
;  ld (phonemeptr),hl
  ld (iy+phonemeptr1),l
  ld (iy+phonemeptr2),h
ret

sound_u_u:
  ld hl,l9761
  ld a,8
  call l88f9
ret

sound_u_h:
  ld hl,l9823
  ld a,7
  call l88f9
ret

sound_u_w:
  ld hl,l9003
  ld a,7
  call l88f9
  ld hl,l92d2
  ld a,6
  call l88f9
ret

sound_u_x:
  ld hl,l9003
  ld a,8
  call l88f9
ret

sound_slash:
  inc hl
  ld b,(hl)
  inc hl
  ;ld (phonemeptr),hl
  ld (iy+phonemeptr1),l
  ld (iy+phonemeptr2),h
  call l886f
  ld a,b
  cp #48 ; H
  jr z,sound_slash_h
  dec hl
  ;ld (phonemeptr),hl
  ld (iy+phonemeptr1),l
  ld (iy+phonemeptr2),h
ret

sound_slash_h:
  ld hl,l9252
  ld a,4
  call l888c
ret

sound_d:
  inc hl
  ld a,(hl)
  cp #48 ; H
  jp z,sound_d_h
  cp #52 ; R
  jp z,sound_d_r
  cp #55 ; U
  jp z,sound_d_u
  ;ld (phonemeptr),hl
  ld (iy+phonemeptr1),l
  ld (iy+phonemeptr2),h
  call l8869
  ld hl,l9410
  ld a,1
  call l88f9
  call l8869
ret

sound_d_h:
  inc hl
  ;ld (phonemeptr),hl
  ld (iy+phonemeptr1),l
  ld (iy+phonemeptr2),h
  ld hl,l9720
  ld a,4
  call l88f9
  ld hl,l9252
  ld a,1
  call l888c
ret

sound_d_r:
  inc hl
  ;ld (phonemeptr),hl
  ld (iy+phonemeptr1),l
  ld (iy+phonemeptr2),h
  ld hl,l96a0
  ld a,2
  call l88f9
  ld hl,l93d0
  ld a,3
  call l88f9
  ld hl,l8fc3
  ld a,7
  call l88f9
ret

sound_d_u:
  inc hl
  inc hl
  ;ld (phonemeptr),hl
  ld (iy+phonemeptr1),l
  ld (iy+phonemeptr2),h
  ld hl,l96a0
  ld a,5
  call l88f9
  ld hl,l93d0
  ld a,2
  call l88f9
  ld hl,l9003
  ld a,8
  call l88f9
ret

sound_c:
  inc hl
  ld a,(hl)
  inc hl
  ;ld (phonemeptr),hl
  ld (iy+phonemeptr1),l
  ld (iy+phonemeptr2),h
  cp #48 ; H
  jr z,sound_c_h
  cp #54 ; T
  jr z,sound_c_t
  dec hl
  ;ld (phonemeptr),hl
  ld (iy+phonemeptr1),l
  ld (iy+phonemeptr2),h
ret

sound_c_t:
  ld hl,l96a0
  ld a,2
  call l88f9
  ld hl,l8997
  ld a,1
  call l88f9
  ld hl,l96a0
  ld a,1
  call l88f9
  ld hl,l89d7
  ld a,1
  call l88f9
ret

sound_c_h:
  ld hl,l96a0
  ld a,6
  call l88f9
  ld hl,l9550
  ld a,3
  call l88f9
  ld hl,l8958
  ld a,1
  call l88f9
ret

sound_t:
  inc hl
  ld a,(hl)
  cp #48 ; H
  jr z,sound_t_h
  cp #52 ; R
  jr z,sound_t_r
  ;ld (phonemeptr),hl
  ld (iy+phonemeptr1),l
  ld (iy+phonemeptr2),h
  ld a,3
  call l8862
  ld hl,l89d7
  ld a,1
  call l88f9
  call l8869
ret

sound_t_h:
  inc hl
  ;ld (phonemeptr),hl
  ld (iy+phonemeptr1),l
  ld (iy+phonemeptr2),h
  ld hl,l96e0
  ld a,5
  call l888c
ret

sound_t_r:
  inc hl
  ;ld (phonemeptr),hl
  ld (iy+phonemeptr1),l
  ld (iy+phonemeptr2),h
  ld hl,l96a0
  ld a,4
  call l88f9
  ld hl,l9550
  ld a,3
  call l88f9
  ld hl,l8fc3
  ld a,7
  call l88f9
ret

sound_z:

  inc hl
  ld a,(hl)
  cp #48 ; H
  jr z,sound_z_h
  ;ld (phonemeptr),hl
  ld (iy+phonemeptr1),l
  ld (iy+phonemeptr2),h
  ld hl,l9142
  ld a,5
  call l88f9
  ld hl,l95d0
  ld a,5
  call l888c
ret

sound_z_h:
  inc hl
  ;ld (phonemeptr),hl
  ld (iy+phonemeptr1),l
  ld (iy+phonemeptr2),h
  ld hl,l9353
  ld a,3
  call l88f9
  ld hl,l9550
  ld a,3
  call l888c
ret

sound_s:
  inc hl
  ld a,(hl)
  cp #48 ; H
  jr z,sound_s_h
 ; ld (phonemeptr),hl
  ld (iy+phonemeptr1),l
  ld (iy+phonemeptr2),h
  ld a,(iy+tonedelay)
  sub 2
  ld (iy+tonedelay),a
  ld hl,l95d0
  ld a,5
  call l888c
ret

sound_s_h:
  inc hl
  ;ld (phonemeptr),hl
  ld (iy+phonemeptr1),l
  ld (iy+phonemeptr2),h
  ld hl,l9550
  ld a,6
  call l888c
ret

sound_n:
  inc hl
  ld a,(hl)
  cp #58 ; X
  jr z,sound_n_x
  ;ld (phonemeptr),hl
  ld (iy+phonemeptr1),l
  ld (iy+phonemeptr2),h
  ld a,1
  call l8862
  ld hl,l9103
  ld a,7
  call l88f9
  ld a,1
  call l8862
ret

sound_n_x:
  inc hl
 ; ld (phonemeptr),hl
  ld (iy+phonemeptr1),l
  ld (iy+phonemeptr2),h
  ld hl,l9450
  ld a,7
  call l88f9
ret

sound_b:
  inc hl
  ;ld (phonemeptr),hl
  ld (iy+phonemeptr1),l
  ld (iy+phonemeptr2),h
  call l8869
  ld hl,l9212
  ld a,1
  call l88f9
  call l8869
ret

sound_r:
  inc hl
  ;ld (phonemeptr),hl
  ld (iy+phonemeptr1),l
  ld (iy+phonemeptr2),h
  ld hl,l8fc3
  ld a,7
  call l88f9
ret

sound_l:
  inc hl
 ; ld (phonemeptr),hl
  ld (iy+phonemeptr1),l
  ld (iy+phonemeptr2),h
  ld hl,l90c3
  ld a,7
  call l88f9
ret

sound_m:
  inc hl
  ;ld (phonemeptr),hl
  ld (iy+phonemeptr1),l
  ld (iy+phonemeptr2),h
  ld hl,l9142
  ld a,7
  call l88f9
ret

sound_v:
  inc hl
  ;ld (phonemeptr),hl
  ld (iy+phonemeptr1),l
  ld (iy+phonemeptr2),h
  ld hl,l91c2
  ld a,5
  call l88f9
  ld hl,l9252
  ld a,1
  call l888c
ret

sound_k:
  inc hl
  ;ld (phonemeptr),hl
  ld (iy+phonemeptr1),l
  ld (iy+phonemeptr2),h
  call l8869
  ld hl,l8997
  ld a,1
  call l88f9
  call l8869
ret

sound_p:
  inc hl
;  ld (phonemeptr),hl
  ld (iy+phonemeptr1),l
  ld (iy+phonemeptr2),h
  call l8869
  ld hl,l9292
  ld a,1
  call l88f9
  ld a,3
  call l8869
ret

sound_w:
  inc hl
  ;ld (phonemeptr),hl
  ld (iy+phonemeptr1),l
  ld (iy+phonemeptr2),h
  ld hl,l92d2
  ld a,7
  call l88f9
ret

sound_j:
  inc hl
  ;ld (phonemeptr),hl
  ld (iy+phonemeptr1),l
  ld (iy+phonemeptr2),h
  call l8869
  ld hl,l9410
  ld a,1
  call l88f9
  ld hl,l9550
  ld a,4
  call l888c
ret

sound_y:
  inc hl
 ; ld (phonemeptr),hl
  ld (iy+phonemeptr1),l
  ld (iy+phonemeptr2),h
  ld hl,l9353
  ld a,7
  call l88f9
ret

sound_f:
  inc hl
 ; ld (phonemeptr),hl
  ld (iy+phonemeptr1),l
  ld (iy+phonemeptr2),h
  ld hl,l9618
  ld a,5
  call l888c
ret

sound_g:
  inc hl
 ; ld (phonemeptr),hl
  ld (iy+phonemeptr1),l
  ld (iy+phonemeptr2),h
  call l8869
  ld hl,l9590
  ld a,1
  call l88f9
  call l8869
ret

l8ee4:
  push af
  push hl
  push de
  ;ld de,(l883c)
  ld e,(iy+option12)
  ld d,(iy+option13)
  ;ld hl,(l883e)
  ld l,(iy+option14)
  ld h,(iy+option15)
  xor a
  sbc hl,de
  ld a,h
  or l
  jr z,checkendofsentencetoneadjust
;  ld hl,(l8840)
  ld l,(iy+option16)
  ld h,(iy+option17)
  xor a
  sbc hl,de
  ld a,h
  or l
  jr z,checkendofsentencetoneadjust2
  l8eff:
  pop de
  pop hl
  pop af
ret

checkendofsentencetoneadjust:
  ld a,(iy+option8);(l8842)
  cp #3f ; ?
  jr z,raisetoneforquestion
  cp #2e ; .
  jr z,droptoneforfullstop
jr l8eff

raisetoneforquestion:
  ld a,(iy+tonedelay)
  dec a
  ld (iy+tonedelay),a
jr l8eff

droptoneforfullstop:
  ld a,(iy+tonedelay)
  inc a
  ld (iy+tonedelay),a
jr l8eff

checkendofsentencetoneadjust2:
  ld a,(iy+option8);(l8842)
  cp #3f ; ?
  jr z,raisetoneforquestion2
  cp #2e ; .
  jr z,droptoneforfullstop2
jr l8eff

raisetoneforquestion2:
  ld a,(iy+tonedelay)
  dec a
  dec a
  ld (iy+tonedelay),a
jr l8eff

droptoneforfullstop2:
  ld a,(iy+tonedelay)
  inc a
  inc a
  ld (iy+tonedelay),a
jr l8eff

; SOUND SAMPLE DATA

l8f43:
db #96,#ee,#ff,#ed,#44,#10,#52,#d9
db #ef,#bd,#58,#45,#66,#86,#88,#77
db #a8,#ba,#9b,#48,#44,#53,#a7,#cb
db #ab,#68,#55,#65,#87,#99,#89,#88
db #88,#a9,#99,#88,#78,#98,#a9,#99
db #78,#66,#87,#98,#88,#68,#66,#76
db #88,#88,#78,#67,#66,#66,#66,#66
db #66,#76,#77,#66,#67,#67,#87,#77
l8f83:
db #66,#96,#b8,#ff,#cb,#fb,#9a,#85
db #73,#78,#58,#ba,#9d,#99,#89,#88
db #44,#64,#58,#86,#a9,#aa,#88,#86
db #58,#54,#76,#87,#88,#99,#9a,#78
db #88,#67,#66,#86,#88,#9a,#ca,#aa
db #a8,#88,#86,#76,#88,#89,#88,#89
db #67,#66,#65,#65,#65,#66,#66,#66
db #56,#55,#55,#55,#44,#77,#68,#2b
l8fc3:
db #44,#75,#ea,#ff,#ac,#da,#ee,#5a
db #32,#65,#56,#55,#76,#ba,#cd,#8b
db #87,#99,#48,#22,#53,#77,#66,#97
db #aa,#ab,#8a,#66,#76,#57,#44,#75
db #98,#88,#98,#aa,#bb,#ab,#89,#87
db #88,#56,#75,#88,#88,#88,#88,#68
db #56,#55,#55,#55,#55,#55,#66,#56
db #66,#56,#55,#55,#44,#65,#66,#55
l9003:
db #44,#54,#55,#55,#76,#b9,#fd,#ff
db #ff,#ee,#de,#cd,#ab,#68,#45,#23
db #32,#44,#44,#55,#76,#a9,#ba,#bb
db #ab,#aa,#9a,#89,#68,#55,#44,#44
db #54,#65,#66,#87,#98,#a9,#aa,#aa
db #9a,#a9,#aa,#aa,#9a,#89,#88,#88
db #88,#88,#66,#55,#55,#55,#55,#45
db #44,#54,#55,#55,#45,#44,#44,#54
l9043:
db #55,#65,#66,#67,#87,#b9,#ec,#ff
db #ff,#cf,#8a,#24,#01,#31,#75,#da
db #fe,#ff,#ce,#8a,#56,#44,#54,#65
db #88,#99,#aa,#aa,#bb,#bb,#aa,#89
db #57,#45,#54,#75,#a8,#cb,#dd,#dd
db #bc,#9a,#68,#56,#55,#65,#87,#a9
db #bb,#bb,#9a,#88,#66,#55,#55,#66
db #87,#98,#99,#99,#88,#67,#56,#55
l9083:
db #35,#43,#07,#e1,#a4,#79,#bd,#e8
db #fd,#da,#cf,#db,#fb,#9a,#ab,#68
db #96,#45,#54,#25,#52,#44,#54,#56
db #65,#87,#76,#9a,#98,#aa,#99,#aa
db #89,#a9,#89,#88,#68,#86,#68,#65
db #67,#85,#77,#79,#a9,#87,#aa,#aa
db #9a,#a9,#98,#88,#88,#67,#66,#55
db #55,#55,#54,#55,#44,#45,#54,#34
l90c3:
db #55,#55,#75,#a8,#db,#fe,#ef,#be
db #8b,#68,#55,#54,#54,#55,#55,#66
db #87,#99,#aa,#ab,#aa,#89,#66,#55
db #55,#55,#65,#76,#87,#88,#99,#99
db #99,#9a,#99,#99,#98,#88,#88,#68
db #67,#67,#77,#76,#66,#66,#66,#66
db #66,#66,#66,#66,#66,#66,#66,#66
db #66,#66,#66,#66,#66,#66,#66,#55
l9103:
db #55,#66,#66,#76,#9a,#a6,#bb,#cb
db #bb,#de,#ed,#dd,#dd,#bc,#bc,#ba
db #9a,#99,#78,#68,#66,#56,#55,#55
db #55,#55,#55,#66,#65,#66,#76,#77
db #88,#88,#88,#98,#99,#aa,#aa,#aa
db #ba,#ba,#ab,#aa,#aa,#99,#89,#88
db #68,#66,#55,#55,#44,#44,#44,#44
db #44,#44,#44,#54,#45,#55,#65
l9142: db #32
db #43,#34,#43,#44,#55,#55,#65,#76
db #b9,#a8,#9a,#bb,#cd,#dd,#dd,#ee
db #ed,#dd,#dc,#bb,#ab,#99,#89,#88
db #66,#56,#55,#45,#44,#54,#55,#55
db #55,#65,#66,#87,#88,#88,#99,#99
db #aa,#aa,#ba,#ab,#bb,#ab,#bb,#bb
db #aa,#9a,#89,#88,#78,#66,#56,#55
db #44,#44,#34,#33,#33,#34,#43
l9182: db #55
db #d7,#ff,#bf,#49,#33,#67,#68,#89
db #a9,#dd,#8b,#24,#22,#95,#aa,#9a
db #89,#99,#58,#34,#54,#a7,#bb,#8a
db #68,#66,#66,#65,#97,#ba,#ab,#68
db #55,#76,#98,#89,#98,#88,#68,#56
db #75,#88,#89,#68,#66,#66,#66,#66
db #76,#88,#67,#56,#55,#76,#67,#76
db #66,#77,#66,#66,#56,#66,#67
l91c2: db #99
db #99,#99,#78,#77,#77,#67,#66,#77
db #77,#77,#98,#99,#99,#a9,#aa,#99
db #99,#99,#78,#77,#77,#67,#66,#77
db #77,#77,#98,#99,#99,#a9,#aa,#89
db #99,#99,#99,#aa,#9a,#99,#99,#89
db #77,#77,#77,#66,#76,#77,#77,#87
db #99,#99,#99,#aa,#9a,#99,#99,#89
db #77,#77,#77,#66,#76,#77,#77,#87
db #99,#99,#99,#aa,#9a,#99,#99,#89
db #77,#77,#77,#66,#76,#77,#77
l9212: db #86
db #88,#98,#88,#88,#88,#99,#89,#88
db #88,#88,#88,#99,#88,#88,#98,#99
db #88,#88,#88,#88,#88,#88,#88,#88
db #88,#88,#78,#88,#87,#77,#77,#88
db #88,#77,#87,#88,#88,#77,#66,#66
db #66,#56,#55,#55,#55,#66,#b8,#fe
db #ff,#ce,#9a,#89,#48,#24,#01,#20
db #55,#66,#56,#55,#55,#24,#00
l9252: db #88
db #88,#68,#86,#78,#97,#89,#88,#76
db #76,#88,#89,#99,#88,#68,#56,#87
db #99,#a9,#89,#66,#56,#76,#88,#88
db #89,#78,#77,#88,#88,#99,#88,#68
db #55,#75,#a9,#9a,#89,#68,#55,#66
db #86,#a9,#9a,#88,#56,#86,#88,#88
db #68,#75,#77,#98,#aa,#98,#89,#58
db #55,#66,#b9,#ab,#8a,#58,#65
l9292: db #88
db #99,#99,#a9,#da,#bc,#ed,#cd,#bb
db #cc,#dc,#fd,#ff,#ff,#ff,#ff,#ff
db #ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff
db #ff,#8c,#04,#00,#00,#00,#00,#00
db #00,#00,#00,#00,#00,#10,#32,#45
db #13,#00,#00,#00,#00,#00,#00,#00
db #00,#00,#00,#00,#00,#10,#11,#10
db #11,#11,#32,#54,#55,#76,#76
l92d2: db #44
db #55,#76,#b9,#dc,#fe,#ff,#de,#cd
db #ab,#9a,#88,#56,#45,#23,#22,#43
db #54,#86,#98,#a9,#aa,#9a,#99,#99
db #89,#88,#56,#45,#44,#54,#55,#66
db #76,#87,#88,#98,#99,#99,#a9,#aa
db #aa,#aa,#9a,#89,#78,#66,#66,#66
db #66,#56,#55,#55,#55,#66,#66,#66
db #56,#55,#55,#55,#55,#55
l9311: db #45,#b6
db #ff,#a5,#fb,#6a,#84,#95,#56,#73
db #d9,#69,#b8,#8c,#56,#66,#67,#44
db #a6,#8a,#96,#aa,#68,#65,#76,#46
db #75,#99,#88,#a9,#8a,#67,#76,#67
db #65,#97,#88,#d2,#9a,#a9,#a9,#59
db #65,#89,#55,#98,#88,#67,#66,#46
db #54,#66,#55,#66,#55,#86,#56,#76
db #56,#55,#56,#65,#45,#87,#58,#75
l9353:
db #55,#95,#54,#5c,#87,#a9,#a8,#ad
db #bb,#bd,#9d,#9f,#ab,#ab,#8a,#8b
db #88,#88,#46,#47,#44,#55,#44,#55
db #40,#65,#55,#87,#86,#97,#88,#99
db #98,#a9,#99,#9a,#98,#99,#98,#9a
db #99,#99,#98,#8a,#88,#88,#78,#68
db #66,#56,#55,#45,#54,#44,#54,#44
db #55,#54,#55,#44,#64,#54,#47
l9392: db #a4
db #58,#d5,#1f,#d7,#8f,#a5,#88,#84
db #34,#8b,#34,#b6,#5a,#b7,#6c,#89
db #89,#87,#55,#67,#44,#87,#58,#99
db #89,#99,#99,#88,#86,#88,#65,#88
db #98,#89,#ab,#9b,#b9,#89,#86,#58
db #65,#55,#54,#55,#67,#66,#88,#66
db #87,#55,#56,#64,#46,#75,#46,#84
db #59,#75,#89,#74,#67
l93d0: db #76,#66,#67
db #66,#77,#87,#77,#89,#88,#89,#89
db #89,#a8,#99,#9a,#a9,#9a,#ba,#9a
db #9a,#a9,#89,#89,#88,#79,#87,#77
db #67,#66,#67,#76,#76,#67,#77,#77
db #88,#97,#89,#99,#99,#aa,#a9,#9a
db #aa,#a9,#9a,#99,#89,#99,#87,#78
db #77,#67,#77,#12,#66,#67,#66,#77
db #87,#77,#89,#88,#89
l9410: db #3a,#fb,#98
db #6c,#a9,#a5,#5a,#89,#a8,#58,#67
db #67,#55,#55,#66,#56,#76,#88,#76
db #86,#87,#54,#55,#47,#55,#85,#65
db #66,#88,#8a,#a8,#aa,#89,#98,#89
db #67,#88,#89,#98,#ba,#ab,#ba,#bc
db #ab,#aa,#aa,#78,#87,#78,#66,#86
db #88,#87,#98,#88,#77,#78,#56,#55
db #56,#44,#54,#45,#44
l9450: db #44,#a6,#aa
db #bb,#cb,#bd,#bd,#ab,#aa,#ba,#9a
db #89,#88,#88,#88,#66,#66,#66,#66
db #67,#87,#78,#88,#88,#88,#66,#87
db #77,#77,#77,#77,#88,#88,#88,#99
db #aa,#aa,#aa,#aa,#99,#99,#99,#88
db #88,#66,#66,#55,#55,#55,#55,#55
db #55,#55,#55,#55,#55,#55,#55,#65
db #56,#55,#55,#55,#55,#45
l9491: db #66,#66
db #f7,#ff,#9e,#5b,#74,#88,#56,#54
db #75,#db,#bd,#88,#46,#b1,#58,#45
db #65,#b7,#cb,#8a,#68,#56,#76,#56
db #54,#87,#ba,#ab,#78,#77,#66,#66
db #56,#96,#da,#bd,#8b,#56,#75,#67
db #76,#98,#9a,#88,#66,#65,#77,#66
db #56,#66,#87,#66,#55,#65,#66,#56
db #65,#66,#77,#88,#67
l94d0: db #95,#db,#ff
db #ff,#4a,#02,#00,#73,#fb,#ff,#af
db #48,#23,#42,#75,#88,#99,#98,#aa
db #aa,#68,#25,#22,#53,#b8,#ed,#bd
db #69,#24,#32,#75,#a9,#ab,#9a,#88
db #88,#a9,#89,#67,#66,#87,#89,#89
db #69,#67,#66,#66,#66,#55,#66,#86
db #78,#66,#55,#55,#55,#66,#66,#66
db #66,#66,#66,#56,#45
l9510: db #67,#d7,#ff
db #ab,#cb,#ac,#89,#26,#52,#87,#56
db #86,#ba,#cb,#8b,#76,#88,#48,#44
db #55,#76,#89,#88,#b9,#ab,#88,#67
db #66,#66,#45,#75,#98,#99,#99,#99
db #ba,#8a,#87,#88,#78,#77,#76,#98
db #89,#87,#88,#78,#66,#55,#65,#66
db #65,#66,#66,#66,#56,#65,#56,#55
db #65,#56,#66,#66,#66
l9550: db #8b,#43,#97
db #3b,#93,#4c,#55,#3f,#74,#59,#58
db #c8,#03,#c7,#26,#c3,#18,#77,#7a
db #34,#c9,#82,#a1,#2b,#81,#2d,#76
db #a8,#38,#78,#7a,#e0,#48,#a6,#83
db #47,#3b,#a5,#3a,#85,#3b,#98,#64
db #89,#56,#b8,#88,#83,#67,#87,#27
db #77,#0d,#73,#5e,#72,#cc,#70,#d8
db #44,#47,#59,#98,#58
l9590: db #76,#87,#88
db #98,#99,#aa,#aa,#aa,#aa,#99,#89
db #88,#88,#77,#66,#66,#55,#45,#41
db #b7,#dc,#be,#99,#b9,#bb,#8a,#45
db #43,#54,#55,#24,#42,#65,#76,#56
db #54,#65,#77,#66,#86,#cb,#ed,#ce
db #bb,#ba,#ab,#99,#68,#65,#66,#76
db #86,#77,#87,#88,#89,#88,#78,#99
db #99,#99,#98,#99,#9a
l95d0: db #b6,#75,#5a
db #4b,#99,#b5,#58,#5b,#89,#a6,#96
db #68,#88,#a6,#78,#4a,#8b,#a5,#a5
db #4a,#4b,#b7,#b4,#7a,#4c,#87,#c3
db #78,#2c,#4b,#c5,#a4,#3a,#5b,#99
db #95,#88,#49,#b7,#b4,#68,#8a,#a7
db #b5,#78,#4c,#9a,#a5,#78,#5a,#87
db #b5,#78,#5c,#6b,#a6,#78,#5a,#a7
db #b3,#58,#2d,#89,#d5,#75,#5a,#4b
db #a4,#3a,#78,#b5,#58
l9618: db #65,#66,#6a
db #66,#a7,#98,#66,#6a,#66,#a7,#a6
db #67,#66,#68,#a6,#6a,#67,#a7,#98
db #66,#66,#a7,#9a,#a5,#86,#66,#77
db #68,#a6,#9a,#59,#66,#89,#a7,#89
db #65,#68,#86,#a6,#76,#68,#86,#66
db #aa,#68,#6a,#76,#86,#76,#7a,#66
db #a6,#6a,#7a,#66,#a6,#8a,#76,#7a
db #8a,#95,#6a,#a6,#65,#66,#6a,#66
db #a7,#6a,#66,#89,#59,#00,#89,#89
db #89,#a8,#99,#9a,#a9,#9a,#ba,#9a
db #9a,#a9,#89,#88,#79,#87,#77,#67
db #66,#67,#76,#76,#67,#77,#77,#88
db #97,#89,#99,#99,#aa,#a9,#9a,#aa
db #a9,#9a,#99,#89,#99,#87,#78,#77
db #67,#77,#76,#66,#67,#66,#77,#87
db #77,#89,#88,#89,#89,#89,#a8,#99
db #9a,#a9,#9a,#ba,#9a
l96a0: db #88,#88,#88
db #88,#88,#88,#88,#88,#88,#88,#88
db #88,#88,#88,#88,#88,#88,#88,#88
db #88,#88,#88,#88,#88,#88,#88,#88
db #88,#88,#88,#88,#88,#88,#88,#88
db #88,#88,#88,#88,#88,#88,#88,#88
db #88,#88,#88,#88,#88,#88,#88,#88
db #88,#88,#88,#88,#88,#88,#88,#88
db #88,#88,#88,#88,#88
l96e0: db #88,#88,#87
db #88,#79,#86,#88,#76,#86,#86,#66
db #66,#76,#78,#98,#88,#8a,#99,#88
db #89,#79,#7a,#8a,#99,#89,#a8,#98
db #98,#68,#88,#89,#79,#78,#78,#88
db #86,#88,#67,#68,#87,#87,#85,#67
db #7a,#88,#8a,#8b,#9a,#a9,#99,#a9
db #98,#a9,#a9,#a8,#98,#a8,#96,#86
db #76,#76,#78,#76,#66
l9720: db #67,#98,#99
db #a9,#aa,#9a,#aa,#89,#88,#78,#67
db #76,#67,#76,#87,#88,#99,#9a,#a9
db #aa,#99,#99,#89,#77,#77,#77,#66
db #76,#77,#77,#88,#88,#a9,#aa,#a9
db #aa,#89,#88,#78,#77,#77,#66,#76
db #77,#87,#99,#99,#a9,#aa,#99,#9a
db #89,#88,#77,#66,#87,#99,#99,#aa
db #aa,#a9,#9a,#88,#88,#77
l9761: db #d6,#fc
db #cd,#9c,#88,#88,#56,#44,#76,#ba
db #ab,#99,#89,#78,#56,#44,#65,#98
db #99,#99,#99,#89,#56,#45,#64,#87
db #88,#98,#99,#99,#68,#55,#65,#86
db #a9,#bb,#ab,#8a,#68,#56,#66,#87
db #88,#88,#78,#56,#55,#55,#55,#65
db #66,#66,#56,#66,#55,#55,#56,#45
db #65,#87,#88,#66,#55,#55,#98,#89
db #aa,#99,#aa,#89,#89,#67,#77,#66
db #77,#76,#88,#97,#a9,#a9,#ab,#99
db #99,#87,#78,#76,#67,#76,#77,#97
db #89,#a9,#9a,#b9,#99,#99,#78,#88
db #66,#76,#66,#87,#88,#a9,#99,#aa
db #99,#aa,#99,#9a,#88,#88,#76,#67
db #66,#77,#86,#88,#98,#98,#89,#aa
db #99,#aa,#89,#89,#67,#77,#66,#77
l97e3:
db #55,#87,#f4,#8f,#95,#8f,#23,#67
db #86,#75,#fb,#79,#b8,#29,#53,#76
db #66,#b8,#9c,#78,#88,#45,#65,#87
db #97,#aa,#89,#87,#56,#55,#76,#88
db #99,#8a,#68,#66,#55,#76,#ab,#98
db #ba,#58,#65,#56,#76,#99,#89,#88
db #68,#55,#66,#66,#98,#88,#77,#66
db #55,#56,#66,#66,#86,#57,#87,#56
l9823:
db #21,#32,#44,#44,#64,#86,#aa,#9a
db #77,#b9,#fd,#ff,#cd,#ba,#cb,#cb
db #8a,#55,#65,#a7,#aa,#89,#98,#b9
db #cc,#ab,#68,#66,#88,#78,#57,#55
db #97,#ba,#ab,#9a,#99,#aa,#9a,#68
db #66,#86,#98,#99,#db,#fd,#ff,#df
db #ab,#89,#88,#68,#55,#55,#76,#88
db #78,#56,#66,#66,#56,#34,#22,#32
l9863:
db #00,#00,#00,#00,#00,#00,#00,#00
db #00,#00,#00,#00,#00,#00,#00,#00
db #00,#00,#00,#00,#00,#00,#00,#00
db #00,#00,#00,#00,#00,#00,#00,#00
db #00,#00,#00,#00,#00,#00,#00,#00
db #00,#00,#00,#00,#00,#00,#00,#00
db #00,#00,#00,#00,#00,#00,#00,#00
db #00,#00,#00,#00,#00,#00,#00,#00

; SKIP MULTIPLE VOWELS?
l9bfe:
  cp #45      ; E
  jr z,l9c19
  cp #41      ; A
  jr z,l9c19
  cp #4f      ; O 
  jr z,l9c19
  cp #49      ; I
  jr z,l9c19
  cp #55      ; U
  jr z,l9c19
  push af
  xor a
  ld (iy+option23),a;(l98b1),a
  pop af
ret
l9c19:
  push af
  ld a,(iy+option23);(l98b1)
  or a
  jr nz,l9c31
  push hl
;  ld hl,(l8840)
  ld l,(iy+option16)
  ld h,(iy+option17)
  ;ld (l883e),hl
  ld (iy+option14),l
  ld (iy+option15),h
  pop hl
  ;ld (l8840),hl
  ld (iy+option16),l
  ld (iy+option17),h
  inc a
  ld (iy+option23),a;(l98b1),a
  pop af
ret
l9c31:
  xor a
  ld (iy+option23),a;(l98b1),a
  pop af
ret

; STRIP BAD CHARACTERS FROM STRING?
l9c37:
  ;ld hl,textbuffer ; DATA BUFFER FOR STRING
  push iy
  ld bc,textbuffer          
  add iy,bc        
  push iy
  pop hl
  pop iy
  
  l9c3a:
    ld a,(hl)
    cp #0d     ; RETURN
    ret z
    cp #5c     ; BACKSLASH
    jr z,l9c51
    cp #61     ; a
    jr c,l9c4d
    cp #7b     ; {
    jr nc,l9c4d
    sub #20
    ld (hl),a  ; WRITE VALUE OF LETTER (make start space = 0?)
    l9c4d:     ; SKIP CHARACTER
    inc hl
  jp l9c3a
  l9c51:
  ld a,#20     ; WRITE SPACE INSTEAD OF BAD CHARACTER
  ld (hl),a
  inc hl
jp l9c3a

; TABLE TRANSLATION PTRS
dict_space:   defw dict1 ; 9c58 #89,#9e
dict_numbers: defw dict2 ; 9c5a #8d,#a6
dict_letters: ;9c5c 
defw dict3 ; #7c,#a1 ; A
defw dict4 ; #f0,#a2 ; B
defw dict5 ; #75,#a4 ; C
defw dict6 ; #ff,#a5 ; D
defw dict7 ; #ad,#a3 ; E
defw dict8 ; #8e,#a3 ; F
defw dict9 ; #f4,#a0 ; G
defw dict10 ; #ba,#a5 ; H
defw dict11 ; #f2,#9d ; I
defw dict12 ; #f2,#a6 ; J
defw dict13 ; #2c,#a4 ; K
defw dict14 ; #26,#a6 ; L
defw dict15 ; #14,#a3 ; M
defw dict16 ; #36,#a1 ; N
defw dict17 ; #90,#9c ; O
defw dict18 ; #d3,#a5 ; P
defw dict19 ; #83,#a6 ; Q
defw dict20 ; #a6,#a5 ; R
defw dict21 ; #cf,#a4 ; S
defw dict22 ; #32,#a3 ; T
defw dict23 ; #29,#a5 ; U
defw dict24 ; #f6,#a6 ; V
defw dict25 ; #37,#a6 ; W
defw dict26 ; #3f,#a4 ; X
defw dict27 ; #4a,#a4 ; Y
defw dict28 ; #74,#a6 ; Z

; WORDS
dict17: 
db "OUS ",#00,"UU3S",#00
db "OCA",#00,"OW2KAH",#00
db "OCO ",#00,"OWKOW",#00
db "OCO",#00,"OWK",#00
db "OCU",#00,"OWKUU",#00
db "OQU",#00,"OWK",#00
db "OXU",#00,"OOKSUU",#00
db "O#U",#00,"OW3#",#00
db "OUGH ",#00,"OH3W",#00
db "OGY",#00,"OJEE",#00
db "OUGH",#00,"AH",#00
db "OLE ",#00,"OW2L",#00
db "OE",#00,"OW3",#00
db "OULD ",#00,"UH3D",#00
db "OXO",#00,"OOKSOW",#00
db "O#O ",#00,"OW#OW",#00
db "O#O",#00,"OW2#",#00
db "OXA",#00,"OOKSAE",#00
db "O#A",#00,"OW2#",#00
db "OCE",#00,"OWSH",#00
db "OXE",#00,"OOKS",#00
db "O#E",#00,"OW3#",#00
db "OOK",#00,"UH3K",#00
db "OU",#00,"AE2UX",#00
db "OUR",#00,"AO3R",#00
db "OIC",#00,"OYS",#00
db "O ",#00,"OW",#00
db "OA",#00,"OH3W",#00
db "ORE ",#00,"AO2R",#00
db "OW",#00,"OW",#00
db "ORI",#00,"AORIX2",#00
db "OO",#00,"UX",#00
db "OR",#00,"AOR",#00
db "OH",#00,"OH",#00
db "OOR",#00,"AO3R",#00
db "OI",#00,"OY3",#00
db "OY",#00, "OY",#00
db "OTHER",#00,"AHDHER",#00
db "ORR",#00,"OR",#00
db "O",#00,"OO",#00

dict11: 
db "ICE",#00,"IYS",#00
db "ICY",#00,"IYSEE4",#00
db "IXY",#00,"IHKSEE",#00
db "I#Y",#00,"IY#EE",#00
db "IRO",#00,"IYROO",#00
db "IY",#00,"IY",#00
db "ITLE",#00,"IYTUUL",#00
db "IED",#00,"AY3D",#00
db "IXE",#00,"IHKS",#00
db "I#E",#00,"IY3#",#00
db "IE",#00,"EE",#00
db "IGI",#00,"IX2JIH",#00
db "I ",#00,"IY4",#00
db "ISM",#00,"IX3SUUM",#00
db "IGH",#00,"IY2",#00
db "IR",#00,"ER4",#00
db "I",#00,"IH",#00

dict1:
db " DAVID ",#00," DAYVIHD",#00
db " PSY",#00," SIY",#00
db " GIVE",#00," GIHV",#00
db " YOUR ",#00," YAOR",#00
db " CHAIR ",#00," CHAIR",#00
db " WHY ",#00," WIY",#00
db " E ",#00," EE",#00
db " #ERE",#00," #EE3ER",#00
db " OUGHT",#00," AO2T",#00
db " COUGH ",#00," KOOF",#00
db " #OUGH ",#00," #AHF",#00
db " SCI",#00," SIY",#00
db " YES ",#00," YEH3S",#00
db " #IE",#00," #IY",#00
db " ABLE",#00," AY3BL",#00
db " GET",#00," GEHT",#00
db " ANY",#00," EH2NEE",#00
db " U#E",#00," YUXW#",#00
db " OUR",#00," AW3R",#00
db " ONE",#00," WOON",#00
db " TO ",#00," TUX3",#00
db " BE ",#00," BEE3",#00
db " OF ",#00," OO3V",#00
db " A ",#00," AE",#00
db " ARE ",#00," AA3R",#00
db " WOR",#00," WER3",#00
db " ME ",#00," MEE3",#00
db " GI",#00," JIY",#00
db " MY ",#00," MIY",#00
db " IS ",#00," IX4S",#00
db " SC",#00," SK",#00
db " AS ",#00," AES",#00
db " WITH ",#00," WIX3DH",#00
db " HAVE ",#00," /HAE3V",#00
db " BY ",#00," BIY1",#00
db " THIS ",#00," DHIXS",#00
db " WE ",#00," WEE3",#00
db " THEY ",#00," DHAY2",#00
db " HAS ",#00," /HAES",#00
db " THEIR ",#00," DHAI2R",#00
db " THAN ",#00," DHAE4N",#00
db " ONLY ",#00," OW3NLEE",#00
db " PEO",#00," PEE2",#00
db " SHE ",#00," SHEE3",#00
db " SAID ",#00," SAI4D",#00
db " SOME ",#00," SAH3M",#00
db " THEN ",#00," DHEH3N",#00
db " ME ",#00," MEE",#00
db " GOTO ",#00," GOWTUW",#00
db " MOST ",#00," MOW2ST",#00
db " ",#00," ",#00

dict9: 
db "GTH ",#00,"TH",#00
db "GHOTI",#00,"FIH4SH",#00
db "GUE ",#00,"G",#00
db "GOO",#00,"GUH2",#00
db "GEN",#00,"JEH3N",#00
db "GHO",#00,"GOH2W",#00
db "GG",#00,"G",#00
db "G",#00,"G",#00

dict16:
db "NGER",#00,"NXGER",#00
db "NGS ",#00,"NXZ",#00
db "NOW",#00,"NAW",#00
db "NGE",#00,"NJ",#00
db "NION",#00,"NIXUUN",#00
db "NN",#00,"N",#00
db "NG ",#00,"NX",#00
db "NG",#00,"NXG",#00
db "N",#00,"N",#00

dict3: 
db "AGE ",#00,"AYJ",#00
db "AUGH",#00,"AA3F",#00
db "AIGH",#00,"AY",#00
db "ABLE",#00,"AY3BL",#00;"AHBUUL",#00
db "ACI",#00,"AESIH",#00
db "AXI",#00,"AEKSIH",#00
db "A#I",#00,"AY3#",#00
db "ARE",#00,"AI3R",#00
db "A ",#00,"AH",#00
db "ANGE ",#00,"AY2NJ",#00
db "ANGE",#00,"AY2NJUU",#00
db "ALLY",#00,"AE2LEE",#00
db "AXA",#00,"AEKSAE",#00
db "ACA",#00,"AEKAE",#00
db "A#A",#00,"AY#",#00
db "ACE",#00,"AYS",#00
db "AXE",#00,"AEKS",#00
db "A#E",#00,"AY4#",#00
db "ACY",#00,"AYSEE",#00
db "ACH",#00,"AECH",#00
db "ACK",#00,"AEK",#00
db "ACC",#00,"AEK",#00
db "AC",#00,"AEK",#00
db "AXO",#00,"AEKSOW",#00
db "A#O",#00,"AY#",#00
db "AU",#00,"AO3",#00
db "AVI",#00,"AY2VIX",#00
db "ALK",#00,"AORK",#00
db "AR",#00,"AA3",#00
db "AF",#00,"AA2F",#00
db "AZY",#00,"AY3ZEE",#00
db "ALL",#00,"AO2L",#00
db "AXY",#00,"AEKSEE",#00
db "A#Y",#00,"AIIX#EE",#00
db "AW",#00,"AW",#00
db "AI",#00,"AY2",#00
db "AIR",#00,"AIR",#00
db "AY",#00,"AY",#00
db "AR ",#00,"AA3R",#00
db "ARR",#00,"AE3R",#00
db "A",#00,"AE",#00

dict4:
db "BBC",#00,"BEE%%BEE%SEE",#00
db "BB",#00,"B",#00
db "BEY ",#00,"BEEY",#00
db "B",#00,"B",#00

dict15:
db "MICRO",#00,"MIY3KROW",#00
db "MB ",#00,"M",#00
db "MM",#00,"M",#00
db "MPUT",#00,"MPYUWT",#00
db "M",#00,"M",#00

dict22:
db "TWO",#00,"TUW",#00
db "THREE",#00,"THREE",#00
db "TCH",#00,"CH",#00
db "TLE",#00,"TL",#00
db "TU#E",#00,"CHUW#",#00
db "TIO",#00,"SHAH",#00
db "TIA",#00,"SHIXUU",#00
db "THE ",#00,"DHUU% ",#00
db "TH",#00,"TH",#00
db "TT",#00,"T",#00
db "T",#00,"T",#00

dict8: 
db "FOUR",#00,"FAO3R",#00
db "FOOT",#00,"FUH2T",#00
db "FF",#00,"F",#00
db "F",#00,"F",#00

dict7:
db "EIGHT",#00,"AYTE",#00
db "ERY ",#00,"EH2REE",#00
db "ERR",#00,"EH2R",#00
db "ES ",#00,"S",#00
db "EFUL ",#00,"FUUL",#00
db "EADY ",#00,"AI4DEE",#00
db "EASE ",#00,"EEZ",#00
db "E ",#00,"%",#00
db "EW",#00,"IHUW",#00
db "EU",#00,"IHUH2",#00
db "EE",#00,"EE4",#00
db "ERE",#00,"AIR",#00
db "ER",#00,"ER",#00
db "EY",#00,"AY",#00
db "EA",#00,"EE3",#00
db "ED ",#00,"%D",#00
db "E",#00,"EH",#00

dict13:
db "KN",#00,"N",#00
db "KEY ",#00,"KEEY",#00
db "K",#00,"K",#00

dict26:
db "XC",#00,"KS",#00
db "X",#00,"KS",#00

dict27:
db "YS",#00,"IH2S",#00
db "YPE",#00,"IY2P",#00
db "YE ",#00,"IY",#00
db "Y ",#00,"EE",#00
db "YOU ",#00,"YUW",#00
db "Y",#00,"Y",#00

dict5:
db "CHN",#00,"KN",#00
db "CI",#00,"SIH",#00
db "CHR",#00,"KR",#00
db "COME ",#00,"KAHM",#00
db "COW",#00,"KAW",#00
db "CE ",#00,"S",#00
db "CE",#00,"SEH2",#00
db "CH",#00,"CH",#00
db "CC",#00,"K",#00
db "CK",#00,"K",#00
db "CPC",#00,"SEE PEE SEE",#00
db "C",#00,"K",#00

dict21:
db "SUPERIOR",#00,"SUX2PEE3RIHAOR",#00
db "SHALL",#00,"SHAEL",#00
db "STION",#00,"S%CHUUN",#00
db "SES ",#00,"SIXZ",#00
db "SS",#00,"S",#00
db "SIO",#00,"ZHUU",#00
db "SH",#00,"SH",#00
db "SC",#00,"SK",#00
db "S",#00,"S",#00

dict23:
db "UE ",#00,"UW6",#00
db "URE ",#00,"UH3R",#00
db "UY",#00,"IY3",#00
db "UCE",#00,"UWS",#00
db "U#E",#00,"YUW3#",#00
db "U#A",#00,"UXW#",#00
db "UCI",#00,"UWSIH",#00
db "U#I",#00,"YUXW#",#00
db "ULL",#00,"UH3L",#00
db "UH",#00,"UH",#00
db "UL ",#00,"UUL",#00
db "UAL",#00,"YUUL",#00
db "UR",#00,"ER3R",#00
db "URR",#00,"AHR",#00
db "U",#00,"AH",#00

dict20:
db "REAT",#00,"RAY3T",#00
db "RR",#00,"R",#00
db "R",#00,"R",#00

dict10:
db "HOW",#00,"/HAW2",#00
db "HE ",#00,"/HEE4",#00
db "H",#00,"/H",#00

dict18: 
db "POW",#00,"PAW3",#00
db "PROG",#00,"PROW2G",#00
db "PH",#00,"F",#00
db "PP",#00,"P",#00
db "PLY",#00,"PLIY",#00
db "PUT",#00,"PUHT",#00
db "P",#00,"P",#00

dict6: 
db "DOW",#00,"DAW2",#00
db "DO ",#00,"DUH4W",#00
db "DG",#00,"J",#00
db "DH",#00,"DH",#00
db "DD",#00,"D",#00
db "D",#00,"D",#00

dict14:
db "LE ",#00,"UUL",#00
db "LL",#00,"L",#00
db "LAW",#00,"LOOAH",#00
db "L",#00,"L",#00

dict25: 
db "WHO",#00,"/HUHW",#00
db "WAS ",#00,"WOOZ",#00
db "WHA",#00,"WOO3",#00
db "WAT",#00,"WAO4T",#00
db "WH",#00,"W",#00
db "WR",#00,"R",#00
db "WOO",#00,"WUH",#00
db "W",#00,"W",#00

dict28:
db "ZZ",#00,"Z",#00
db "ZH",#00,"ZH",#00
db "Z",#00,"Z",#00

dict19: 
db "QU",#00,"KW",#00
db "Q",#00,"K",#00

dict2:
db "0",#00,"ZIH5ROW2 ",#00
db "1",#00,"WOO3N ",#00
db "2",#00,"TUH2W ",#00
db "3",#00,"THREE3 ",#00
db "4",#00,"FAO3R ",#00
db "5",#00,"FIY3V ",#00
db "6",#00,"SIH4KS ",#00
db "7",#00,"SEH3VUUN ",#00
db "8",#00,"AY3T ",#00
db "9",#00,"NIY3N ",#00
db "#",#00,"#",#00

dict12: 
db "J",#00,"J",#00

dict24: 
db "V",#00,"V",#00
db #00,#00,#00,#00
db #07,#00

; ===============================================
; MAIN PROGRAM
; -----------------------------------------------

; SET OUTPUT CHANNEL A
setleftchannel:
  or a
  jr nz,displaysyntaxerror
  ld a,#08  ; CHANNEL A
  ld (iy+outchannel),a
ret
; SET OUTPUT CHANNEL B
setcentrechannel:
  or a
  jr nz,displaysyntaxerror
  ld a,#0a  ; CHANNEL B
  ld (iy+outchannel),a
ret
; SET OUTPUT CHANNEL C
setrightchannel:
  or a
  jr nz,displaysyntaxerror
  ld a,#09  ; CHANNEL C
  ld (iy+outchannel),a
ret

; SET SPEED
setspeed:
  cp #01                    ; DO WE HAVE AN ARGUMENT?
  jr nz,displaysyntaxerror
  ld a,(ix+#01)
  or a
  jr nz,displaysyntaxerror
  ld a,(ix+#00)
  or a
  jr z,displaysyntaxerror
  cp #15                   ; IS VALUE OVER 20? 
  jr nc,displaysyntaxerror
  cpl
  add #1a
  ld (iy+speed),a;(pitch),a
ret

; ERROR MESSAGES
l9922: db "Syntax error."
l992f: db "Line too long."

displaysyntaxerror:
  ld hl,l9922
  jr l9948
displaylinetoolong:
  pop hl
  pop hl
  pop hl

  ld hl,l992f
  l9948:
  ld a,(hl)

  ; PRINT STRING
  printmessageloop:
    call txt_output ; PRINT CHAR
    inc hl
    ld a,(hl)
    cp #2e          ; FULL STOP
  jr nz,printmessageloop
  ; MAKE CARRIAGE RETURN IN BASIC
  ld a,#0d
  call txt_output ; PRINT CHAR
  ld a,#0a
  call txt_output ; PRINT CHAR
  ld a,#07
  call txt_output ; PRINT CHAR
ret

; STARTS AT $9962 BUT IS NOT CALLED FROM MAIN CODE
; PERFORMS SAME FUNCTION AS BELOW, ONLY LEAVES TEXT UNMODIFIED
; USED FOR ENTERING RAW PHONEME DATA
rawcommand:
  cp #01 ; DO WE HAVE AN ARGUMENT?
  jr nz,displaysyntaxerror
  ld l,(ix+#00)
  ld h,(ix+#01)
  ld a,(hl)
  or a
  ret z
  inc hl
  ld c,(hl)
  inc hl
  ld b,(hl)
  
  ;ld hl,phonemestringbuffer
  ; GET PHONEME STRING BUFFER POSITION
  push iy
  ld de,phonemestringbuffer          
  add iy,de      
  push iy
  pop hl
  pop iy
  
  ld d,a
  l9977:
    ld a,(bc)
    ld (hl),a
    inc hl
    inc bc
    dec d
  jr nz,l9977
  ld a,#0d ; EOL
  ld (hl),a
  
  ;ld hl,phonemestringbuffer
  ; GET PHONEME STRING BUFFER POSITION
  push iy
  ld de,phonemestringbuffer          
  add iy,de      
  push iy
  pop hl
  pop iy
  
  call l9c3a
  call start
ret

; STANDARD SAY COMMAND, MODIFIES INPUT STRING
; READ STRING IN A$. CALLED FROM &998B,A$
saycommand:
  cp #01          ; DO WE HAVE AN ARGUMENT SUPPLIED?
  jr nz,displaysyntaxerror
  ld h,(ix+#01)   ; GET PTR TO STRING FROM IX
  ld l,(ix+#00)
  ld a,(hl)
  or a
  ret z
  inc hl
  
  ;ld bc,textbuffer ; DATA BUFFER FOR STRING
  push iy
  ld de,textbuffer          
  add iy,de        
  push iy
  pop bc
  pop iy
  
  ld e,(hl)
  inc hl
  ld d,(hl)
  ex de,hl
  
  ld d,a 
  ld a,#20        ; INSERT SPACE
  ld (bc),a
  inc bc
  l99a5:
    ld a,(hl)
    ld (bc),a
    inc hl
    inc bc
    dec d
  jp nz,l99a5
  ld a,#20        ; INSERT SPACE
  ld (bc),a
  inc bc
  ld a,#0d        ; EOL
  ld (bc),a
  dosaycommand:
  call l9c37      ; STRIP BAD CHARACTERS FROM STRING?
  call l9ae7      ; FIND LAST LETTER OF WORD?
  call l99c3      ; SAY PHONEME?
ret

l99c3:
;  ld hl,textbuffer ; DATA BUFFER FOR STRING
  push iy
  ld de,textbuffer          
  add iy,de      
  push iy
  pop hl
  pop iy  
  
  ;ld (l99be),hl
  ld (iy+option18),l
  ld (iy+option19),h  
  ld hl,0
  ;ld (l8840),hl
  ld (iy+option16),l
  ld (iy+option17),h
  ;ld (l883e),hl
  ld (iy+option14),l
  ld (iy+option15),h
  
  ;ld hl,phonemestringbuffer
  ; GET PHONEME STRING BUFFER POSITION
  push iy
  ld de,phonemestringbuffer          
  add iy,de      
  push iy
  pop hl
  pop iy
  
 ; ld (phonemeptr),hl
  ld (iy+phonemeptr1),l
  ld (iy+phonemeptr2),h
  ld d,0
  call l99e7
  ;ld hl,(phonemeptr)
  ld l,(iy+phonemeptr1)
  ld h,(iy+phonemeptr2)
  ld a,#0d
  ld (hl),a
  call start
ret

l99e7:
  call l9aa2 ; IS THIS EOL?
  ret c
  call l99f4
  call l9aae
jp l99e7

l99f4:
  ;ld hl,(l99be)
  ld l,(iy+option18)
  ld h,(iy+option19)
  
  ld a,(hl)
  cp #41             ; A
  jp c,l9a1f
  cp #5b             ; NOT AFTER Z
  jp nc,l9a1f
  sub #41            ; START LETTER A = 0, B = 1
  add a
  ld b,0
  ld c,a         
  ld hl,dict_letters ; LOAD TABLE PTR
  xor a
  adc hl,bc          ; ADD OFFSET TO TABLE PTR
  ld c,(hl)          ; GET RESULT IN BC
  inc hl
  ld b,(hl)
  ;ld (l99c0),bc
  ld (iy+option20),c
  ld (iy+option21),b
  l9a15:
    call l9a38
    ret c
    call l9a93 ; FIND NEXT 0?
  jp l9a15

l9a1f:
  cp #20      ; IS SPACE ?
  jp z,l9a2e
  ld bc,dict_numbers ; LOAD ORDINARY DATA
  ;ld (l99c0),bc
  ld (iy+option20),c
  ld (iy+option21),b
jp l9a15

; LOAD TABLE?
l9a2e:
  ld bc,dict_space   ; LOAD DATA IF SPACE
  ;ld (l99c0),bc
  ld (iy+option20),c
  ld (iy+option21),b
jp l9a15

; PARSE PHONEME?
l9a38:
;  ld hl,(l99be)
  ld l,(iy+option18)
  ld h,(iy+option19)
  
  ;ld bc,(l99c0)
  ld c,(iy+option20)
  ld b,(iy+option21)
  ld a,(bc)
  l9a40:
  cp #20 ; SPACE
  jr z,l9a87
  cp #23 ; #
  jr z,l9a7c
  cp (hl)
  jp nz,l9a8d
  l9a4c:
  inc bc
  inc hl
  ld a,(bc)
  or a
  jr z,l9a5c
  ld a,(hl)
  cp #0d ; EOL
  jp z,l9a8d
  ld a,(bc)
  jp l9a40
  l9a5c:
  inc bc
  dec hl
  ;ld (l99c0),bc
  ld (iy+option20),c
  ld (iy+option21),b
  ;ld (l99be),hl
  ld (iy+option18),l
  ld (iy+option19),h
  
  ld a,(hl)
  call l9ad4
  jr nc,l9a76
  dec bc
  dec bc
  dec bc
  ld a,(bc)
  inc bc
  inc bc
  inc bc
  or a
  jr z,l9a76
  dec hl
  l9a76:
  inc hl
  ;ld (l99be),hl
  ld (iy+option18),l
  ld (iy+option19),h
  scf  ; RETURN TRUE
ret

l9a7c:
  ld a,(hl)
  cp #0d ; EOL
  jr z,l9a8d
  ;ld (l99c2),a  ; STORE HASH
  ld (iy+option22),a
jp l9a4c

l9a87:
  ld a,(hl)
  call l9ad4
  jr c,l9a4c
  l9a8d: ; EOL
  ;ld (l99c0),bc
  ld (iy+option20),c
  ld (iy+option21),b
  xor a ; RETURN FALSE
ret

l9a93:
  ;ld hl,(l99c0)
  ld l,(iy+option20)
  ld h,(iy+option21)
  ld bc,0
  xor a
  cpir
  cpir
  ;ld (l99c0),hl
  ld (iy+option20),l
  ld (iy+option21),h
ret

l9aa2:
  ;ld hl,(l99be)
  ld l,(iy+option18)
  ld h,(iy+option19)
  ld a,(hl) 
  cp #0d ; EOL
  jr z,returntrue2
  xor a ; RETURN FALSE
ret

returntrue2:
  scf ; RETURN TRUE
ret

l9aae:
  ;ld bc,(l99c0)
  ld c,(iy+option20)
  ld b,(iy+option21)
  ;ld hl,(phonemeptr)
  ld l,(iy+phonemeptr1)
  ld h,(iy+phonemeptr2)
  l9ab5:
  ld a,(bc)
  inc d
  jp z,displaylinetoolong;l9942
  or a
  jr z,l9ad0
  cp #23
  jr z,l9aca
  l9ac1:
  call l9bfe
  ld (hl),a
  inc hl
  inc bc
  jp l9ab5
  l9aca:
  ;ld a,(l99c2)
  ld a,(iy+option22)
  jp l9ac1
  l9ad0:
 ; ld (phonemeptr),hl
  ld (iy+phonemeptr1),l
  ld (iy+phonemeptr2),h
ret

; FILTER LETTERS FROM ASCII STRING?
l9ad4:
  cp #30 ; 0
  ret c
  cp #5b ; [
  jr nc,returntrue
  cp #41 ; A
  jr nc,returnfalse
  cp #3a ; :
  jr nc,returntrue
  returnfalse:
  xor a ; RETURN FALSE
ret
  returntrue:
  scf   ; RETURN TRUE
ret

; FIND LAST LETTER OF WORD IN HL
l9ae7:
  ;ld hl,textbuffer ; DATA BUFFER FOR STRING
  push iy
  ld bc,textbuffer          
  add iy,bc        
  push iy
  pop hl
  pop iy
  
  l9aea:
  ld a,(hl)
  cp #20 ; SPACE
  jp nz,l9af4 
  inc hl
  jp l9aea
  l9af4:
  cp #0d ; EOL
  ret z
  ld (iy+option8),a;(l8842),a
  inc hl
jp l9aea
