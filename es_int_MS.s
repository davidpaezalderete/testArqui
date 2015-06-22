***********************************************************
* Autores:
* Sotodosos Rodrigo, Iván (080087)
* Mascaró Pérez, José (q080030)
***********************************************************

********* Inicialización de SP y PC ***********************

	ORG	$0
	DC.L	$8000		* Inicio de Pila
	DC.L	BUFP03		* PC al inicio de PPAL1

********* Definición de los registros *********************

MR1A    EQU     $effc01       * Registro de modo 1 de A - escritura
SRA     EQU     $effc03       * Registro de estado de A - lectura
CRA     EQU     $effc05       * Registro de control de A - escritura
TBA     EQU     $effc07       * Buffer transmisión de A - escritura
RBA     EQU     $effc07       * Buffer recepción de A  - lectura
ACR	EQU	$effc09	      * Registro de control auxiliar
IMR     EQU     $effc0B       * Registro de máscara de interrupción - escritura
MR1B	EQU	$effc11		  * Registro de modo 1 de B - escritura
SRB	EQU	$effc13		  * Registro de estado de B - lectura
CRB	EQU	$effc15		  * Registro de control de B - escritura
TBB     EQU     $effc17       * Buffer transmisión de B - escritura
RBB     EQU     $effc17       * Buffer recepción B - lectura
IVR     EQU     $effc19       * Registro del vector de interrupción

********* Datos en memoria ********************************

	ORG		$400

buffSA:		DS.B	2000	* Buffer interno de SCAN por línea A
fin_SA:		DS.B	4		* Final de buffSA
buffPA:		DS.B	2000	* Buffer interno de SCAN por línea B
fin_PA:		DS.B	4		* Final de buffPA
buffSB:		DS.B	2000	* Buffer interno de PRINT por línea A
fin_SB:		DS.B	4		* Final de buffSB
buffPB:		DS.B	2000	* Buffer interno de PRINT por línea B
fin_PB:		DS.B	4		* Final de buffPB
VACIO_SA:	DS.B	1		* Bit para comprobar si está vacío SA
VACIO_SB:	DS.B	1		* Bit para comprobar si está vacío SB
LLENO_PA:	DS.B	1		* Bit para comprobar si está lleno PA
LLENO_PB:	DS.B	1		* Bit para comprobar si está lleno PB


RET_TBA:	DS.B	1		* Bit para comprobar si hay que escribir un 0A en la RTI
RET_TBB:	DS.B	1		* Bit para comprobar si hay que escribir un 0A en la RTI

IMRC:		DS.B	2		* Copia de la máscara de interrupción

********* Definición de punteros a buffers ****************

PUNSA:		DS.B 	4	* Puntero de SCAN A
PUNSB: 		DS.B	4	* Puntero de SCAN B
PUNPA:		DS.B	4	* Puntero de PRINT A
PUNPB:		DS.B	4	* Puntero de PRINT B
PUNRTISA:	DS.B 	4	* Puntero de RTI de SCAN A
PUNRTISB:	DS.B	4	* Puntero de RTI de SCAN B
PUNRTIPA:	DS.B	4	* Puntero de RTI de PRINT A
PUNRTIPB:	DS.B	4	* Puntero de RTI de PRINT B
FINSA:		DS.B	4	* Puntero de fin de SCAN A
FINSB:		DS.B	4	* Puntero de fin de SCAN B
FINPA:		DS.B	4	* Puntero de fin de PRINT A
FINPB:		DS.B	4	* Puntero de fin de PRINT B

********* LEECAR ******************************************

LEECAR:
	BTST		#0,D0	* Miro el valor del 1º bit de D0
	BNE		LEE_B	* Si no es 0 (es 1) salta a LEE_B
	
********* LEE LÍNEA A *****************
LEE_A:
	BTST		#1,D0			* Miro el valor del 2º bit de D0
	BNE		LEE_AT			* Si es 1 salta a LEE_AT
LEE_AR:
	MOVE.L		PUNSA,A1		* Llevo PUNSA a A1
	MOVE.L		PUNRTISA,A2		* Llevo PUNRTISA a A2
	MOVE.L		FINSA,A3		* Llevo FINSA a A3
	MOVE.B		VACIO_SA,D2		* Llevo VACIO_SA a D2
	CMP.L		A1,A2			* Comparo PUNSA y PUNRTISA
	BNE		LEE_ARN			* Si no son iguales voy a LEE_ARN para leer normal
	CMP.B		#1,D2			* Miro si está vacío el buffer
	BNE		LEE_ARN			* Si PUNSA y PUNRTISA son iguales y no está vacío voy a LEE_ARN
	MOVE.L		#$FFFFFFFF,D0		* Si PUNSA y PUNRTISA son iguales y sí está vacío devuelvo un error
	BRA		LEE_FIN			* Y salto a LEE_FIN
LEE_ARN:
	MOVE.B		(A1)+,D0		* Llevo el carácter leído a D0 e incremento A1
	MOVE.L		A1,PUNSA		* Actualizo PUNSA
	CMP.L		A1,A3			* Miro si he llegado al final
	BNE		COMP_LAR		* Si no, salto a COMP_LAR
	LEA		buffSA,A1		* Si he llegado al final llevo buffSA a A1 (buffer circular)
	MOVE.L		A1,PUNSA		* Y actualizo PUNSA
COMP_LAR:
	CMP.L		A1,A2			* Comparo PUNSA y PUNRTISA
	BNE		LEE_FIN			* Si no son iguales voy a LEE_FIN
	MOVE.B		#1,VACIO_SA		* Si sí son iguales pongo un 1 en VACIO_SA
	BRA		LEE_FIN			* Y salto a LEE_FIN
	
LEE_AT:
	MOVE.L		PUNPA,A1		* Llevo PUNPA a A1
	MOVE.L		PUNRTIPA,A2		* Llevo PUNRTIPA a A2
	MOVE.L		FINPA,A3		* Llevo FINPA a A3
	MOVE.B		LLENO_PA,D2		* Llevo LLENO_PA a D2
	CMP.L		A1,A2			* Comparo PUNPA y PUNRTIPA
	BNE		LEE_ATN			* Si no son iguales voy a LEE_ATN para leer normal
	CMP.B		#0,D2			* Miro si no está lleno el buffer
	BNE		LEE_ATN			* Si PUNPA y PUNRTIPA son iguales y no está lleno voy a LEE_ATN
	MOVE.L		#$FFFFFFFF,D0		* Si PUNPA y PUNRTIPA son iguales y sí está lleno devuelvo un error
	BRA		LEE_FIN			* Y salto a LEE_FIN
LEE_ATN:
	MOVE.B		(A2)+,D0		* Llevo el carácter leído a D0 e incremento A2
	MOVE.L		A2,PUNRTIPA		* Actualizo PUNRTIPA
	CMP.L		A2,A3			* Miro si he llegado al final
	BNE		COMP_LAT		* Si no, salto a COMP_LAT
	LEA		buffPA,A2		* Si he llegado al final llevo buffPA a A2 (buffer circular)
	MOVE.L		A2,PUNRTIPA		* Y actualizo PUNRTIPA
COMP_LAT:
	CMP.L		A1,A2			* Comparo PUNPA y PUNRTIPA
	BNE		LEE_FIN			* Si no son iguales voy a LEE_FIN
	MOVE.B		#0,LLENO_PA		* Si sí son iguales pongo un 0 en LLENO_PA
	BRA		LEE_FIN			* Y salto a LEE_FIN
	
********* LEE LÍNEA B *****************
LEE_B:
	BTST		#1,D0
	BNE		LEE_BT
LEE_BR:
	MOVE.L		PUNSB,A1
	MOVE.L		PUNRTISB,A2
	MOVE.L		FINSB,A3
	MOVE.B		VACIO_SB,D2
	CMP.L		A1,A2
	BNE		LEE_BRN
	CMP.B		#1,D2
	BNE		LEE_BRN
	MOVE.L		#$FFFFFFFF,D0
	BRA		LEE_FIN
LEE_BRN:
	MOVE.B		(A1)+,D0
	MOVE.L		A1,PUNSB
	CMP.L		A1,A3
	BNE		COMP_LBR
	LEA		buffSB,A1
	MOVE.L		A1,PUNSB
COMP_LBR:
	CMP.L		A1,A2
	BNE		LEE_FIN
	MOVE.B		#1,VACIO_SB
	BRA		LEE_FIN
	
LEE_BT:
	MOVE.L		PUNPB,A1
	MOVE.L		PUNRTIPB,A2
	MOVE.L		FINPB,A3
	MOVE.B		LLENO_PB,D2
	CMP.L		A1,A2
	BNE		LEE_BTN
	CMP.B		#0,D2
	BNE		LEE_BTN
	MOVE.L		#$FFFFFFFF,D0
	BRA		LEE_FIN
LEE_BTN:
	MOVE.B		(A2)+,D0
	MOVE.L		A2,PUNRTIPB
	CMP.L		A2,A3
	BNE		COMP_LBT
	LEA		buffPB,A2
	MOVE.L		A2,PUNRTIPB
COMP_LBT:
	CMP.L		A1,A2
	BNE		LEE_FIN
	MOVE.B		#0,LLENO_PB
	
LEE_FIN:
	RTS

********* ESCCAR ******************************************

ESCCAR:
	BTST		#0,D0	* Miro el valor del 1º bit de D0
	BNE		ESC_B	* Si no es 0 (es 1) salta a ESC_B
	
********* ESCRIBE LÍNEA A *************
ESC_A:
	BTST		#1,D0			* Miro el valor del 2º bit de D0
	BNE		ESC_AT			* Si es 1 salta a ESC_AT
ESC_AR:
	MOVE.L		PUNSA,A1		* Llevo PUNSA a A1
	MOVE.L		PUNRTISA,A2		* Llevo PUNRTISA a A2
	MOVE.L		FINSA,A3		* Llevo FINSA a A3
	MOVE.B		VACIO_SA,D2		* Llevo VACIO_SA a D2
	CMP.L		A1,A2			* Comparo PUNSA y PUNRTISA
	BNE		ESC_ARN			* Si no son iguales voy a ESC_ARN para escribir normal
	CMP.B		#0,D2			* Miro si no está vacío el buffer
	BNE		ESC_ARN			* Si PUNSA y PUNRTISA son iguales y está vacío voy a ESC_ARN
	MOVE.L		#$FFFFFFFF,D0		* Si PUNSA y PUNRTISA son iguales y no está vacío devuelvo un error
	BRA		ESC_FIN			* Y salto a LEE_FIN
ESC_ARN:
	MOVE.B		D1,(A2)+		* Llevo el carácter a A2 y lo incremento
	MOVE.L		#0,D0			* Pongo un 0 en D0 ya que se ha escrito el carácter correctamente
	MOVE.L		A2,PUNRTISA		* Actualizo PUNRTISA
	CMP.L		A2,A3			* Miro si he llegado al final 
	BNE		COMP_EAR		* Si no, salto a COMP_EAR
	LEA		buffSA,A2		* Si he llegado al final llevo buffSA a A2 (buffer circular)
	MOVE.L		A2,PUNRTISA		* Y actualizo PUNRTISA
COMP_EAR:
	CMP.L		A1,A2			* Comparo PUNSA y PUNRTISA
	BEQ		ESC_FIN			* Si son iguales voy a ESC_FIN
	MOVE.B		#0,VACIO_SA		* Si no, pongo un 0 en VACIO_SA
	BRA		ESC_FIN			* Y salto a ESC_FIN

ESC_AT:
	MOVE.L		PUNPA,A1		* Llevo PUNPA a A1
	MOVE.L		PUNRTIPA,A2		* Llevo PUNRTIPA a A2
	MOVE.L		FINPA,A3		* Llevo FINPA a A3
	MOVE.B		LLENO_PA,D2		* Llevo LLENO_PA a D2
	CMP.L		A1,A2			* Comparo PUNPA y PUNRTIPA
	BNE		ESC_ATN			* Si no son iguales voy a ESC_ATN para escribir normal
	CMP.B		#1,D2			* Miro si está lleno el buffer
	BNE		ESC_ATN			* Si PUNPA y PUNRTIPA son iguales y está lleno voy a ESC_ATN
	MOVE.L		#$FFFFFFFF,D0		* Si PUNPA y PUNRTIPA son iguales y no está lleno devuelvo un error
	BRA		ESC_FIN			* Y salto a ESC_FIN
ESC_ATN:
	MOVE.B		D1,(A1)+		* Llevo el carácter a A1 y lo incremento
	MOVE.L		#0,D0			* Pongo un 0 en D0 ya que se ha escrito el carácter correctamente
	MOVE.L		A1,PUNPA		* Actualizo PUNPA
	CMP.L		A1,A3			* Miro si he llegado al final
	BNE		COMP_EAT		* Si no, salto a COMP_EAT
	LEA		buffPA,A1		* Si he llegado al final llevo buffPA a A1 (buffer circular)
	MOVE.L		A1,PUNPA		* Y actualizo PUNPA
COMP_EAT:
	CMP.L		A1,A2			* Comparo PUNPA y PUNRTIPA
	BNE		ESC_FIN			* Si no son iguales voy a ESC_FIN
	MOVE.B		#1,LLENO_PA		* Si sí son iguales pongo un 1 en LLENO_PA
	BRA		ESC_FIN			* Y salto a ESC_FIN
	
********* ESCRIBE LÍNEA B *************
ESC_B:
	BTST		#1,D0
	BNE		ESC_BT
ESC_BR:
	MOVE.L		PUNSB,A1
	MOVE.L		PUNRTISB,A2
	MOVE.L		FINSB,A3
	MOVE.B		VACIO_SB,D2
	CMP.L		A1,A2
	BNE		ESC_BRN
	CMP.B		#0,D2
	BNE		ESC_BRN
	MOVE.L		#$FFFFFFFF,D0
	BRA		ESC_FIN
ESC_BRN:
	MOVE.B		D1,(A2)+
	MOVE.L		#0,D0
	MOVE.L		A2,PUNRTISB
	CMP.L		A2,A3
	BNE		COMP_EBR
	LEA		buffSB,A2
	MOVE.L		A2,PUNRTISB
COMP_EBR:
	CMP.L		A1,A2
	BEQ		ESC_FIN
	MOVE.B		#0,VACIO_SB
	BRA		ESC_FIN

ESC_BT:
	MOVE.L		PUNPB,A1
	MOVE.L		PUNRTIPB,A2
	MOVE.L		FINPB,A3
	MOVE.B		LLENO_PB,D2
	CMP.L		A1,A2
	BNE		ESC_BTN
	CMP.B		#1,D2
	BNE		ESC_BTN
	MOVE.L		#$FFFFFFFF,D0
	BRA		ESC_FIN
ESC_BTN:
	MOVE.B		D1,(A1)+
	MOVE.L		#0,D0
	MOVE.L		A1,PUNPB
	CMP.L		A1,A3
	BNE		COMP_EBT
	LEA		buffPB,A1
	MOVE.L		A1,PUNPB
COMP_EBT:
	CMP.L		A1,A2
	BNE		ESC_FIN
	MOVE.B		#1,LLENO_PB

ESC_FIN:
	RTS

********* LINEA *******************************************

LINEA:
	BTST		#0,D0			* Miro el valor del 1º bit de D0
	BNE		LIN_B			* Si no es 0 (es 1) salta a LIN_B
	
********* CUENTA LÍNEA A *************
LIN_A:
	BTST		#1,D0			* Miro el valor del 2º bit de D0
	BNE		LIN_AT			* Si no es 0 (es 1) salta a LIN_AT

LIN_AR:
	MOVE.L		PUNSA,A1		* Llevo PUNSA a A1
	MOVE.L		PUNRTISA,A2		* Llevo PUNRTISA a A2
	MOVE.L		FINSA,A3		* Llevo FINSA a A3
	MOVE.B		VACIO_SA,D2		* Llevo VACIO_SA a D2
	MOVE.L		#0,D0			* Ponemos un 0 en D0 (podemos ya machacar lo que tenga, asi ahorramos registros)
	CMP.L		A1,A2			* Comparo PUNSA y PUNRTISA
	BNE		LIN_ARN			* Si no son iguales voy a LIN_ARN para leer normal
	CMP.B		#1,D2			* Miro si está vacío el buffer
	BNE		LIN_ARN			* Si no lo esta, salto a LIN_ARN
	BRA		LIN_FIN			* Y saltamos a LIN_FIN
LIN_ARN:
	MOVE.B		(A1)+,D1		* Llevo el carácter a D1 e incremento A1
	ADD.L		#1,D0			* Aumento el contador de caracteres
	CMP.L		A1,A3			* Miro si he llegado al final 
	BNE		CMP_LIAR		* Si no, salto a CMP_LIAR
	LEA		buffSA,A1		* Si he llegado al final llevo buffSA a A1 (buffer circular)
CMP_LIAR:
	CMP.B		#13,D1			* Si el caracter leido es un retorno de carro
	BEQ		LIN_FIN			* Voy a LIN_FIN
	CMP.L		A1,A2			* Comparo PUNSA y PUNRTISA
	BNE		LIN_ARN			* Si no son iguales voy a LIN_ARN
	MOVE.L		#0,D0			* Pongo un 0 en D0 (hemos terminado de leer el buffer y no hay un retorno de carro)
	BRA		LIN_FIN			* Y salto a LIN_FIN

LIN_AT:
	MOVE.L		PUNPA,A1		* Llevo PUNPA a A1
	MOVE.L		PUNRTIPA,A2		* Llevo PUNRTIPA a A2
	MOVE.L		FINPA,A3		* Llevo FINPA a A3
	MOVE.B		LLENO_PA,D2		* Llevo LLENO_PA a D2
	MOVE.L		#0,D0			* Ponemos un 0 en D0 (podemos ya machacar lo que tenga, asi ahorramos registros)
	CMP.L		A1,A2			* Comparo PUNPA y PUNRTIPA
	BNE		LIN_ATN			* Si no son iguales voy a LIN_ATN para leer normal
	CMP.B		#1,D2			* Miro si está lleno el buffer
	BEQ		LIN_ATN			* Si lo esta, salto a LIN_ATN
	MOVE.L		#0,D0			* Si no, ponemos un 0 en D0
	BRA		LIN_FIN			* Y saltamos a LIN_FIN
LIN_ATN:
	MOVE.B		(A2)+,D1		* Llevo el carácter a D1 e incremento A2
	ADD.L		#1,D0			* Aumento el contador de caracteres
	CMP.L		A2,A3			* Miro si he llegado al final 
	BNE		CMP_LIAT		* Si no, salto a CMP_LIAT
	LEA		buffPA,A2		* Si he llegado al final llevo buffPA a A2 (buffer circular)
CMP_LIAT:
	CMP.B		#13,D1			* Si el caracter leido es un retorno de carro
	BEQ		LIN_FIN			* Voy a LIN_FIN
	CMP.L		A1,A2			* Comparo PUNPA y PUNRTIPA
	BNE		LIN_ATN			* Si no son iguales voy a LIN_ATN
	MOVE.L		#0,D0			* Pongo un 0 en D0 (hemos terminado de leer el buffer y no hay un retorno de carro)
	BRA		LIN_FIN			* Y salto a LIN_FIN

********* CUENTA LÍNEA B *************
LIN_B:	
	BTST		#1,D0			* Miro el valor del 2º bit de D0
	BNE		LIN_BT			* Si no es 0 (es 1) salta a LIN_BT

LIN_BR:
	MOVE.L		PUNSB,A1		* Llevo PUNSA a A1
	MOVE.L		PUNRTISB,A2		* Llevo PUNRTISA a A2
	MOVE.L		FINSB,A3		* Lo estoy haciendo con tus punteros, en mi caso sería buffPA
	MOVE.B		VACIO_SB,D2		* Llevo VACIO_SB a D2
	MOVE.L		#0,D0			* Ponemos un 0 en D0 (podemos ya machacar lo que tenga, asi ahorramos registros)
	CMP.L		A1,A2			* Comparo PUNSA y PUNRTISA
	BNE		LIN_BRN			* Si no son iguales voy a LIN_ARN para leer normal
	CMP.B		#1,D2			* Miro si está vacío el buffer
	BNE		LIN_BRN			* Si no lo esta, salto a LIN_ARN
	BRA		LIN_FIN			* Y saltamos a LIN_FIN
LIN_BRN:
	MOVE.B		(A1)+,D1		* Llevo el carácter a D1 e incremento A1
	ADD.L		#1,D0			* Aumento el contador de caracteres
	CMP.L		A1,A3			* Miro si he llegado al final 
	BNE		CMP_LIBR		* Si no, salto a CMP_LIBR
	LEA		buffSB,A1		* Si he llegado al final llevo buffSB a A1 (buffer circular)
CMP_LIBR:
	CMP.B		#13,D1			* Si el caracter leido es un retorno de carro
	BEQ		LIN_FIN			* Voy a LIN_FIN
	CMP.L		A1,A2			* Comparo PUNSA y PUNRTISA
	BNE		LIN_BRN			* Si no son iguales voy a LIN_BRN
	MOVE.L		#0,D0			* Pongo un 0 en D0 (hemos terminado de leer el buffer y no hay un retorno de carro)
	BRA		LIN_FIN			* Y salto a LIN_FIN

LIN_BT:
	MOVE.L		PUNPB,A1		* Llevo PUNPB a A1
	MOVE.L		PUNRTIPB,A2		* Llevo PUNRTIPB a A2
	MOVE.L		FINPB,A3		* Llevo FINPB a A3, lo mismo digo en mi caso serían buffSA
	MOVE.B		LLENO_PB,D2		* Llevo LLENO_PB a D2
	MOVE.L		#0,D0			* Ponemos un 0 en D0 (podemos ya machacar lo que tenga, asi ahorramos registros)
	CMP.L		A1,A2			* Comparo PUNPB y PUNRTIPB
	BNE		LIN_BTN			* Si no son iguales voy a LIN_BTN para leer normal
	CMP.B		#1,D2			* Miro si está vacío el buffer
	BEQ		LIN_BTN			* Si lo esta, salto a LIN_BTN
	MOVE.L		#0,D0			* Si no, ponemos un 0 en D0
	BRA		LIN_FIN			* Y saltamos a LIN_FIN
LIN_BTN:
	MOVE.B		(A2)+,D1		* Llevo el carácter a D1 e incremento A2
	ADD.L		#1,D0			* Aumento el contador de caracteres
	CMP.L		A2,A3			* Miro si he llegado al final 
	BNE		CMP_LIBT		* Si no, salto a CMP_LIBT
	LEA		buffPB,A2		* Si he llegado al final llevo buffPB a A2 (buffer circular)
CMP_LIBT:
	CMP.B		#13,D1			* Si el caracter leido es un retorno de carro
	BEQ		LIN_FIN			* Voy a LIN_FIN
	CMP.L		A1,A2			* Comparo PUNPB y PUNRTIPB
	BNE		LIN_BTN			* Si no son iguales voy a LIN_BTN
	MOVE.L		#0,D0			* Pongo un 0 en D0 (hemos terminado de leer el buffer y no hay un retorno de carro)
	BRA		LIN_FIN			* Y salto a LIN_FIN

LIN_FIN:
	RTS


********* INIT ********************************************

INIT:
	MOVE.B		#%00000011,MR1A		* 8 bits en A y una interrupción por carácter
	MOVE.B		#%00000011,MR1B		* 8 bits en B y una interrupción por carácter 
	MOVE.B		#%00000000,MR1A		* Eco desactivado en A
	MOVE.B		#%00000000,MR1B		* Eco desactivado en B
	MOVE.B		#%11001100,SRA		* Velocidad de transmisión y recepción = 38400 bps
	MOVE.B		#%11001100,SRB		* Velocidad de transmisión y recepción = 38400 bps
	MOVE.B		#%00000000,ACR		* Conjunto 1 de velocidades de transmisión y recepción
	MOVE.B		#%00000101,CRA		* Habilito transmisión y recepción en A
	MOVE.B		#%00000101,CRB		* Habilito transmisión y recepción en B
	MOVE.B		#$40,IVR		* Vector de interrupción 40
	MOVE.B		#%00100010,IMR		* Habilitar las interrupciones por línea, no por carácter
	MOVE.B		#%00100010,IMRC		* Habilitar las interrupciones por línea, no por carácter en la copia de la IMR

	LEA		RTI,A1				* Dirección de la tabla de vectores a A1
	MOVE.L		#$100,A2			* 100 es la dirección siguiente al vector de interrupción
	MOVE.L		A1,(A2)				* Actualizo la dirección de la tabla de vectores

	LEA		buffSA,A1			* Dirección del buffer SA a A1
	MOVE.L 		A1,PUNSA			* Puntero de SCAN al principio del buffer de A
	MOVE.L 		A1,PUNRTISA			* Puntero de RTI de SCAN al principio del buffer de A
	LEA		fin_SA,A1			* Dirección final del buffer SA a A1
	MOVE.L		A1,FINSA			* Puntero al fin del buffer SA para hacerlo circular

	MOVE.B		#1,VACIO_SA			* Pongo un 1 en VACIO_SA
	
	LEA		buffPA,A1			* Dirección del buffer PA a A1
	MOVE.L		A1,PUNPA			* Puntero de PRINT al principio del buffer de A
	MOVE.L 		A1,PUNRTIPA			* Puntero de RTI de PRINT al principio del buffer de A
	LEA		fin_PA,A1			* Dirección final del buffer PA a A1
	MOVE.L 		A1,FINPA			* Puntero al fin del buffer PA para hacerlo circular

	MOVE.B		#0,LLENO_PA			* Pongo un 0 en LLENO_PA
	
	LEA		buffSB,A1			* Dirección del buffer SB a A1
	MOVE.L 		A1,PUNSB			* Puntero de PRINT al principio del buffer de B
	MOVE.L 		A1,PUNRTISB			* Puntero de RTI de PRINT al principio del buffer de B
	LEA			fin_SB,A1			* Dirección final del buffer SB a A1
	MOVE.L		A1,FINSB			* Puntero al fin del buffer SB para hacerlo circular

	MOVE.B		#1,VACIO_SB			* Pongo un 1 en VACIO_SB
	
	LEA			buffPB,A1			* Dirección del buffer PB a A1
	MOVE.L		A1,PUNPB			* Puntero de PRINT al principio del buffer de B
	MOVE.L 		A1,PUNRTIPB			* Puntero de RTI de PRINT al principio del buffer de B
	LEA			fin_PB,A1			* Dirección final del buffer PB a A1
	MOVE.L		A1,FINPB			* Puntero al fin del buffer PB para hecerlo circular

	MOVE.B		#0,LLENO_PB			* Pongo un 0 en LLENO_PB

	MOVE.B		#0,RET_TBA			* Pongo un 0 en RET_TBA
	MOVE.B		#0,RET_TBB			* Pongo un 0 en RET_TBB
	
	RTS

********* SCAN ********************************************

SCAN:
	LINK		A6,#0			* Marco de pila, 8 bytes para los parametros
	MOVE.L		8(A6),A4		* Direccion del buffer
	MOVE.W		12(A6),D3		* Descriptor
	MOVE.W		14(A6),D4		* Tamaño
	CLR.L		D5			* Inicializo D5 (contador)
	CMP.L		#0,D4			* Miro si tamaño = 0
	BEQ		SCAN_FIN		* Si es así salimos
	CMP.L		#0,D3			* Miro si descriptor = 0
	BEQ		SCAN_A			* Si es así salta a la macro que lee de la línea A
	CMP.L		#1,D3			* Miro si descriptor = 1
	BEQ		SCAN_B			* Si es así salta a la macro que lee de la línea B
	MOVE.L		#$FFFFFFFF,D5		* Si descriptor != 1 ó 0 devuelve ERROR
	BRA		SCAN_FIN		* Salimos
   
********* SCAN LÍNEA A ****************
SCAN_A:
	MOVE.L		#0,D0			* Paso un 00 a LINEA
	BSR		LINEA			* Llamada a LINEA
	CMP.L		#0,D0			* Si buffSA está vacio o no tiene retorno de carro
	BEQ		SCAN_FIN		* Hay ERROR y vamos a SCAN_FIN
	MOVE.L		D0,D6			* Si no, llevamos el tamaño de la línea a D6
	CMP.L		D4,D6			* Comparo tamaño de línea con el parámetro tamaño
	BGT		SCAN_FIN		* Si D6 > D4 dejo de leer
SCLI_A:
	CMP.L 		D5,D6			* Comparo tamaño
	BEQ		SCAN_FIN		* Si son iguales salimos
	MOVE.L		#0,D0			* Si no, paso un 00 a LEECAR
	BSR		LEECAR			* Llamada a LEECAR
	CMP.L		#$FFFFFFFF,D0		* Si buffSA está vacío
	BEQ		SCAN_FIN		* Salimos
	MOVE.B		D0,(A4)+		* Si no, llevo el resultado de LEECAR al buffer
	ADD.L		#1,D5			* Aumento el contador
	BRA		SCLI_A			* Y sigo leyendo

********* SCAN LÍNEA B ****************
SCAN_B:
	MOVE.L		#1,D0			* Paso un 01 a LINEA
	BSR		LINEA			* Llamada a LINEA
	CMP.L		#0,D0			* Si buffSB está vacio o no tiene retorno de carro
	BEQ		SCAN_FIN		* Hay ERROR y vamos a SCAN_FIN
	MOVE.L		D0,D6			* Si no, llevamos el tamaño de la línea a D6
	CMP.L		D4,D6			* Comparo tamaño de línea con el parámetro tamaño
	BGT		SCAN_FIN		* Si D6 > D4 dejo de leer
SCLI_B:
	CMP.L 		D5,D6			* Comparo tamaño
	BEQ		SCAN_FIN		* Si son iguales salimos
	MOVE.L		#1,D0			* Si no, paso un 01 a LEECAR
	BSR		LEECAR			* Llamada a LEECAR
	CMP.L		#$FFFFFFFF,D0		* Si buffSA está vacío
	BEQ		SCAN_FIN		* Salimos
	MOVE.B		D0,(A4)+		* Si no, llevo el resultado de LEECAR al buffer
	ADD.L		#1,D5			* Aumento el contador
	BRA		SCLI_B			* Y sigo leyendo

SCAN_FIN:
	MOVE.L		D5,D0		* Llevo el contador a D0
	UNLK		A6		* Se destruye el marco de pila
	RTS


********* PRINT *******************************************

PRINT:
	LINK		A6,#0			* Marco de pila, 8 bytes para los parametros
	MOVE.L		8(A6),A4		* Direccion del buffer
	MOVE.W		12(A6),D3		* Descriptor
	MOVE.W		14(A6),D4		* Tamaño
	CLR.L 		D5			* Inicializo D5 (contador)
	CMP.L		#0,D4			* Miro si tamaño = 0
	BEQ		PRINT_FIN		* Si es así salimos
	CMP.L 		#0,D3			* Miro si Descriptor = 0
	BEQ 		PRINT_A 		* Si Descriptor = 0, imprime en A
	CMP.L 		#1,D3			* Miro si Descriptor = 1
	BEQ 		PRINT_B			* Si Descriptor = 1, imprime en B
	MOVE.L		#$FFFFFFFF,D5		* Si descriptor != 1 ó 0 devuelve ERROR
	BRA		PRINT_FIN		* Salimos

********* PRINT LÍNEA A ***************
PRINT_A:
	MOVE.B 		(A4)+,D1  		* Llevo el byte del buffer parámetro a D1
	MOVE.L		#2,D0			* Paso un 10 a ESCCAR
	BSR		ESCCAR			* Llamada a ESCCAR
	CMP.L		#0,D0			* Si hay un 0 en D0
	BEQ		COMP_PA			* Salto a COMP_PA
	MOVE.L		#$FFFFFFFF,D5		* Si no, llevo el mensaje de error a D5
	BRA		INT_PA			* Y salto a INT_PA
COMP_PA:
	ADD.L		#1,D5			* Incremento el contador
	CMP.L		#13,D1			* Comprobamos si el caracter escrito en el buffer PA es un retorno de carro
	BEQ		INT_PA			* Si es asi, saltamos a INT_PA
	CMP.L		D4,D5			* Si no, comparo D5 con el tamaño
	BEQ		INT_PA			* Si son iguales salto a INT_PA
	BRA		PRINT_A			* Y sigo escribiendo
INT_PA:
	MOVE.W		#$2700,SR		* Deshabilito las interrupciones
	BSET		#0,IMRC			* Habilito las interrupciones en la línea A
	MOVE.B		IMRC,IMR		* Actualizo la máscara de interrupciones
	MOVE.W		#$2000,SR		* Habilito las interrupciones
	BRA		PRINT_FIN		* Salimos
	
********* PRINT LÍNEA B ***************
PRINT_B:
	MOVE.B 		(A4)+,D1  		* Llevo el byte del buffer parámetro a D1
	MOVE.L		#3,D0			* Paso un 10 a ESCCAR
	BSR		ESCCAR
	CMP.L		#0,D0
	BEQ		COMP_PB
	MOVE.L		#$FFFFFFFF,D5
	BRA		INT_PB
COMP_PB:
	ADD.L		#1,D5
	CMP.L		#13,D1			* Comprobamos si el caracter escrito en el buffer PB es un retorno de carro
	BEQ		INT_PB			* Si es asi, saltamos a INT_PB
	CMP.L		D4,D5
	BEQ		INT_PB
	BRA		PRINT_B
INT_PB:
	MOVE.W		#$2700,SR		* Deshabilito las interrupciones
	BSET		#4,IMRC			* Habilito las interrupciones en la línea B
	MOVE.B		IMRC,IMR		* Actualizo la máscara de interrupciones
	MOVE.W		#$2000,SR		* Habilito las interrupciones
	BRA		PRINT_FIN		* Salimos	
	
PRINT_FIN:
	MOVE.L		D5,D0			* Llevo el contador a D0
	UNLK		A6
	RTS
	
	
********* RTI ********************************************

RTI:
	MOVE.L		D7,-(A7)		* Salvo los registros
	MOVE.L		D6,-(A7)
	MOVE.L		D5,-(A7)
	MOVE.L		D4,-(A7)
	MOVE.L		D3,-(A7)
	MOVE.L		D2,-(A7)
	MOVE.L		D1,-(A7)
	MOVE.L		D0,-(A7)
	MOVE.L		A5,-(A7)
	MOVE.L		A4,-(A7)
	MOVE.L		A3,-(A7)
	MOVE.L		A2,-(A7)
	MOVE.L		A1,-(A7)	
	MOVE.B		IMRC,D1			* Copia de la máscara de interrupción a D1
	AND.B		IMR,D1			* IMR and IMRC a D1
	BTST		#0,D1			* Miro el valor del 1º bit de D1
	BNE		A_TREADY		* Si es 1 voy a A_TREADY
	
	BTST		#1,D1			* Miro el valor del 2º bit de D1
	BNE		A_RREADY		* Si es 1 voy a A_RREADY
	
	BTST		#4,D1			* Miro el valor del 5º bit de D1
	BNE		B_TREADY		* Si es 1 voy a B_TREADY
	
	BTST		#5,D1			* Miro el valor del 6º bit de D1
	BNE		B_RREADY		* Si es 1 voy a B_RREADY
	
	BRA		RTI_FIN			* Si no esta activo ninguno voy a RTI_FIN

********* RECEPCIÓN LÍNEA A ***********
A_RREADY:	
	MOVE.B 		RBA,D1  		* Llevo el byte a D1
	MOVE.L		#0,D0			* Paso un 00 a ESCCAR
	BSR		ESCCAR			* Llamada a ESCCAR
	CMP.L		#0,D0			* Miro si el carácter se ha escrito correctamente
	BEQ		RTI_FIN			* Si es así, salto a RTI_FIN
	MOVE.B		#0,VACIO_SA		* Pongo un 0 en VACIO_SA
	BRA		RTI_FIN			* Y acabo

********* RECEPCIÓN LÍNEA B ***********
B_RREADY:	
	MOVE.B 		RBB,D1  		* Llevo el byte a D1
	MOVE.L		#1,D0			* Paso un 01 a ESCCAR
	BSR		ESCCAR
	CMP.L		#0,D0	
	BEQ		RTI_FIN
	MOVE.B		#0,VACIO_SB
	BRA		RTI_FIN			

********* TRANSMISIÓN LÍNEA A *********
A_TREADY:
	MOVE.B		RET_TBA,D2		* Llevo RET_TBA a D2
	CMP.B		#1,D2
	BNE		A_NORET
	MOVE.B		#10,TBA			* Si es asi, escribimos un salto de linea en TBA
	MOVE.B		#0,RET_TBA		* Pongo un 1 en RET_TBA
	BRA		RTI_FIN			* Y acabo
A_NORET:
	MOVE.L		#2,D0			* Pasamos un 10 LINEA
	BSR		LINEA			* Llamada a LINEA
	CMP.L		#0,D0			* Comprobamos que hay un 0 en D0
	BEQ		DES_A			* Si es asi, es que no hay una linea, saltamos a DES_A
	MOVE.L		#2,D0			* Paso un 10 a LEECAR
	BSR		LEECAR			* Llamada a LEECAR
	CMP.L		#$FFFFFFFF,D0		* Miro si el carácter no se ha leido correctamente
	BEQ		DES_A			* Si es así, voy a DES_A
	MOVE.B		D0,TBA			* Llevamos D0 a TBA
	CMP.L		#13,D0			* Miramos si ha leido un retorno de carro
	BNE		RTI_FIN			* Si no es asi, vamos a RTI_FIN
	MOVE.B		#1,RET_TBA		* Pongo un 1 en RET_TBA
	BRA		RTI_FIN			* Y acabo
DES_A:
	MOVE.W		#$2700,SR		* Si no hay más caracteres inhibo interrupciones		
	BCLR		#0,IMRC			* Deshabilito interrupciones en la linea A
	MOVE.B		IMRC,IMR		* Actualizo IMR
	MOVE.W		#$2000,SR		* Permito de nuevo las interrupciones
	BRA		RTI_FIN			* Salto al final de la RTI

********* TRANSMISIÓN LÍNEA B *********
B_TREADY:
	MOVE.B		RET_TBB,D2		* Llevo RET_TBB a D2
	CMP.B		#1,D2
	BNE		B_NORET
	MOVE.B		#10,TBB			* Si es asi, escribimos un salto de linea en TBA
	MOVE.B		#0,RET_TBB		* Pongo un 1 en RET_TBA
	BRA		RTI_FIN			* Y acabo
B_NORET:
	MOVE.L		#3,D0			* Pasamos un 11 LINEA
	BSR		LINEA			* Llamada a LINEA
	CMP.L		#0,D0			* Comprobamos que hay un 0 en D0
	BEQ		DES_B			* Si es asi, es que no hay una linea, saltamos a DES_B
	MOVE.L		#3,D0			* Paso un 11 a LEECAR
	BSR		LEECAR			* Llamada a LEECAR
	CMP.L		#$FFFFFFFF,D0		* Miro si el carácter no se ha leido correctamente
	BEQ		DES_B			* Si es así, voy a DES_B
	MOVE.B		D0,TBB			* Si se ha leido correctamente lo llevo a TBB
	CMP.L		#13,D0			* Miramos si ha leido un retorno de carro
	BNE		RTI_FIN			* Si no es asi, vamos a RTI_FIN
	MOVE.B		#1,RET_TBB		* Pongo un 1 en RET_TBB
	BRA		RTI_FIN			* Y acabo
DES_B:
	MOVE.W		#$2700,SR		* Si no hay más caracteres inhibo interrupciones		
	BCLR		#4,IMRC			* Deshabilito interrupciones en la linea B
	MOVE.B		IMRC,IMR		* Actualizo IMR
	MOVE.W		#$2000,SR		* Permito de nuevo las interrupciones
	BRA		RTI_FIN			* Salto al final de la RTI

RTI_FIN:	
	MOVE.L		(A7)+,A1		* Recupero los registros
	MOVE.L		(A7)+,A2
	MOVE.L		(A7)+,A3
	MOVE.L		(A7)+,A4
	MOVE.L		(A7)+,A5
	MOVE.L		(A7)+,D0
	MOVE.L		(A7)+,D1
	MOVE.L		(A7)+,D2
	MOVE.L		(A7)+,D3
	MOVE.L		(A7)+,D4
	MOVE.L		(A7)+,D5
	MOVE.L		(A7)+,D6
	MOVE.L		(A7)+,D7
	RTE


********* PROGRAMA DE PRUEBA ******************************
PPAL0:
	BSR		INIT
	CLR.L		D5
BUPPAL0:
	MOVE.W		#0,D0
	MOVE.W		#61,D1
	BSR		ESCCAR
	ADD.L		#1,D5
	CMP.L		#1499,D5
	BNE		BUPPAL0
	MOVE.W		#0,D0
	MOVE.W		#13,D1
	BSR		ESCCAR

	CLR.L		D5
BUPPAL1:
	MOVE.W		#0,D0
	BSR		LEECAR
	ADD.L		#1,D5
	CMP.L		#1500,D5
	BNE		BUPPAL1

	CLR.L		D5
BUPPAL2:
	MOVE.W		#0,D0
	MOVE.W		#61,D1
	BSR		ESCCAR
	ADD.L		#1,D5
	CMP.L		#999,D5
	BNE		BUPPAL2
	MOVE.W		#0,D0
	MOVE.W		#13,D1
	BSR		ESCCAR

	MOVE.W		#0,D0
	BSR		LINEA
	BREAK

********************************
BUFP02:
	DS.B		3000
PARP02:
	DC.L		0

PPAL02:
	BSR		INIT
	CLR.L		D5
BUPPAL02:
	MOVE.W		#1,D0
	MOVE.W		#61,D1
	BSR		ESCCAR
	ADD.L		#1,D5
	CMP.L		#1000,D5
	BNE		BUPPAL02
	MOVE.W		#1,D0
	MOVE.W		#13,D1
	BSR		ESCCAR
	MOVE.L		#BUFP02,PARP02
	MOVE.W		#1003,-(A7) 
	MOVE.W		#1,-(A7) 
	MOVE.L		PARP02,-(A7) 
	BSR		SCAN
	ADD.L 		#8,A7 
	ADD.L		D0,PARP02

	CLR.L		D5
BUPPAL12:
	MOVE.W		#1,D0
	MOVE.W		#61,D1
	BSR		ESCCAR
	ADD.L		#1,D5
	CMP.L		#1000,D5
	BNE		BUPPAL12
	MOVE.W		#1,D0
	MOVE.W		#13,D1
	BSR		ESCCAR
	MOVE.W		#1003,-(A7) 
	MOVE.W		#1,-(A7) 
	MOVE.L		PARP02,-(A7) 
	BSR		SCAN
	ADD.L 		#8,A7 

	BREAK

********************************
BUFP03:
	DS.B		3000
PARP03:
	DC.L		0

PPAL03:
	BSR		INIT
	CLR.L		D5
BUPPAL03:
	MOVE.W		#0,D0
	MOVE.W		#67,D1
	BSR		ESCCAR
	ADD.L		#1,D5
	CMP.L		#1900,D5
	BNE		BUPPAL03
	MOVE.W		#0,D0
	MOVE.W		#13,D1
	BSR		ESCCAR
	MOVE.L		#BUFP03,PARP03
	MOVE.W		#1902,-(A7) 
	MOVE.W		#0,-(A7) 
	MOVE.L		PARP03,-(A7) 
	BSR		SCAN
	ADD.L 		#8,A7 
	MOVE.L		#BUFP03,PARP03
	MOVE.W 		D0,-(A7) 
	MOVE.W		#0,-(A7) 
	MOVE.L		PARP03,-(A7)
	BSR 		PRINT
	ADD.L 		#8,A7 
ESPE3:
	BRA 		ESPE3
	BREAK

********* Prueba básica ***************
BUFFER1:
	DS.B		2000

PARDIR1:
	DC.L		0

PPAL1:
	BSR		INIT 
	MOVE.W		#$2000,SR
	MOVE.L		#BUFFER1,PARDIR1
	MOVE.W		#18,-(A7) 
	MOVE.W		#0,-(A7) 
	MOVE.L		PARDIR1,-(A7) 
	BSR 		SCAN
	ADD.L 		#8,A7 				* Restablece la pila
	MOVE.L		#BUFFER1,PARDIR1
	MOVE.W 		D0,-(A7) 
	MOVE.W		#1,-(A7) 
	MOVE.L		PARDIR1,-(A7)
	BSR 		PRINT
	BREAK

********* Prueba 2 ********************
BUFFER2:
    DS.B		2000

PARDIR2:
	DC.L		0

PPAL2:
	BSR 		INIT 
	MOVE.W		#$2000,SR
	MOVE.L		#BUFFER2,PARDIR2
	MOVE.W 		#18,-(A7) 
	MOVE.W 		#1,-(A7) 
	MOVE.L		PARDIR2,-(A7) 
	BSR 		SCAN
	ADD.L 		#8,A7 				* Restablece la pila
	MOVE.L		#BUFFER2,PARDIR2
	MOVE.W 		D0,-(A7) 
	MOVE.W 		#1,-(A7) 
	MOVE.L		PARDIR2,-(A7)
	BSR 		PRINT
	BREAK

********* Prueba 3 ********************
BUFFER3:
	DS.B 2100	* Buffer para lectura y escritura de caracteres
		
PARDIR3:
	DC.L 0		* Direccion que se pasa como parametro
		
PARTAM:
	DC.W 0		* Tamaño que se pasa como parametro
		
CONTC:
	DC.W 0 		* Contador de caracteres a imprimir
		
DESA: 	EQU 0 		* Descriptor linea A
		
DESB: 	EQU 1 		* Descriptor linea B
		
TAMBS:	EQU 30 		* Tamaño de bloque para SCAN
		
TAMBP: 	EQU 7 		* Tamaño de bloque para PRINT
		
* Manejadores de excepciones
PPAL3:
	MOVE.L 		#BUS_ERROR,8	* Bus error handler
	MOVE.L 		#ADDRESS_ER,12 	* Address error handler
	MOVE.L 		#ILLEGAL_IN,16 	* Illegal instruction handler
	MOVE.L 		#PRIV_VIOLT,32 	* Privilege violation handler
	MOVE.L 		#ILLEGAL_IN,40 	* Illegal instruction handler
	MOVE.L 		#ILLEGAL_IN,44 	* Illegal instruction handler
	BSR 		INIT
	MOVE.W 		#$2000,SR 		* Permite interrupciones
	
BUCPR:
	MOVE.W 		#TAMBS,PARTAM 	* Inicializa par ́ametro de tama~no
	MOVE.L 		#BUFFER3,PARDIR3 	* Par ́ametro BUFFER3 = comienzo del buffer
	
OTRAL:
	MOVE.W 		PARTAM,-(A7) 	* Tama~no de bloque
	MOVE.W 		#DESA,-(A7) 	* Puerto A
	MOVE.L 		PARDIR3,-(A7) 	* Direcci ́on de lectura
	
ESPL:
	BSR 		SCAN
	ADD.L 		#8,A7 			* Restablece la pila
	ADD.L 		D0,PARDIR3 		* Calcula la nueva direcci ́on de lectura
	SUB.W 		D0,PARTAM 		* Actualiza el n ́umero de caracteres le ́ıdos
	BNE 		OTRAL 			* Si no se han le ́ıdo todas los caracteres
								* del bloque se vuelve a leer
	MOVE.W 		#TAMBS,CONTC 	* Inicializa contador de caracteres a imprimir
	MOVE.L 		#BUFFER3,PARDIR3 	* Par ́ametro BUFFER3 = comienzo del buffer
	
OTRAE:
	MOVE.W 		#TAMBP,PARTAM 	* Tama~no de escritura = Tama~no de bloque
	
ESPE:
	MOVE.W 		PARTAM,-(A7) 	* Tama~no de escritura
	MOVE.W 		#DESB,-(A7) 	* Puerto B
	MOVE.L 		PARDIR3,-(A7) 	* Direcci ́on de escritura
	BSR 		PRINT
	ADD.L 		#8,A7 			* Restablece la pila
	ADD.L 		D0,PARDIR3 		* Calcula la nueva direcci ́on del buffer
	SUB.W 		D0,CONTC 		* Actualiza el contador de caracteres
	BEQ 		SALIR 			* Si no quedan caracteres se acaba
	SUB.W 		D0,PARTAM 		* Actualiza el tama~no de escritura
	BNE 		ESPE 			* Si no se ha escrito todo el bloque se insiste
	CMP.W 		#TAMBP,CONTC 	* Si el nº de caracteres que quedan es menor que
								* el tama~no establecido se imprime ese n ́umero
	BHI 		OTRAE 			* Siguiente bloque
	MOVE.W 		CONTC,PARTAM
	BRA 		ESPE 			* Siguiente bloque
	
SALIR:
	BRA 		BUCPR
	
BUS_ERROR:
	BREAK 						* Bus error handler
	NOP
	
ADDRESS_ER:
	BREAK 						* Address error handler
	NOP
	
ILLEGAL_IN:
	BREAK 						* Illegal instruction handler
	NOP
	
PRIV_VIOLT:
	BREAK 						* Privilege violation handler
	NOP








* PPAL4 - Ejemplo
BUFFER4:	DS.B	2100
CONTL:	DC.W	0
CONTC4:	DC.W	0
DIRLEC4:	DC.L	0
DIRESC4:	DC.L	0
TAME:	DC.W	0
DESA:	EQU	0
DESB:	EQU	1
NLIN:	EQU	3
TAML:	EQU	30
TAMB:	EQU	5

PPAL4:
	MOVE.L	#BUS_ERR,8
	MOVE.L	#ADDRESS,12
	MOVE.L	#ILLEGAL,16
	MOVE.L	#PRIV_VI,32
	BSR	INIT
	MOVE.W	#$2000,SR

BUCPR4:
	MOVE.W	#0,CONTC4
	MOVE.W	#NLIN,CONTL
	MOVE.L	#BUFFER4,DIRLEC4

OTRAL4:
	MOVE.W	#TAML,-(A7)
	MOVE.W	#DESA,-(A7)
	MOVE.L	DIRLEC4,-(A7)

ESPL4:
	BSR	SCAN
	CMP.L	#0,D0
	BEQ	ESPL4
	ADD.L	#8,A7
	ADD.L	D0,DIRLEC4
	ADD.W	D0,CONTC4
	SUB.W	#1,CONTL
	BNE	OTRAL4
	MOVE.L	#BUFFER4,DIRLEC4

OTRAE4:
	MOVE.W	#TAMB,TAME

ESPE4:
	MOVE.W	TAME,-(A7)
	MOVE.W	#DESB,-(A7)
	MOVE.L	DIRLEC4,-(A7)
	BSR	PRINT
	ADD.L	#8,A7
	ADD.L	D0,DIRLEC4
	SUB.W	D0,CONTC4
	BEQ	SALIR4
	SUB.W	D0,TAME
	BNE	ESPE4
	CMP.W	#TAMB,CONTC4
	BHI	OTRAE4
	MOVE.W	CONTC4,TAME
	BRA	ESPE4

SALIR4:
	BRA	BUCPR4

FIN:
	BREAK

BUS_ERR:
	BREAK 						* Bus error handler
	NOP
	
ADDRESS:
	BREAK 						* Address error handler
	NOP
	
ILLEGAL:
	BREAK 						* Illegal instruction handler
	NOP
	
PRIV_VI:
	BREAK 						* Privilege violation handler
	NOP
