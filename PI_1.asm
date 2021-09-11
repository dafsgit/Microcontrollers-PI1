
; PIC18F4550 Configuration Bit Settings

; Assembly source line config statements

#include "p18f4550.inc"

; CONFIG1L
  CONFIG  PLLDIV = 1            ; PLL Prescaler Selection bits (No prescale (4 MHz oscillator input drives PLL directly))
  CONFIG  CPUDIV = OSC1_PLL2    ; System Clock Postscaler Selection bits ([Primary Oscillator Src: /1][96 MHz PLL Src: /2])
  CONFIG  USBDIV = 1            ; USB Clock Selection bit (used in Full-Speed USB mode only; UCFG:FSEN = 1) (USB clock source comes directly from the primary oscillator block with no postscale)

; CONFIG1H
  CONFIG  FOSC = INTOSCIO_EC    ; Oscillator Selection bits (Internal oscillator, port function on RA6, EC used by USB (INTIO))
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enable bit (Fail-Safe Clock Monitor disabled)
  CONFIG  IESO = OFF            ; Internal/External Oscillator Switchover bit (Oscillator Switchover mode disabled)

; CONFIG2L
  CONFIG  PWRT = OFF            ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  BOR = ON              ; Brown-out Reset Enable bits (Brown-out Reset enabled in hardware only (SBOREN is disabled))
  CONFIG  BORV = 3              ; Brown-out Reset Voltage bits (Minimum setting 2.05V)
  CONFIG  VREGEN = OFF          ; USB Voltage Regulator Enable bit (USB voltage regulator disabled)

; CONFIG2H
  CONFIG  WDT = ON              ; Watchdog Timer Enable bit (WDT enabled)
  CONFIG  WDTPS = 32768         ; Watchdog Timer Postscale Select bits (1:32768)

; CONFIG3H
  CONFIG  CCP2MX = ON           ; CCP2 MUX bit (CCP2 input/output is multiplexed with RC1)
  CONFIG  PBADEN = ON           ; PORTB A/D Enable bit (PORTB<4:0> pins are configured as analog input channels on Reset)
  CONFIG  LPT1OSC = OFF         ; Low-Power Timer 1 Oscillator Enable bit (Timer1 configured for higher power operation)
  CONFIG  MCLRE = ON            ; MCLR Pin Enable bit (MCLR pin enabled; RE3 input pin disabled)

; CONFIG4L
  CONFIG  STVREN = ON           ; Stack Full/Underflow Reset Enable bit (Stack full/underflow will cause Reset)
  CONFIG  LVP = ON              ; Single-Supply ICSP Enable bit (Single-Supply ICSP enabled)
  CONFIG  ICPRT = OFF           ; Dedicated In-Circuit Debug/Programming Port (ICPORT) Enable bit (ICPORT disabled)
  CONFIG  XINST = OFF           ; Extended Instruction Set Enable bit (Instruction set extension and Indexed Addressing mode disabled (Legacy mode))

; CONFIG5L
  CONFIG  CP0 = OFF             ; Code Protection bit (Block 0 (000800-001FFFh) is not code-protected)
  CONFIG  CP1 = OFF             ; Code Protection bit (Block 1 (002000-003FFFh) is not code-protected)
  CONFIG  CP2 = OFF             ; Code Protection bit (Block 2 (004000-005FFFh) is not code-protected)
  CONFIG  CP3 = OFF             ; Code Protection bit (Block 3 (006000-007FFFh) is not code-protected)

; CONFIG5H
  CONFIG  CPB = OFF             ; Boot Block Code Protection bit (Boot block (000000-0007FFh) is not code-protected)
  CONFIG  CPD = OFF             ; Data EEPROM Code Protection bit (Data EEPROM is not code-protected)

; CONFIG6L
  CONFIG  WRT0 = OFF            ; Write Protection bit (Block 0 (000800-001FFFh) is not write-protected)
  CONFIG  WRT1 = OFF            ; Write Protection bit (Block 1 (002000-003FFFh) is not write-protected)
  CONFIG  WRT2 = OFF            ; Write Protection bit (Block 2 (004000-005FFFh) is not write-protected)
  CONFIG  WRT3 = OFF            ; Write Protection bit (Block 3 (006000-007FFFh) is not write-protected)

; CONFIG6H
  CONFIG  WRTC = OFF            ; Configuration Register Write Protection bit (Configuration registers (300000-3000FFh) are not write-protected)
  CONFIG  WRTB = OFF            ; Boot Block Write Protection bit (Boot block (000000-0007FFh) is not write-protected)
  CONFIG  WRTD = OFF            ; Data EEPROM Write Protection bit (Data EEPROM is not write-protected)

; CONFIG7L
  CONFIG  EBTR0 = OFF           ; Table Read Protection bit (Block 0 (000800-001FFFh) is not protected from table reads executed in other blocks)
  CONFIG  EBTR1 = OFF           ; Table Read Protection bit (Block 1 (002000-003FFFh) is not protected from table reads executed in other blocks)
  CONFIG  EBTR2 = OFF           ; Table Read Protection bit (Block 2 (004000-005FFFh) is not protected from table reads executed in other blocks)
  CONFIG  EBTR3 = OFF           ; Table Read Protection bit (Block 3 (006000-007FFFh) is not protected from table reads executed in other blocks)

; CONFIG7H
  CONFIG  EBTRB = OFF           ; Boot Block Table Read Protection bit (Boot block (000000-0007FFh) is not protected from table reads executed in other blocks)

;**************** Definitions*********************************
RETARDO	    EQU 0x01			;Reservar un registro temporal para el retardo
MULTIPLO    EQU 0x02			;Reservar un registro temporal para el múltiplo del loop
MINU	    EQU 0X03			;Reservar registro para contador de los minutos
DECA	    EQU 0X04			;Reservar registro para contador de las décadas de segundo
SEGU	    EQU 0X05			;Reservar registro para contador de las unidades de segundo
CONTANDO    EQU 0X06
;*************************************************

    ORG 0x000				;vector de reset
    GOTO MAIN				;goes to main program

INIT: 
    MOVLW	0x0F			;Puertos A, B y E pueden ser digitales (I/O) o analógicos (sólo I)
    MOVWF	ADCON1			;PORTA es analógico por default y estas dos líneas lo obligan a ser digital
    
    BSF		TRISC, 0		;RC0 es entrada
    BSF		TRISC, 1		;RC1 es entrada
    BSF		TRISC, 2		;RC2 es entrada
    BCF		TRISC, 4		;RC4 es salida
    CLRF	TRISA			;PORTA es salida: DISPLAY_MIN
    CLRF	TRISB			;PORTB es salida: DISPLAY_DEC
    CLRF	TRISD			;PORTD es salida: DISPLAY_SEG
    CLRF	PORTA			;Limpiar el puerto A
    CLRF	PORTB			;Limpiar el puerto B
    CLRF	PORTD			;Limpiar el puerto D
    
    BSF		CONTANDO, 0
    MOVLW	0x03
    MOVWF	MINU
    MOVLW	0x00
    MOVWF	DECA
    MOVLW	0x00
    MOVWF	SEGU
    RETURN				;leaving initialization subroutine

MAIN:
    CALL INIT				;Llamar a inicialización de puertos

WAITING:
    BTFSC PORTC, 0
    CALL INIT_BUTTON
    CALL    MILIS_100			;tiempo de espera
    BTFSC PORTC, 1
    CALL STOP_BUTTON
    CALL    MILIS_100			;tiempo de espera
    BTFSC PORTC, 2
    CALL VAL_BUTTON
    CALL    MILIS_100			;tiempo de espera
    
    ;MOVF CONTANDO, W
    ;BNZ  SHOW
    BTFSS CONTANDO, 0
    GOTO  WAITING

SHOW:    
    CALL  PARSE_MINU
    MOVWF PORTA
    CALL  PARSE_DECA
    MOVWF PORTB
    CALL  PARSE_SEGU
    MOVWF PORTD
    
    BTFSC CONTANDO, 0
    CALL  TIMER
    
    MOVF  SEGU, W
    BZ	  RET_9
    
    DECF  SEGU, F
    GOTO  WAITING

RET_9:
    MOVLW 0x09
    MOVWF SEGU
    
    MOVF  DECA, W
    BZ	  RET_5
    
    DECF  DECA
    GOTO  SHOW

RET_5:
    MOVLW 0x05
    MOVWF DECA
    
    MOVF  MINU, W
    BZ	  ZEROS
    
    DECF  MINU
    GOTO  SHOW
    
ZEROS:
    MOVLW	0x00
    MOVWF	DECA
    MOVLW	0x00
    MOVWF	SEGU
    MOVLW       b'00111111'
    MOVWF	PORTA
    MOVWF	PORTB
    MOVWF	PORTD
    BCF		CONTANDO, 0
    GOTO	WAITING
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INIT_BUTTON:
    BTFSS	CONTANDO, 0
    GOTO	IB_NC
    MOVLW	0x03
    MOVWF	MINU
    MOVLW	0x00
    MOVWF	DECA
    MOVLW	0x00
    MOVWF	SEGU
    BCF	    CONTANDO, 0
    RETURN

IB_NC:
    BSF	    CONTANDO, 0
    RETURN
    
STOP_BUTTON:
    BCF	    CONTANDO, 0
    RETURN

VAL_BUTTON:
    BTFSC   CONTANDO, 0
    RETURN
    GOTO    SHOW
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;
PARSE_MINU:
    MOVF MINU, W
    BZ	C0
    
    MOVF MINU, W
    SUBLW 0x01
    BZ	C1
    
    MOVF MINU, W
    SUBLW 0x02
    BZ	C2
    
    MOVF MINU, W
    SUBLW 0x03
    BZ	C3
    
    BRA C0
    
PARSE_DECA:
    MOVF DECA, W
    BZ	C0
    
    MOVF DECA, W
    SUBLW 0x01
    BZ	C1
    
    MOVF DECA, W
    SUBLW 0x02
    BZ	C2
    
    MOVF DECA, W
    SUBLW 0x03
    BZ	C3
    
    MOVF DECA, W
    SUBLW 0x04
    BZ	C4
    
    MOVF DECA, W
    SUBLW 0x05
    BZ	C5
    
    BRA C0
    
PARSE_SEGU:
    MOVF SEGU, W
    BZ	C0
    
    MOVF SEGU, W
    SUBLW 0x01
    BZ	C1
    
    MOVF SEGU, W
    SUBLW 0x02
    BZ	C2
    
    MOVF SEGU, W
    SUBLW 0x03
    BZ	C3
    
    MOVF SEGU, W
    SUBLW 0x04
    BZ	C4
    
    MOVF SEGU, W
    SUBLW 0x05
    BZ	C5
    
    MOVF SEGU, W
    SUBLW 0x06
    BZ	C6
    
    MOVF SEGU, W
    SUBLW 0x07
    BZ	C7
    
    MOVF SEGU, W
    SUBLW 0x08
    BZ	C8
    
    MOVF SEGU, W
    SUBLW 0x09
    BZ	C9
    
    BRA C0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
C9:    
    RETLW b'01101111'
C8:
    RETLW b'01111111'
C7:
    RETLW b'00000111'
C6:
    RETLW b'01111101'
C5:
    RETLW b'01101101'
C4:
    RETLW b'01100110'  
C3:
    RETLW b'01001111'
C2:
    RETLW b'01011011'
C1:					
    RETLW b'00000110'				
C0:					
    RETLW b'00111111'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
TIMER:
;SEG_1:
    BTG	PORTC, 4		; para monitoreo
    MOVLW 0x07			; 10*100ms = 1s
    MOVWF MULTIPLO
LOOP_1:
    CALL MILIS_100
    DECFSZ MULTIPLO
    GOTO LOOP_1
    RETURN
    
MILIS_100:
    MOVLW 0xFA			; 250*(97+1+2)*0.5us
    MOVWF RETARDO
LOOP:
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    DECFSZ RETARDO
    GOTO LOOP
    RETURN
    
    END					;El programa finaliza
