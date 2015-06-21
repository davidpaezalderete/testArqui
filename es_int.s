***********************************************************
* Autor:
* David Paez Alderete (q080063)
***********************************************************

********* Inicialización de SP y PC ***********************

	ORG	$0
	DC.L	$8000		* Inicio de Pila
	DC.L	INICIO		* PC al inicio de PPAL1

********* Definición de los registros *********************

MR1A    EQU     $effc01       * de modo A (escritura)
SRA     EQU     $effc03       * de estado A (lectura)
CRA     EQU     $effc05       * de control A (escritura)
TBA     EQU     $effc07       * buffer transmision A (escritura)
RBA     EQU     $effc07       * buffer recepcion A  (lectura)
ACR		EQU		$effc09	      * de control auxiliar
IMR     EQU     $effc0B       * de mascara de interrupcion A (escritura)
MR1B	EQU		$effc11		  * de modo B (escritura)
SRB		EQU		$effc13		  * de estado B (lectura)
CRB		EQU		$effc15		  * de control B (escritura)
TBB     EQU     $effc17       * buffer transmision B (escritura)
RBB     EQU     $effc17       * buffer recepcion B (lectura)
IVR     EQU     $effc19       * del vector de interrupción

********* Punteros a utilizar ***************

pSA:			DS.B	4   * Puntero SCAN A
pSB:			DS.B	4   * Puntero SCAN B
pPA:			DS.B	4   * Puntero PRINT A
pPB: 			DS.B	4   * Puntero PRINT B
pSARTI:		    DS.B	4   * Puntero RTI SCAN A
pSBRTI:		    DS.B	4   * Puntero RTI SCAN B
pPARTI:		    DS.B	4   * Puntero RTI PRINT A
pPBRTI:		    DS.B	4   * Puntero RTI PRINT B
pfinSA:         DS.B    4   * Puntero fin de buffer SCAN A
pfinSB:         DS.B    4   * Puntero fin de buffer SCAN B
pfinPA:         DS.B    4   * Puntero fin de buffer PRINT A
pfinPB:         DS.B    4   * Puntero fin de buffer PRINT B


******* Memoria *********

buffSA:			DS.B	2000    * Buffer SCAN A
buffSB:			DS.B	2000    * Buffer SCAN B
buffPA:			DS.B	2000    * Buffer PRINT A
buffPB:			DS.B	2000    * Buffer PRINT B
finSA:          DS.B    4       * Direccion de buffSA
finSB:          DS.B    4       * Direccion de buffSB
finPA:          DS.B    4       * Direccion de buffPA
finPB:          DS.B    4       * Direccion de buffPB
emptySA:        DS.B	1		* Bit para comprobar si está vacío SA
emptySB:        DS.B	1		* Bit para comprobar si está vacío SB
fullPA:       DS.B	1		* Bit para comprobar si está lleno PA
fullPB:       DS.B	1		* Bit para comprobar si está lleno PB

RET_TBA:	DS.B	1		* Bit para comprobar si hay que escribir un 0A en la RTI
RET_TBB:	DS.B	1		* Bit para comprobar si hay que escribir un 0A en la RTI
IMRcopia:		DS.B	2		* Copia de la máscara de interrupción

***************************

**************************** INIT *************************************************************
INIT:
        MOVE.B          #%00000011,MR1A     * 8 bits por carac. en A y solicita una int. por carac.
		MOVE.B          #%00000000,MR1A     * Eco desactivado en A
		MOVE.B          #%00000011,MR1B     * 8 bits por caract. en B y solicita una int. por carac.
		MOVE.B          #%00000000,MR1B     * Eco desactivado en B
        MOVE.B          #%11001100,SRA     	* Velocidad = 38400 bps.
		MOVE.B          #%11001100,SRB		* Velocidad = 38400 bps.
        MOVE.B          #%00000000,ACR      * Selección del primer conjunto de velocidades.
        MOVE.B          #%00000101,CRA      * Transmision y recepcion activados en A.
		MOVE.B          #%00000101,CRB      * Transmision y recepcion activados en B.
		MOVE.B			#$40,IVR			* Vector de interrupción 40.
		MOVE.B 			#%00100010,IMR 		* Habilitar las interrupciones
		MOVE.B          #%00100010,IMRcopia * Habilitamos las interrupciones en la copia de IMR
		LEA				RTI,A1				* Dirección de la tabla de vectores
		MOVE.L          #$100,A2			* $100 es la dirección siguiente al V.I.
		MOVE.L          A1,(A2)				* Actualización de la dirección de la tabla de vectores

        LEA				buffSA,A1			* Dirección de buffSA -> A1
		MOVE.L			A1,pSA			    * pSA apunta al primero del buffSA
		MOVE.L			A1,pSARTI			* puntero para la RTI
		MOVE.B			#1,emptySA			* El buffSA inicialmente no está lleno
        LEA             finSA,A1            * Direccion de fin buffSA
        MOVE.L          A1,pfinSA           * Puntero a dir de fin buffSA

        LEA				buffSB,A1			* Dirección de buffSB -> A1
		MOVE.L			A1,pSB              * pSB apunta al primero del buffSB
		MOVE.L			A1,pSBRTI			* puntero para la RTI
		MOVE.B			#1,emptySB			* El buffSB inicialmente no está lleno
        LEA             finSB,A1               * Direccion de fin buffSB
        MOVE.L          A1,pfinSB           * Puntero a dir de fin buffSB

        LEA				buffPA,A1			* Dirección de buffPA -> A1
		MOVE.L			A1,pPA              * pPA apunta al primero del buffPA
		MOVE.L			A1,pPARTI			* puntero para la RTI
		MOVE.B			#0,fullPA			* El buffPA inicialmente no está lleno
        LEA             finPA,A1            * Direccion de fin buffPA
        MOVE.L          A1,pfinPA           * Puntero a dir de fin buffPA

        LEA				buffPB,A1			* Dirección de buffPB -> A1
		MOVE.L			A1,pPB              * pPB apunta al primero del buffPB
		MOVE.L			A1,pPBRTI			* puntero para la RTI
		MOVE.B			#0,fullPB			* El buffPB inicialmente no está lleno
		LEA				finPB,A1			* Direccion de fin buffPB
		MOVE.L			A1,pfinPB			* Puntero a dir de fin buffPB

        RTS

**************************** FIN INIT *********************************************************

********** LEECAR **********

LEECAR:
        BTST        #0,D0
        BNE         LB          * Si D0 es 1 voy a leer linea B

LA:
        BTST        #1,D0
        BNE         LA_T        * Si D0 es 1 salta a LA_T

LA_R:
        MOVE.L      pSA,A1          * Carga puntero
        MOVE.L      pSARTI,A2       * Carga puntero RTI
        MOVE.L      pfinSA,A3       * PUNTERO DE fin
        MOVE.L      emptySA,D2      * Flag de vacio
        CMP.L       A1,A2           * Se comparan los punteros
        BNE         LA_RLEE         * Si son distintos leo
        CMP.B       #1,D2           * Son iguales, buffer vacio?
        BNE.L       LA_RLEE         * No son iguales, leo
        MOVE.L      #$FFFFFFFF,D0   * Punteros iguales y/o buffer vacio
        BRA         L_FIN
LA_RLEE:
        MOVE.B      (A1)+,D0        * Lee el caracter en D0
        MOVE.L      A1,pSA          * Actualiza puntero pSA
        CMP.L       A1,A3           * Compara tras leer
        BNE         LA_RFIN         * Si no son iguales empiezo a salir
        LEA         buffSA,A1       * Si son iguales actualiza el puntero al principio
        MOVE.L      A1,pSA
LA_RFIN:
        CMP.L       A1,A2           * Compara con el pRTI
        BNE         L_FIN           * Si no son iguales sale
        MOVE.B      #1,emptySA      * Si son iguales, lleno
        BRA         L_FIN           * Salida

LA_T:
        MOVE.L      pPA,A1          * Carga puntero
        MOVE.L      pPARTI,A2       * Carga puntero RTI
        MOVE.L      pfinPA,A3       * Carga puntero de fin
        MOVE.B      fullPA,D2       * Flag de lleno
        CMP.L       A1,A2           * Se comparan los punteros
        BNE         LA_TLEE         * Si no son iguales, leo
        CMP.B       #0,D2           * Si lo son, buffer lleno?
        BNE         LA_TLEE         * Si no, leo
        MOVE.L      #$FFFFFFFF,D0   * Punteros iguales y/o buffer lleno
        BRA         L_FIN           * salida
LA_TLEE:
        MOVE.B      (A2)+,D0        * Lee el caracter en d0
        MOVE.L      A2,pPARTI       * Actualiza Puntero
        CMP.L       A2,A3           * Compara
        BNE         LA_TAFIN        * Si no son iguales, empiezo a salir
        LEA         buffPA,A2       * Actualiza puntero al principio
        MOVE.L      A2,pPARTI
LA_TAFIN:
        CMP.L       A1,A2           * Compara con RTI
        BNE         L_FIN           * Salida
        MOVE.B      #0,fullPA       * Flag
        BRA         L_FIN           * Salida

LB:
        BTST        #1,D0
        BNE         LB_T            * Si D0 es 1 salta a LB_T

LB_R:
        MOVE.L      pSB,A1          * Carga puntero
        MOVE.L      pSBRTI,A2       * Carga puntero RTI
        MOVE.L      pfinSB,A3       * PUNTERO DE fin
        MOVE.L      emptySB,D2      * Flag de vacio
        CMP.L       A1,A2           * Se comparan los punteros
        BNE         LA_RLEE         * Si son distintos leo
        CMP.B       #1,D2           * Son iguales, buffer vacio?
        BNE.L       LA_RLEE         * No son iguales, leo
        MOVE.L      #$FFFFFFFF,D0   * Punteros iguales y/o buffer vacio
        BRA         L_FIN
LB_RLEE:
        MOVE.B      (A1)+,D0        * Lee el caracter en D0
        MOVE.L      A1,pSB          * Actualiza puntero pSA
        CMP.L       A1,A3           * Compara tras leer
        BNE         LB_RFIN         * Si no son iguales empiezo a salir
        LEA         buffSB,A1       * Si son iguales actualiza el puntero al principio
        MOVE.L      A1,pSB
LB_RFIN:
        CMP.L       A1,A2           * Compara con el pRTI
        BNE         L_FIN           * Si no son iguales sale
        MOVE.B      #1,emptySB      * Si son iguales, lleno
        BRA         L_FIN           * Salida

LB_T:
        MOVE.L      pPB,A1          * Carga puntero
        MOVE.L      pPBRTI,A2       * Carga puntero RTI
        MOVE.L      pfinPB,A3       * Carga puntero de fin
        MOVE.B      fullPB,D2       * Flag de lleno
        CMP.L       A1,A2           * Se comparan los punteros
        BNE         LB_TLEE         * Si no son iguales, leo
        CMP.B       #0,D2           * Si lo son, buffer lleno?
        BNE         LB_TLEE         * Si no, leo
        MOVE.L      #$FFFFFFFF,D0   * Punteros iguales y/o buffer lleno
        BRA         L_FIN           * salida
LB_TLEE:
        MOVE.B      (A2)+,D0        * Lee el caracter en d0
        MOVE.L      A2,pPBRTI       * Actualiza Puntero
        CMP.L       A2,A3           * Compara
        BNE         LB_TBFIN        * Si no son iguales, empiezo a salir
        LEA         buffPB,A2       * Actualiza puntero al principio
        MOVE.L      A2,pPBRTI
LB_TBFIN:
        CMP.L       A1,A2           * Compara con RTI
        BNE         L_FIN           * Salida
        MOVE.B      #0,fullPB       * Flag
        BRA         L_FIN           * Salida

L_FIN:
        RTS

********** FIN LEECAR ****************


********** ESCCAR **********

ESCCAR:
        BTST        #1,D0
        BNE         EB

EA:
        BTST        #1,D0
        BNE         EA_T
EA_R:
        MOVE.L		pSA,A1		* Llevo pSA a A1
        MOVE.L		pSARTI,A2		* Llevo pRTISA a A2
        MOVE.L		pfinSA,A3		* Llevo FINSA a A3
        MOVE.B		emptySA,D2		* Llevo VACIO_SA a D2
        CMP.L		A1,A2			* Comparo PUNSA y PUNRTISA
        BNE         EA_RESC			* Si no son iguales voy a ESC_ARN para escribir normal
        CMP.B		#0,D2			* Miro si no está vacío el buffer
        BNE         EA_RESC         * Si PUNSA y PUNRTISA son iguales y está vacío voy a ESC_ARN
        MOVE.L		#$FFFFFFFF,D0
        BRA         E_FIN           * Y salto a LEE_FIN
EA_RESC:
        MOVE.B		D1,(A2)+		* Llevo el carácter a A2 y lo incremento
        MOVE.L		#0,D0			* Pongo un 0 en D0 ya que se ha escrito el carácter correctamente
        MOVE.L		A2,pSARTI		* Actualizo PUNRTISA
        CMP.L		A2,A3			* Miro si he llegado al final
        BNE         EA_RFIN         * Si no, salto a COMP_EAR
        LEA         buffSA,A2		* Si he llegado al final llevo buffSA a A2 (buffer circular)
        MOVE.L		A2,pSARTI		* Y actualizo PUNRTISA
EA_RFIN:
        CMP.L		A1,A2			* Comparo PUNSA y PUNRTISA
        BEQ         E_FIN			* Si son iguales voy a ESC_FIN
        MOVE.B		#0,emptySA		* Si no, pongo un 0 en VACIO_SA
        BRA         E_FIN			* Y salto a ESC_FIN

EA_T:
        MOVE.L		pPA,A1		* Llevo PUNPA a A1
        MOVE.L		pPARTI,A2		* Llevo PUNRTIPA a A2
        MOVE.L		pfinPA,A3		* Llevo FINPA a A3
        MOVE.B		fullPA,D2		* Llevo LLENO_PA a D2
        CMP.L		A1,A2			* Comparo PUNPA y PUNRTIPA
        BNE         EA_TESC			* Si no son iguales voy a ESC_ATN para escribir normal
        CMP.B		#1,D2			* Miro si está lleno el buffer
        BNE         EA_TESC			* Si PUNPA y PUNRTIPA son iguales y está lleno voy a ESC_ATN
        MOVE.L		#$FFFFFFFF,D0		* Si PUNPA y PUNRTIPA son iguales y no está lleno devuelv
        BRA         E_FIN			* Y salto a ESC_FIN
EA_TESC:
        MOVE.B		D1,(A1)+		* Llevo el carácter a A1 y lo incremento
        MOVE.L		#0,D0			* Pongo un 0 en D0 ya que se ha escrito el carácter correctamente
        MOVE.L		A1,pPA		    * Actualizo PUNPA
        CMP.L		A1,A3			* Miro si he llegado al final
        BNE         EA_TFIN		    *   Si no, salto a COMP_EAT
        LEA         buffPA,A1		* Si he llegado al final llevo buffPA a A1 (buffer circular)
        MOVE.L		A1,pPA		    * Y actualizo PUNPA
EA_TFIN:
        CMP.L		A1,A2			* Comparo PUNPA y PUNRTIPA
        BNE         E_FIN			* Si no son iguales voy a ESC_FIN
        MOVE.B		#1,fullPA		* Si sí son iguales
        BRa         E_FIN

EB:
        BTST        #1,D0
        BNE         EB_T
EB_R:
        MOVE.L		pSB,A1		* Llevo PUNSA a A1
        MOVE.L		pSBRTI,A2		* Llevo PUNRTISA a A2
        MOVE.L		pfinSB,A3		* Llevo FINSA a A3
        MOVE.B		emptySB,D2		* Llevo VACIO_SA a D2
        CMP.L		A1,A2			* Comparo PUNSA y PUNRTISA
        BNE         EB_RESC			* Si no son iguales voy a ESC_ARN para escribir normal
        CMP.B		#0,D2			* Miro si no está vacío el buffer
        BNE         EB_RESC         * Si PUNSA y PUNRTISA son iguales y está vacío voy a ESC_ARN
        MOVE.L		#$FFFFFFFF,D0
        BRA         E_FIN           * Y salto a LEE_FIN
EB_RESC:
        MOVE.B		D1,(A2)+		* Llevo el carácter a A2 y lo incremento
        MOVE.L		#0,D0			* Pongo un 0 en D0 ya que se ha escrito el carácter correctamente
        MOVE.L		A2,pSBRTI		* Actualizo PUNRTISA
        CMP.L		A2,A3			* Miro si he llegado al final
        BNE         EB_RFIN         * Si no, salto a COMP_EAR
        LEA         buffSB,A2		* Si he llegado al final llevo buffSA a A2 (buffer circular)
        MOVE.L		A2,pSBRTI		* Y actualizo PUNRTISA
EB_RFIN:
        CMP.L		A1,A2			* Comparo PUNSA y PUNRTISA
        BEQ         E_FIN			* Si son iguales voy a ESC_FIN
        MOVE.B		#0,emptySB		* Si no, pongo un 0 en VACIO_SA
        BRA         E_FIN			* Y salto a ESC_FIN

EB_T:
        MOVE.L		pPB,A1		* Llevo PUNPA a A1
        MOVE.L		pPBRTI,A2		* Llevo PUNRTIPA a A2
        MOVE.L		pfinPB,A3		* Llevo FINPA a A3
        MOVE.B		fullPB,D2		* Llevo LLENO_PA a D2
        CMP.L		A1,A2			* Comparo PUNPA y PUNRTIPA
        BNE         EB_TESC			* Si no son iguales voy a ESC_ATN para escribir normal
        CMP.B		#1,D2			* Miro si está lleno el buffer
        BNE         EB_TESC			* Si PUNPA y PUNRTIPA son iguales y está lleno voy a ESC_ATN
        MOVE.L		#$FFFFFFFF,D0		* Si PUNPA y PUNRTIPA son iguales y no está lleno devuelv
        BRA         E_FIN			* Y salto a ESC_FIN
EB_TESC:
        MOVE.B		D1,(A1)+		* Llevo el carácter a A1 y lo incremento
        MOVE.L		#0,D0			* Pongo un 0 en D0 ya que se ha escrito el carácter correctamente
        MOVE.L		A1,pPB		* Actualizo PUNPA
        CMP.L		A1,A3			* Miro si he llegado al final
        BNE         EA_TFIN		* Si no, salto a COMP_EAT
        LEA         buffPB,A1		* Si he llegado al final llevo buffPA a A1 (buffer circular)
        MOVE.L		A1,pPB		* Y actualizo PUNPA
EB_TFIN:
        CMP.L		A1,A2			* Comparo PUNPA y PUNRTIPA
        BNE         E_FIN			* Si no son iguales voy a ESC_FIN
        MOVE.B		#1,fullPB		* Si sí son iguales


E_FIN:
        RTS


*************** FIN ESCCAR *******************

**************************** SCAN ************************************************************
SCAN:
		LINK		A6,#0
		MOVE.L		8(A6),A4		* Dir. del buffer.
		MOVE.W		12(A6),D1		* Descriptor --> D1
		MOVE.W		14(A6),D2		* Tamaño --> D2
		MOVE.L		#0,D4			* Inicializo contador
		CMP.L		#0,D2			* Si tamaño = 0
		BEQ			SCAN_FIN
		CMP.B		#0,D1
		BEQ			SCAN_A			* Si descriptor = 0 lee de A
		CMP.B		#1,D1
		BEQ			SCAN_B			* Si descriptor = 1 lee de B
		MOVE.L		#$FFFFFFFF,D0	* Si no ERROR
		BRA			SCAN2_FIN		* y sale de SCAN
		

SCAN_A:	
		MOVE.L 		#0,D0
		BSR 		LINEA
		CMP.L 		#0,D0
		BEQ 		SCAN_FIN
		CMP.L		D2,D0			* Compruebo contadores
		BGT			SCAN_FIN			* Si son iguales nos salimos
SCA_LO:
        CMP.L       D4,D0
        BEQ         SCAN_FIN
        MOVE.L		#0,D0			* Un 0 en D0 para asegurarnos que esta vacio
		BSR 		LEECAR			* Saltamos a leecar con los dos bits a 0.
		CMP.L		#$FFFFFFFF,D0	* Si d0 = #$FFFFFFFF buffer vacio
		BEQ			SCAN_FIN		* Nos salimos si error.
		MOVE.B		D0,(A4)+		* El caracter leido,D0, lo metemos en A1
		ADD.L		#1,D4			* +1 en contador.
		BRA			SCA_LO			* Vuelvo a Scan
		
SCAN_B:
		MOVE.L 		#1,D0
		BSR 		LINEA
		CMP.L 		#0,D0
		BEQ 		SCAN_FIN
		CMP.L		D2,D0			* Compruebo contadores
		BGT			SCAN_FIN			* Si son iguales nos salimos
SCB_LO:
        CMP.L       D4,D0
        BEQ         SCAN_FIN
        MOVE.L		#0,D0			* Un 0 en D0 para asegurarnos que esta vacio
		BSR 		LEECAR			* Saltamos a leecar con los dos bits a 0.
		CMP.L		#$FFFFFFFF,D0	* Si d0 = #$FFFFFFFF buffer vacio
		BEQ			SCAN_FIN		* Nos salimos si error.
		MOVE.B		D0,(A4)+		* El caracter leido,D0, lo metemos en A1
		ADD.L		#1,D4			* +1 en contador.
		BRA			SCB_LO			* Vuelvo a Scan

SCAN_FIN:
		MOVE.L 		D4,D0
        UNLK 		A6
		RTS


		
******************************* FIN SCAN *****************************************************
****************************  PRINT  *********************************************************
 

PRINT:  LINK		A6,#0
		MOVE.L		8(A6),A1		* Dirección del buffer.
		MOVE.W		12(A6),D1		* Descriptor --> D1
		MOVE.W		14(A6),D2		* Tamaño --> D2
		MOVE.L		#0,D4			* Inicialización D4 = 0
		MOVE.L		#0,D0			* Limpio D0
		CMP.W		#0,D2			* Si tamaño = 0
		BEQ			PRINT_FIN
		*BSR 		LINEA
		*CMP.L 		#0,D0
		*BEQ 		PRINT_FIN
		*MOVE.L 		D0,D2	
		CMP.W		#0,D1
		BEQ			PRINT_A			* Si descriptor = 0 escribe en A
		CMP.W		#1,D1
		BEQ			PRINT_B			* Si descriptor = 1 escribe en B
		MOVE.L		#$FFFFFFFF,D0	* Si no ERROR,
		BRA			PRINT_FIN		* y sale de PRINT.
		
PRINT_A:
		CMP.L		D2,D4			* Comprobamos el numero de caracteres leido.
		BEQ			FIN_PA			* Si es igual nos salimos.
		MOVE.L		#2,D0			*BSET.B 		#1,D0// BIT 0 = 0, BIT 1 = 1;
		MOVE.B		(A1)+,D1		* D1 caracter a escribir por ESCCAR
		CMP.B 		#$0D,D1
		BEQ 		FLAGA
		BSR 		ESCCAR			* saltamos a ESCCAR
		CMP.L		#$FFFFFFFF,D0	* Si d0 = #$FFFFFFFF buffer lleno
		BEQ			PR_FIN			* Nos salimos
		ADD.L		#1,D4			* Contador ++
		BRA 		PRINT_A

FIN_PA:
		MOVE.W		#$2700,SR		* Inhibimos interrupciones
		BSET.B		#0,IMRcopia		* Habilitamos las interrupciones en A
		MOVE.B		IMRcopia,IMR	* Actualizamos IMR
		MOVE.W		#$2000,SR		* Permitimos de nuevo las interrupciones        
		MOVE.L 		D4,D0
		UNLK		A6
		RTS 

PRINT_B:
		CMP.L		D2,D4			* Comprobamos el numero de caracteres leido.
		BEQ			FIN_PB			* Si es igual nos salimos
        
        MOVE.B 		#3,D0			* BSET.B		#1,D0 //BIT 0 = 1, BIT 1 = 1;
        MOVE.B		(A1)+,D1		* D1 caracter a escribir por ESCCAR
        CMP.B 		#$0D,D1
		BEQ 		FLAGB
        BSR			ESCCAR			* saltamos a ESCCAR
        CMP.L		#$FFFFFFFF,D0	* Si d0 = #$FFFFFFFF buffer lleno
		BEQ			PR_FIN			* 
		ADD.L		#1,D4			* Contador ++
		BRA 		PRINT_B

FIN_PB:
        MOVE.W		#$2700,SR		* Inhibimos interrupciones
		BSET.B		#4,IMRcopia		* Habilitamos las interrupciones en A
		MOVE.B		IMRcopia,IMR	* Actualizamos IMR
		MOVE.W		#$2000,SR		* Permitimos de nuevo las interrupciones        
		MOVE.L 		D4,D0
		UNLK		A6
		RTS 

FLAGA:
		BSR			ESCCAR
		ADD.L		#1,D4			* Contador ++
		BSR 		FIN_PA

FLAGB:
		BSR			ESCCAR
		ADD.L		#1,D4			* Contador ++
		BSR 		FIN_PB

PR_FIN:	
		MOVE.L 		D4,D0 
PRINT_FIN:
		UNLK		A6
		RTS  
**************************** FIN PRINT ******************************************************

**********************  LINEA  ******************************
LINEA:
		BTST		#0,D0			* Comprobamos el bit 0
		BNE			LINE_B			* Si es 1 Linea de transmision B

LINE_A:	
		BTST		#1,D0			* Comprobamos el bit 1
		BEQ			LINA_T			* Si es 0 selecciona el buff de recepción

LINA_R:
        MOVE.L		pSA,A1		    * Cargamos el puntero que vamos a utilizar
		MOVE.L 		pSARTI,A2		* Cargamos el puntero de SCAN
		MOVE.L		pfinSA,A3		* Cargamos el final del buff
        MOVE.L      emptySA,D2      * FLAG DE vacio
        MOVE.L      #0,D0           * Contador
        CMP.L       A1,A2           * Se comparan los punteros
        BNE         LINA_RN         * Si no son iguales se sigue en LINA_RN
        CMP.B       #1,D2           * Si no, se mira si buff vacio
        BNE         LINA_RN         *
        BRA         LI_FIN

LINA_RN:
        MOVE.B      (A1)+,D1        * Se lee el caracer en D1
        ADD.L       #1,D0           * Contador ++
        CMP.L       A1,A3           * Se comprueban los punteros despues de leer
        BNE         LINA_RFIN        * Si no son iguales se sale
        LEA         buffSA,A1       * Si lo son, se resetea el puntero al principio

LINA_RFIN:
        CMP.B       #13,D1          * Caracter leido igual a retorono de carro?
        BEQ         LI_FIN          * Si lo es, se sale.
        CMP.L       A1,A2           * si no se comprueban los punteros
        BNE         LINA_RN         * si no son iguales se sigue leyendo.
        MOVE.L      #0,D0           * Si lo son, se pone 0 en D0
        BRA         LI_FIN          * Salida

LINA_T:
        MOVE.L      pPA,A1          * Carga puntero
        MOVE.L      pPARTI,A2
        MOVE.L      pfinPA,A3
        MOVE.B      fullPA,D2       * Flag de buffer lleno
        MOVE.L      #0,D2           * Contador
        CMP.L       A1,A2           * Se comparan los punteros
        BNE         LINA_TN         * SI no son iguales se sigue
        CMP.B       #1,D2           * Si lo son, se comprueba el flag de lleno
        BNE         LINA_TN         * Si flag lleno, salida
        MOVE.L      #0,D0           * Al salir, 0 -> D0
        BRA         LI_FIN          * Salida

LINA_TN:
        MOVE.B      (A1)+,D1        * Se lee y carga el caracter en D1
        ADD.L       #1,D2           * Contador ++
        CMP.L       A2,A3           * se ha llegado al fin?
        BNE         LINA_TFIN       *
        LEA         buffPA,A2       * Se resetea el puntero

LINA_TFIN:
        CMP.B       #13,D1          * Caracter leido igual a retorno de carro?
        BEQ         LI_FIN          * Si, salida.
        CMP.L       A1,A2           *
        BNE         LINA_T
        MOVE.L      #0,D0           * 0 al salir.
        BRA         LI_FIN          * salida

LINE_B:
		BTST		#1,D0			* Comprobamos el bit 1
		BEQ			LINB_T			* Si es 0 selecciona el buff de recepción

LINB_R:
        MOVE.L		pSB,A1		    * Cargamos el puntero que vamos a utilizar
		MOVE.L 		pSBRTI,A2		* Cargamos el puntero de SCAN
		MOVE.L		pfinSB,A3		* Cargamos el final del buff
        MOVE.L      emptySB,D2      * FLAG DE vacio
        MOVE.L      #0,D0           * Contador
        CMP.L       A1,A2           * Se comparan los punteros
        BNE         LINB_RN         * Si no son iguales se sigue en LINA_RN
        CMP.B       #1,D2           * Si no, se mira si buff vacio
        BNE         LINB_RN         *
        BRA         LI_FIN

LINB_RN:
        MOVE.B      (A1)+,D1        * Se lee el caracer en D1
        ADD.L       #1,D0           * Contador ++
        CMP.L       A1,A3           * Se comprueban los punteros despues de leer
        BNE         LINB_RFIN        * Si no son iguales se sale
        LEA         buffSA,A1       * Si lo son, se resetea el puntero al principio

LINB_RFIN:
        CMP.B       #13,D1          * Caracter leido igual a retorono de carro?
        BEQ         LI_FIN          * Si lo es, se sale.
        CMP.L       A1,A2           * si no se comprueban los punteros
        BNE         LINB_RN         * si no son iguales se sigue leyendo.
        MOVE.L      #0,D0           * Si lo son, se pone 0 en D0
        BRA         LI_FIN          * Salida

LINB_T:
        MOVE.L      pPB,A1          * Carga puntero
        MOVE.L      pPBRTI,A2
        MOVE.L      pfinPB,A3
        MOVE.B      fullPB,D2       * Flag de buffer lleno
        MOVE.L      #0,D2           * Contador
        CMP.L       A1,A2           * Se comparan los punteros
        BNE         LINB_TN         * SI no son iguales se sigue
        CMP.B       #1,D2           * Si lo son, se comprueba el flag de lleno
        BNE         LINB_TN         * Si flag lleno, salida
        MOVE.L      #0,D0           * Al salir, 0 -> D0
        BRA         LI_FIN          * Salida

LINB_TN:
        MOVE.B      (A1)+,D1        * Se lee y carga el caracter en D1
        ADD.L       #1,D2           * Contador ++
        CMP.L       A2,A3           * se ha llegado al fin?
        BNE         LINB_TFIN       *
        LEA         buffPB,A2       * Se resetea el puntero

LINB_TFIN:
        CMP.B       #13,D1          * Caracter leido igual a retorno de carro?
        BEQ         LI_FIN          * Si, salida.
        CMP.L       A1,A2           *
        BNE         LINB_T
        MOVE.L      #0,D0           * 0 al salir.
        BRA         LI_FIN          * salida

LI_FIN:
        RTS


****************************  FIN LINEA  ********************************************************



**************************** RTI ************************************************************
RTI:
		MOVE.W		D0,-(A7)		* Guardamos los registros utilizados en SCAN y PRINT
		MOVE.W		D1,-(A7)
		MOVE.W		D2,-(A7)
		MOVE.W		D3,-(A7)
		MOVE.W		D4,-(A7)
		MOVE.W		D5,-(A7)
		MOVE.L		A1,-(A7)
		MOVE.L		A2,-(A7)
		MOVE.L		A3,-(A7)
		MOVE.L		A4,-(A7)
		MOVE.B		IMRcopia,D1		* D1 <-- copia de la máscara de interrupción
		AND.B		IMR,D1			* D1 <-- IMR ^ IMRcopia
		BTST		#0,D1			* Comprobamos el bit 0
		BNE			T_RDY_A			* Si es 1 transmitir por linea A
		BTST		#1,D1			* Comprobamos el bit 1
		BNE			R_RDY_A			* Si es 1 recibir por linea A
		BTST		#4,D1			* Comprobamos el bit 4
		BNE			T_RDY_B			* Si es 1 transmitir por linea B
		BTST		#5,D1			* Comprobamos el bit 5
		BNE			R_RDY_B			* Si es 1 recibir por linea B
		BRA			RTI_FIN			* Si no esta activo ninguno saltar a RTI_FIN

T_RDY_A:
        MOVE.B		emptySA,D2
		CMP.B		#0,D2
		BEQ		TLIN_A
		MOVE.L		#0,D0			* D0 = 0
		BSET		#1,D0			* BIT 0 = 0, BIT 1 = 1; 
		BSR 		LEECAR			* Salto a leecar.
		CMP.L		#$FFFFFFFF,D0	* Si d0 = #$FFFFFFFF buffer vacio
		BEQ 		FIN_TA			* Si error fin.
		MOVE.B		D0,TBA			* Introducimos el caracter en la linea A de transmisión.	
		CMP.B 		#$0D,D0
		BEQ 		TLIN_A
		BRA 		RTI_FIN			* Si son iguales hemos terminado

FIN_TA:        	
		BCLR.B		#0,IMRcopia		* Deshabilitamos interrupciones en la linea A
		MOVE.B		IMRcopia,IMR	* Actualizamos IMR
		MOVE.L		#0,D0			* Limpiamos D0 al volver de vacio
		BRA			RTI_FIN			* Saltamos al final de la rti
		
T_RDY_B:
        MOVE.B		emptySB,D2
		CMP.B		#0,D2
		BEQ         TLIN_B
		MOVE.L		#0,D0			* D0 = 0
		BSET		#1,D0			* BIT 0 = 1, BIT 1 = 1
		BSET 		#0,D0			*	
		BSR 		LEECAR			* Salto a LEECAR
		CMP.L		#$FFFFFFFF,D0	* Si d0 = #$FFFFFFFF buffer vacio
		BEQ         FIN_TB			* Si error, fin.
		MOVE.B 		D0,TBB			* Introducimos el caracter en la linea B de transmisión.
		CMP.B 		#$0D,D0
		BEQ 		TLIN_B
		BRA 		RTI_FIN			*
		
FIN_TB:       
		BCLR.B		#4,IMRcopia		* Deshabilitamos interrupciones en la linea A
		MOVE.B		IMRcopia,IMR	* Actualizamos IMR
		MOVE.L		#0,D0			* Limpiamos D0 al volver de D0
		BRA			RTI_FIN			* Saltamos al final de la rti

R_RDY_A:
		MOVE.L		#0,D1			* D1 = 0, para cargar el car a leer en un reg vacio.
		MOVE.B		RBA,D1			* Cogemos el caracter del puerto de recepción
		MOVE.L		#0,D0			* D0 = 0
		BSR			ESCCAR			* Vamos a rutina ESCCAR
		BRA			RTI_FIN			* Si error, fin.


R_RDY_B:
		MOVE.L		#0,D1			* D1 = 0, para cargar el car a leer en un reg vacio.
		MOVE.B		RBB,D1			* Cogemos el caracter del puerto de recepción
		MOVE.W		#0,D0			* Reseteamos D0
		BSET		#0,D0			* BIT 0 = 1
		BSR		ESCCAR			* Vamos a rutina ESCCAR
		BRA		RTI_FIN			* si error fin.

RCA_RTI:	MOVE.B 		#0,emptySA
		BRA 		RTI_FIN


RCB_RTI		MOVE.B 		#0,emptySB
		BRA 		RTI_FIN

TLIN_A:		MOVE.B 		#1,emptySA	
		MOVE.B		#10,TBA
		BRA		FIN_TA

TLIN_B:		MOVE.B 		#1,emptySB		
		MOVE.B		#10,TBB
		BRA		FIN_TB



RTI_FIN:
		MOVE.L		(A7)+,A4		* Restauramos los registros
		MOVE.L		(A7)+,A3
		MOVE.L		(A7)+,A2
		MOVE.L		(A7)+,A1
		MOVE.W		(A7)+,D5
		MOVE.W		(A7)+,D4
		MOVE.W		(A7)+,D3
		MOVE.W		(A7)+,D2
		MOVE.W		(A7)+,D1
		MOVE.W		(A7)+,D0
		RTE


**************************** FIN RTI ********************************************************

*** Programa de prueba

BUFFER: DS.B 2100 * Buffer para lectura y escritura de caracteres
CONTL: DC.W 0 * Contador de l ́ıneas
CONTC: DC.W 0 * Contador de caracteres
DIRLEC: DC.L 0 * Direcci ́on de lectura para SCAN
DIRESC: DC.L 0 * Direcci ́on de escritura para PRINT
TAME: DC.W 0 * Tama~no de escritura para print
DESA: EQU 0 * Descriptor l ́ınea A
DESB: EQU 1 * Descriptor l ́ınea B
NLIN: EQU 3 * N ́umero de l ́ıneas a leer
TAML: EQU 30 * Tama~no de l ́ınea para SCAN
TAMB: EQU 20 * Tama~no de bloque para PRINT

INICIO: * Manejadores de excepciones
	MOVE.L #BUS_ERROR,8 * Bus error handler
	MOVE.L #ADDRESS_ER,12 * Address error handler
	MOVE.L #ILLEGAL_IN,16 * Illegal instruction handler
	MOVE.L #PRIV_VIOLT,32 * Privilege violation handler
	BSR INIT
	MOVE.W #$2000,SR * Permite interrupciones

BUCPR:
	MOVE.W #0,CONTC * Inicializa contador de caracteres
	MOVE.W #NLIN,CONTL * Inicializa contador de L ́ıneas
	MOVE.L #BUFFER,DIRLEC * Direcci ́on de lectura = comienzo del buffer
OTRAL:
	MOVE.W #TAML,-(A7) * Tama~no m ́aximo de la l ́ınea
	MOVE.W #DESA,-(A7) * Puerto A
	MOVE.L DIRLEC,-(A7) * Direcci ́on de lectura
ESPL:
	BSR SCAN
	CMP.L #0,D0
	BEQ ESPL * Si no se ha le ́ıdo una l ́ınea se intenta de nuevo
	ADD.L #8,A7 * Restablece la pila
	ADD.L D0,DIRLEC * Calcula la nueva direcci ́on de lectura
	ADD.W D0,CONTC * Actualiza el n ́umero de caracteres le ́ıdos
	SUB.W #1,CONTL * Actualiza el n ́umero de l ́ıneas le ́ıdas. Si no
	BNE OTRAL * se han le ́ıdo todas las l ́ıneas se vuelve a leer
	MOVE.L #BUFFER,DIRLEC * Direcci ́on de lectura = comienzo del buffer
OTRAE:
	MOVE.W #TAMB,TAME * Tama~no de escritura = Tama~no de bloque
ESPE:
	MOVE.W TAME,-(A7) * Tama~no de escritura
	MOVE.W #DESB,-(A7) * Puerto B
	MOVE.L DIRLEC,-(A7) * Direcci ́on de lectura
	BSR PRINT
	ADD.L #8,A7 * Restablece la pila
	ADD.L D0,DIRLEC * Calcula la nueva direcci ́on del buffer
	SUB.W D0,CONTC * Actualiza el contador de caracteres
	BEQ SALIR * Si no quedan caracteres se acaba
	SUB.W D0,TAME * Actualiza el tama~no de escritura
	BNE ESPE * Si no se ha escrito todo el bloque se insiste
	CMP.W #TAMB,CONTC * Si el node caracteres que quedan es menor que el

	BHI OTRAE * Siguiente bloque
	MOVE.W CONTC,TAME
	BRA ESPE * Siguiente bloque
SALIR: BRA BUCPR
FIN: BREAK
BUS_ERROR:
	BREAK * Bus error handler
	NOP
ADDRESS_ER:
	BREAK * Address error handler
	NOP
ILLEGAL_IN:
	BREAK * Illegal instruction handler
	NOP
PRIV_VIOLT:
	BREAK * Privilege violation handler
	NOP