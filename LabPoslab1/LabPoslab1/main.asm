;******************************************************************************
; Universidad del Valle de Guatemala 
; 1E2023: Programacion de Microcontroladores 
; main.asm 
; Autor: Jacob Tabush 
; Proyecto: Laboratorio 1 
; Hardware: ATMEGA328P 
; Creado: 30/01/2024 
; Ultima modificacion: 6/02/2024 
;*******************************************************************************

.include "M328PDEF.inc"

.def counter1=R18 ; definimos todos los contadores
.def counter2=R19
.def counterfull=R20 ; este servira para desplegar en el portD
.def sum=R21


.cseg
.org 0x00

; STACK POINTER

LDI R16, LOW(RAMEND)
OUT SPL, R16
LDI R17, HIGH(RAMEND)
OUT SPH, R17


; ///////////////////////////////////////////////////////
; Configuracion
; ///////////////////////////////////////////////////////

Setup:

;  prescaler

LDI R16, 0b1000_0000
STS CLKPR, R16
CALL delay

LDI R16, 0b0000_0011 ; Prescaler de 8 
STS CLKPR, R16

LDI R16, 0xFF
OUT DDRD, R16 ;Ponemos a todo D como salidas
LDI R16, 0x00
OUT PORTD, R16 ; Apagamos todas las salidas

LDI R16, 0b0010_0000
OUT DDRB, R16 ; Ponemos a todo B (menos a PB5) como entradas
LDI R16, 0x1F
OUT PORTB, R16 ; hablitamos pullups en todo B (menos a PB5)

LDI R16, 0b0111_1111
OUT DDRC, R16 ; Ponemos a C0-C5 como salidas
LDI R16, 0x00
OUT PORTC, R16 ; Apagamos todas estas

LDI counter1, 0x00 ; aseguramos que ambos contadores esten en 0
LDI counter2, 0x00


; ///////////////////////////////////////////////////////
; Loop principal
; ///////////////////////////////////////////////////////


Loop:
//outputs

LDI counterfull, 0x00 
OR counterfull, counter2 ; carga el valor del primer contador en los 4 bits bajos

LDI R17, 4 ; Utilizamos left shift para desplegar contador 1 en PD4-7
MOV R16, counter1
shift:
LSL R16
DEC R17
BRNE shift

OR counterfull, R16 ; carga el valor del segundo contador en los 4 bits altos
OUT PORTD, counterfull


LDI sum, 0x00 ; realizamos la suma
ADD sum, counter1
ADD sum, counter2

; Utilizamos PC5 y PC6 para los primeros 2 bits de counter2 porque PD0 y PD1 estan reservados para  el serial
SBRC counter2, 0
SBI PORTC, PC4 
SBRS counter2, 0
CBI PORTC, PC4

SBRC counter2, 1
SBI PORTC, PC5
SBRS counter2, 1
CBI PORTC, PC5

// control

SBIS PINB, PB0 ;Saltamos a increment si PB0 esta en 0 (recordar pullup)
CALL increment1

SBIS PINB, PB1 ;Saltamos a decrement si PB1 esta en 0 (recordar pullup)
CALL decrement1

SBIS PINB, PB2 ;Saltamos a increment2
CALL increment2

SBIS PINB, PB3 ;Saltamos a decrement2
CALL decrement2

SBIS PINB, PB4 ;Saltamos al control del display de adicion
RJMP displaysum

LDI R16, 0x00 ; No desplegamos nada en PORTC cuando no estamos apachando el boton de suma
OUT PORTC, R16
CBI PORTB, PB5 ; Tampoco desplegamos info en 

RJMP Loop


; ///////////////////////////////////////////////////////
; counter modules
; ///////////////////////////////////////////////////////


increment1: ; Modulo para incrementar en el contador 1
CALL delay2

	SBIS PINB, PB0 ; confirmamos que esta en 0
	RJMP increment1

	INC counter1
	SBRC counter1, 4 ; revisamos que no aumenta mas de los 4 bits
	LDI counter1, 0x0F

	RET

increment2: ; Modulo para incrementar en el contador 2
CALL delay

	SBIS PINB, PB2 ; confirmamos que esta en 0
	RJMP increment2

	INC counter2 
	SBRC counter2, 4 ; revisamos que no aumenta mas de los 4 bits
	LDI counter2, 0x0F

	RET

decrement1: ;  Modulo para decrementar en el contador 1
	CALL delay2

	SBIS PINB, PB1 ; confirmamos que esta en 0
	RJMP decrement1

	DEC counter1
	SBRC counter1, 7 ; revisamos que no hace wraparound para estar de mas de 4 bits
	LDI counter1, 0x00

	RET

decrement2: ;  Modulo para decrementar en el contador 2
	CALL delay

	SBIS PINB, PB3 ; confirmamos que esta en 0
	RJMP decrement2

	DEC counter2
	SBRC counter2, 7 ; revisamos que no hace wraparound para estar de mas de 4 bits
	LDI counter2, 0x00

	RET

	
; ///////////////////////////////////////////////////////
; sum module
; ///////////////////////////////////////////////////////


displaysum: ;funcion para desplegar suma
	CALL delay
	
	OUT PORTC, sum
	
	; desplegamos el carry bit en PB5
	SBRC sum, 4
	SBI PORTB, PB5

	SBRS sum, 4
	CBI PORTB, PB5

	; Utilizamos PC5 y PC6 para los primeros 2 bits de counter2 porque PD0 y PD1 estan reservados para  el serial
SBRC counter2, 0
SBI PORTC, PC4 
SBRS counter2, 0
CBI PORTC, PC4

SBRC counter2, 1
SBI PORTC, PC5
SBRS counter2, 1
CBI PORTC, PC5

	SBIS PINB, PB4
	RJMP displaysum

	RJMP Loop


; ///////////////////////////////////////////////////////
; delay modules
; ///////////////////////////////////////////////////////

; Modulo de delays de 1250 ticks
delay:
LDI R17, 5 ; loop externo
delayouter:
LDI R16, 250 ; loop interno
delayinner:
	DEC R16
	BRNE delayinner

	DEC R17
	BRNE delayouter

RET

; Modulo de delays de 1250 ticks
delay2:
LDI R17, 15 ; loop externo
delayouter2:
LDI R16, 250 ; loop interno
delayinner2:
	DEC R16
	BRNE delayinner2

	DEC R17
	BRNE delayouter2

RET

