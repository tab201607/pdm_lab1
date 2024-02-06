;******************************************************************************
; Universidad del Valle de Guatemala 
; 1E2023: Programacion de Microcontroladores 
; main.asm 
; Autor: Jacob Tabush 
; Proyecto: Laboratorio 1 
; Hardware: ATMEGA328P 
; Creado: 30/01/2024 
; Ultima modificacion: 5/02/2024 
;*******************************************************************************

.include "M328PDEF.inc"

.def counter1=R18
.def counter2=R19
.def counterfull=R20


.cseg
.org 0x00

; STACK POINTER

LDI R16, LOW(RAMEND)
OUT SPL, R16
LDI R17, HIGH(RAMEND)
OUT SPH, R17

; Configuración
Setup:

;  prescaler

LDI R16, 0b1000_0000
STS CLKPR, R16
CALL delay

LDI R16, 0b0000_0011
STS CLKPR, R16

LDI R16, 0xFF
OUT DDRD, R16 ;Ponemos a todo D como salidas
LDI R16, 0x00
OUT PORTD, R16 ; Apagamos todas las salidas

LDI R16, 0x00
OUT DDRB, R16 ; Ponemos a todo B como entradas
LDI R16, 0x1F
OUT PORTB, R16 ; hablitamos pullups en todo B

LDI counter1, 0x00
LDI counter2, 0x00

Loop:

LDI counterfull, 0x00 
OR counterfull, counter2 ; carga el valor del primer contador en los 4 bits bajos


LDI R17, 4
MOV R16, counter1
shift:
LSL R16
DEC R17
BRNE shift

OR counterfull, R16 ; carga el valor del segundo contador en los 4 bits altos
OUT PORTD, counterfull

SBIS PINB, PB0 ;Saltamos a increment si PB0 esta en 0 (recordar pullup)
RJMP increment1

SBIS PINB, PB1 ;Saltamos a decrement si PB1 esta en 0 (recordar pullup)
RJMP decrement1

RJMP Loop

increment1:
CALL delay

	SBIS PINB, PB0 ; confirmamos que esta en 0
	RJMP increment1

	INC counter1
	SBRC counter1, 4
	LDI counter1, 0x0F

	RJMP Loop

decrement1:
	CALL delay

	SBIS PINB, PB1 ; confirmamos que esta en 0
	RJMP decrement1

	DEC counter1
	SBRC counter1, 7
	LDI counter1, 0x00

	RJMP Loop

; Modulo de delays de 2500 ticks
delay:
LDI R17, 10
delayouter:
LDI R16, 250
delayinner:
	DEC R16
	BRNE delayinner

	DEC R17
	BRNE delayouter

RET

