
; Smart Medicine Reminder & Dose Tracker

.MODEL SMALL
.STACK 100H

PRINT MACRO MSG
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
ENDM

NEWLINE MACRO
    LEA DX, NL
    MOV AH, 09H
    INT 21H
ENDM



.DATA

MENU DB 0DH,0AH
    
     DB 'MEDICINE REMINDER & DOSE TRACKER    ',0DH,0AH
     DB ' ', 0DH, 0AH
     
     DB '1. Add New Medicine',0DH,0AH
     DB '2. View All Reports',0DH,0AH
     DB '3. Time Query',0DH,0AH
     DB '4. Mark Taken',0DH,0AH
     DB '5. Delete Medicine',0DH,0AH
     DB '6. Compliance',0DH,0AH
     DB ' ',0DH,0AH
     DB 'Choice: $'

NAME_P   DB 0DH,0AH,'Enter Med Name: $'
DOSE_P   DB 0DH,0AH,'How many doses (1-3)? $'
DOSE_W   DB 0DH,0AH,'Which Dose <1-3>? $'
TIME_P   DB 0DH,0AH,'Enter Hour for Dose $'
COLON    DB ': $'
NUM_P    DB 0DH,0AH,'Enter Med Number (1-9): $'
FULL_M   DB 0DH,0AH,'ERROR: System Full!$'
STAT_T   DB ' [TAKEN]',0DH,0AH,'$'
STAT_N   DB ' [NOT TAKEN]',0DH,0AH,'$'
COMP_HDR DB 0DH,0AH,'Daily Compliance',0DH,0AH,'$'
COMP_TAK DB 'Doses Taken : $'
COMP_TOT DB 0DH,0AH,'Total Doses : $'
NL       DB 0DH,0AH,'$'
INDENT   DB '  $'
D_AT     DB ' at $'
H_MARK   DB 'h$'
NO_MATCH DB 0DH,0AH,'No medicine at this hour.',0DH,0AH,'$'
QRY_HDR  DB 0DH,0AH,'>>> Take: $'
QRY_MED  DB 'Medicine #$'
QRY_AND  DB ' and Medicine #$'
DEL_OK   DB 0DH,0AH,'Medicine deleted.$'
MED_LBL  DB 0DH,0AH,'Med #$'
SEP      DB ' | $'
DIVIDER  DB 0DH,0AH,'--------------------------$'
INV_MSG  DB 0DH,0AH,'Invalid input.$'
DOSE_LBL DB 'Dose $'
NO_MED   DB 0DH,0AH,'No medicines stored.$'




; DATA ARRAYS

NAMES    DB 144 DUP(' ')   ; 9 medicines x 16 bytes each
HOURS    DB 27  DUP(0FFh)  ; 9 medicines x 3 doses each
STATUS   DB 27  DUP(0)     ; 0=Not Taken, 1=Taken
DOSE_CNT DB 9   DUP(0)     ; dose count per medicine
COUNT    DB 0

; Memory variables 

SAVE_IDX  DB 0             ; saves medicine index across PRINT_NUM
TARGET_HR DB 0             ; saves query hour
MATCH_BUF DB 10 DUP(0FFh) ; matching medicine numbers + sentinel


.CODE


;  READ_HOUR

READ_HOUR PROC
    PUSH BX
    PUSH CX
    PUSH DX

RH_RETRY:
    XOR  CX, CX
    XOR  BX, BX

RH_LOOP:
    MOV  AH, 01H
    INT  21H
    CMP  AL, 0DH
    JE   RH_DONE
    CMP  AL, '0'
    JB   RH_RETRY
    CMP  AL, '9'
    JA   RH_RETRY
    INC  BL
    CMP  BL, 3
    JAE  RH_RETRY
    SUB  AL, '0'
    PUSH AX
    MOV  AX, CX
    MOV  DL, 10
    MUL  DL
    POP  DX
    MOV  DH, 0
    ADD  AX, DX
    MOV  CX, AX
    JMP  RH_LOOP

RH_DONE:
    CMP  BL, 0
    JE   RH_RETRY
    CMP  CX, 23
    JA   RH_RETRY
    MOV  AX, CX

    POP  DX
    POP  CX
    POP  BX
    RET
READ_HOUR ENDP




PRINT_NUM PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    XOR  AH, AH
    MOV  BL, 10
    XOR  CX, CX

PN_DIV:
    DIV  BL
    PUSH AX
    INC  CX
    XOR  AH, AH
    CMP  AL, 0
    JNE  PN_DIV

PN_PRINT:
    POP  AX
    MOV  DL, AH
    ADD  DL, '0'
    MOV  AH, 02H
    INT  21H
    LOOP PN_PRINT

    POP  DX
    POP  CX
    POP  BX
    POP  AX
    RET
PRINT_NUM ENDP


;  MAIN

MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

MENU_LOOP:
    PRINT MENU
    MOV AH, 01H
    INT 21H

    CMP AL, '1'
    JE  DO_ADD
    CMP AL, '2'
    JE  DO_REP
    CMP AL, '3'
    JE  DO_QRY
    CMP AL, '4'
    JE  DO_MRK
    CMP AL, '5'
    JE  DO_DEL
    CMP AL, '6'
    JE  DO_CMP
    CMP AL, '0'
    JE  DO_EXIT
    JMP MENU_LOOP

DO_ADD:  CALL ADD_MED
         JMP  MENU_LOOP
DO_REP:  CALL REPORT
         JMP  MENU_LOOP
DO_QRY:  CALL QUERY
         JMP  MENU_LOOP
DO_MRK:  CALL MARK
         JMP  MENU_LOOP
DO_DEL:  CALL DELETE
         JMP  MENU_LOOP
DO_CMP:  CALL COMPLY
         JMP  MENU_LOOP
DO_EXIT: MOV  AH, 4CH
         INT  21H
MAIN ENDP


;  ADD_MED: Feature 1
; 
ADD_MED PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
    PUSH DI

    MOV  AL, COUNT
    CMP  AL, 9
    JAE  ADD_FULL

    XOR  AH, AH
    MOV  BX, AX

    MOV  AX, BX
    MOV  DL, 16
    MUL  DL
    LEA  SI, NAMES
    ADD  SI, AX

    

    PRINT NAME_P
    MOV  CX, 16
IN_NAME:
    MOV  AH, 01H
    INT  21H
    CMP  AL, 0DH
    JE   END_NAME
    MOV  [SI], AL
    INC  SI
    LOOP IN_NAME
END_NAME:

ADD_DOSE_PROMPT:
    PRINT DOSE_P
    MOV  AH, 01H
    INT  21H
    SUB  AL, '0'
    CMP  AL, 1
    JB   ADD_DOSE_PROMPT
    CMP  AL, 3
    JA   ADD_DOSE_PROMPT

    MOV  DOSE_CNT[BX], AL      ;bx=medicine num
    MOV  CL, AL
    XOR  CH, CH

    MOV  AX, BX
    MOV  DL, 3
    MUL  DL
    MOV  SI, AX
    MOV  DI, 1

DOSE_IN_LOOP:
    PUSH CX
    PRINT TIME_P
    MOV  DX, DI          
    ADD  DL, '0'
    MOV  AH, 02H
    INT  21H
    PRINT COLON
    CALL READ_HOUR
    MOV  HOURS[SI], AL
    MOV  STATUS[SI], 0
    INC  SI
    INC  DI
    POP  CX
    LOOP DOSE_IN_LOOP

    INC  COUNT
    JMP  ADD_DONE

ADD_FULL:
    PRINT FULL_M
    NEWLINE

ADD_DONE:
    POP  DI
    POP  SI
    POP  CX
    POP  BX
    POP  AX
    RET
ADD_MED ENDP


;  REPORT: Feature 2

REPORT PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI

    CMP  COUNT, 0
    JNE  REP_START
    PRINT NO_MED
    NEWLINE
    JMP  REP_END

REP_START:
    MOV  BL, 0

REP_LOOP:
    CMP  BL, COUNT
    JAE  REP_END

    PRINT DIVIDER
    PRINT MED_LBL

    MOV  AL, BL
    INC  AL
    CALL PRINT_NUM
    PRINT SEP

    MOV  AL, BL
    XOR  AH, AH
    MOV  DL, 16
    MUL  DL
    LEA  SI, NAMES
    ADD  SI, AX
    MOV  CX, 14

NAME_PRINT:
    MOV  DL, [SI]
    CMP  DL, ' '
    JE   NAME_DONE
    MOV  AH, 02H
    INT  21H
    INC  SI
    LOOP NAME_PRINT
NAME_DONE:
    NEWLINE

    MOV  SAVE_IDX, BL

    MOV  AL, BL
    XOR  AH, AH
    MOV  DL, 3
    MUL  DL
    MOV  SI, AX

    XOR  BX, BX
    MOV  BL, SAVE_IDX
    MOV  AL, DOSE_CNT[BX]
    MOV  CL, AL
    XOR  CH, CH
    MOV  DI, 1

DOSE_R:
    PUSH CX

    PRINT INDENT
    PRINT DOSE_LBL          ; "Dose "

    MOV  DX, DI             ; 
    ADD  DL, '0'
    MOV  AH, 02H
    INT  21H

    PRINT D_AT              ; " at "

    MOV  AL, HOURS[SI]
    CALL PRINT_NUM

    PRINT H_MARK            ; "h"

    CMP  STATUS[SI], 1
    JE   R_TAKEN
    PRINT STAT_N
    JMP  R_NEXT
R_TAKEN:
    PRINT STAT_T
R_NEXT:
    INC  SI
    INC  DI
    POP  CX
    LOOP DOSE_R

    MOV  BL, SAVE_IDX
    INC  BL
    JMP  REP_LOOP

REP_END:
    PRINT DIVIDER
    NEWLINE
    POP  SI
    POP  CX
    POP  BX
    POP  AX
    RET
REPORT ENDP


;  QUERY: Feature 3   

QUERY PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
    PUSH DI

    PRINT TIME_P
    MOV  DL, '?'
    MOV  AH, 02H
    INT  21H
    PRINT COLON
    CALL READ_HOUR
    MOV  TARGET_HR, AL      

    ;Clear MATCH_BUF 
    
    LEA  DI, MATCH_BUF
    MOV  CX, 10 
    
Q_CLRBUF:
    MOV  BYTE PTR [DI], 0FFh
    INC  DI
    LOOP Q_CLRBUF

    ; Pass 1: collect the matching medicine numbers
    LEA  DI, MATCH_BUF
    MOV  BL, 0 ; medicine index starting from 0

Q_MED_LOOP:
    CMP  BL, COUNT
    JAE  Q_SCAN_DONE

    
    MOV  AL, BL
    XOR  AH, AH
    MOV  DL, 3
    MUL  DL
    MOV  SI, AX ;; SI = BL * 3

    XOR  BH, BH
    MOV  CL, DOSE_CNT[BX]  ; CL = number of doses

Q_DOSE_LOOP:
    CMP  CL, 0
    JE   Q_NEXT_MED
    MOV  AL, TARGET_HR      ; reload from memory
    CMP  AL, HOURS[SI]
    JNE  Q_SKIP
    MOV  AL, BL
    INC  AL                 ; 1-based medicine number
    MOV  [DI], AL
    INC  DI
    JMP  Q_NEXT_MED         ; one entry per medicine
Q_SKIP:
    INC  SI
    DEC  CL
    JMP  Q_DOSE_LOOP

Q_NEXT_MED:
    INC  BL
    JMP  Q_MED_LOOP

Q_SCAN_DONE:
    ; Count entries
    LEA  SI, MATCH_BUF
    XOR  CX, CX    
    
Q_CNT:
    CMP  BYTE PTR [SI], 0FFh
    JE   Q_CNT_DONE
    INC  CX
    INC  SI
    JMP  Q_CNT 
    
Q_CNT_DONE:
    CMP  CX, 0
    JNE  Q_PRINT
    PRINT NO_MATCH
    JMP  Q_OUT

    ; Pass 2: print all matching medicines
Q_PRINT:
    PRINT QRY_HDR            ; "\r\n>>> Take: "
    LEA  SI, MATCH_BUF
    XOR  BX, BX              ; BL = position counter

Q_PRINT_LOOP:
    MOV  AL, [SI]
    CMP  AL, 0FFh
    JE   Q_PRINT_DONE

    ; PUSH AX before PRINT so AL (medicine number) survives
    
    PUSH AX

    CMP  BL, 0
    JE   Q_IS_FIRST
    PRINT QRY_AND            ; " and Medicine #"
    JMP  Q_DO_NUM
Q_IS_FIRST:
    PRINT QRY_MED            ; "Medicine #"

Q_DO_NUM:
    POP  AX                  ; medicine number back in AL
    CALL PRINT_NUM
    INC  SI
    INC  BL
    JMP  Q_PRINT_LOOP

Q_PRINT_DONE:
    NEWLINE

Q_OUT:
    POP  DI
    POP  SI
    POP  CX
    POP  BX
    POP  AX
    RET
QUERY ENDP


;  MARK: Feature 4

MARK PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI

MARK_MED:
    PRINT NUM_P
    MOV  AH, 01H
    INT  21H
    SUB  AL, '1'
    CMP  AL, 0FFh
    JE   MARK_INV
    MOV  BL, AL
    CMP  BL, COUNT
    JAE  MARK_INV
    JMP  MARK_OK
MARK_INV:
    PRINT INV_MSG
    JMP  MARK_MED
MARK_OK:

MARK_DOSE:
    PRINT DOSE_W
    MOV  AH, 01H
    INT  21H
    SUB  AL, '1'
    MOV  CL, AL
    XOR  BH, BH
    CMP  CL, DOSE_CNT[BX]
    JAE  MARK_DINV
    JMP  MARK_DOK
MARK_DINV:
    PRINT INV_MSG
    JMP  MARK_DOSE
MARK_DOK:
    MOV  AL, BL
    XOR  AH, AH
    MOV  DL, 3
    MUL  DL
    ADD  AL, CL
    MOV  SI, AX
    MOV  STATUS[SI], 1
    PRINT STAT_T
    NEWLINE

    POP  SI
    POP  CX
    POP  BX
    POP  AX
    RET
MARK ENDP


;  DELETE: Feature 5

DELETE PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
    PUSH DI

DEL_PROMPT:
    PRINT NUM_P
    MOV  AH, 01H
    INT  21H
    SUB  AL, '1'
    CMP  AL, 0FFh
    JE   DEL_INV
    MOV  BL, AL
    CMP  BL, COUNT
    JAE  DEL_INV
    JMP  DEL_GO
DEL_INV:
    PRINT INV_MSG
    JMP  DEL_PROMPT
DEL_GO:

SHIFT_LOOP:
    MOV  AL, BL
    INC  AL
    CMP  AL, COUNT
    JAE  SHIFT_DONE

    XOR  AH, AH
    XOR  BH, BH

    MOV  SI, AX
    MOV  DL, DOSE_CNT[SI]
    MOV  DOSE_CNT[BX], DL

    PUSH AX
    PUSH BX
    MOV  DL, 16
    MUL  DL
    LEA  SI, NAMES
    ADD  SI, AX
    MOV  AX, BX
    MOV  DL, 16
    MUL  DL
    LEA  DI, NAMES
    ADD  DI, AX
    MOV  CX, 16
COPY_NAME:
    MOV  DL, [SI]
    MOV  [DI], DL
    INC  SI
    INC  DI
    LOOP COPY_NAME
    POP  BX
    POP  AX

    PUSH AX
    PUSH BX
    MOV  DL, 3
    MUL  DL
    LEA  SI, HOURS
    ADD  SI, AX
    MOV  AX, BX
    MOV  DL, 3
    MUL  DL
    LEA  DI, HOURS
    ADD  DI, AX
    MOV  CX, 3
COPY_DOSE:
    MOV  DL, HOURS[SI]
    MOV  HOURS[DI], DL
    MOV  DL, STATUS[SI]
    MOV  STATUS[DI], DL
    INC  SI
    INC  DI
    LOOP COPY_DOSE
    POP  BX
    POP  AX

    INC  BL
    JMP  SHIFT_LOOP

SHIFT_DONE:
    DEC  COUNT
    PRINT DEL_OK
    NEWLINE

    POP  DI
    POP  SI
    POP  CX
    POP  BX
    POP  AX
    RET
DELETE ENDP


;  COMPLY: Feature 6  

COMPLY PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    PRINT COMP_HDR

    CMP  COUNT, 0
    JNE  CMP_START
    PRINT NO_MED
    NEWLINE
    JMP  CMP_DONE

CMP_START:
    XOR  BX, BX
    XOR  CX, CX             ; CL=total

CMP_MED_LOOP:               ;bl=current medicine index cl=total medicine
    CMP  BL, COUNT
    JAE  CMP_SHOW

    XOR  BH, BH
    MOV  AL, DOSE_CNT[BX]   ;dose[med1]
    MOV  DL, AL

    MOV  AX, BX
    XOR  AH, AH
    MOV  DH, 3
    MUL  DH
    MOV  SI, AX

    ADD  CL, DL          ;DL = number of doses for current medicine
    MOV  DH, DL          ;DH =loop counter for doses of current medicine

CMP_DOSE_LOOP:
    CMP  DH, 0
    JE   CMP_MED_NEXT
    CMP  STATUS[SI], 1
    JNE  CMP_SKIP
    INC  CH
CMP_SKIP:
    INC  SI
    DEC  DH
    JMP  CMP_DOSE_LOOP

CMP_MED_NEXT:
    INC  BL
    JMP  CMP_MED_LOOP

CMP_SHOW:
    PRINT COMP_TAK
    MOV  AL, CH
    CALL PRINT_NUM

    PRINT COMP_TOT
    MOV  AL, CL
    CALL PRINT_NUM
    NEWLINE

CMP_DONE:
    POP  SI
    POP  DX
    POP  CX
    POP  BX
    POP  AX
    RET
COMPLY ENDP

END MAIN
