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


******* Memoria *********

    ORG         $400

buffSA:			DS.B	2000    * Buffer SCAN A
finSA:          DS.B    4       * Direccion de buffSA
buffSB:			DS.B	2000    * Buffer SCAN B
finSB:          DS.B    4       * Direccion de buffSB
buffPA:			DS.B	2000    * Buffer PRINT A
finPA:          DS.B    4       * Direccion de buffPA
buffPB:			DS.B	2000    * Buffer PRINT B
finPB:          DS.B    4       * Direccion de buffPB
emptySA:        DS.B	1		* Bit para comprobar si está vacío SA
emptySB:        DS.B	1		* Bit para comprobar si está vacío SB
fullPA:         DS.B	1		* Bit para comprobar si está lleno PA
fullPB:         DS.B	1		* Bit para comprobar si está lleno PB

LIN_TBA:	DS.B	1		* Hay salto de linea en transmision A
LIN_TBB:	DS.B	1		* Hay salto de linea en transmision B
IMRcopia:	DS.B	2		* Copia de la máscara de interrupción

***************************
********* Punteros a utilizar ***************

pSA:			DS.B	4   * Puntero SCAN A
pSARTI:		    DS.B	4   * Puntero RTI SCAN A
pfinSA:         DS.B    4   * Puntero fin de buffer SCAN A
pSB:			DS.B	4   * Puntero SCAN B
pSBRTI:		    DS.B	4   * Puntero RTI SCAN B
pfinSB:         DS.B    4   * Puntero fin de buffer SCAN B
pPA:			DS.B	4   * Puntero PRINT A
pPARTI:		    DS.B	4   * Puntero RTI PRINT A
pfinPA:         DS.B    4   * Puntero fin de buffer PRINT A
pPB: 			DS.B	4   * Puntero PRINT B
pPBRTI:		    DS.B	4   * Puntero RTI PRINT B
pfinPB:         DS.B    4   * Puntero fin de buffer PRINT B

**************************** INIT **************************************************
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

        LEA				buffPA,A1			* Dirección de buffPA -> A1
		MOVE.L			A1,pPA              * pPA apunta al primero del buffPA
		MOVE.L			A1,pPARTI			* puntero para la RTI
		MOVE.B			#0,fullPA			* El buffPA inicialmente no está lleno
        LEA             finPA,A1            * Direccion de fin buffPA
        MOVE.L          A1,pfinPA           * Puntero a dir de fin buffPA

        LEA				buffSB,A1			* Dirección de buffSB -> A1
		MOVE.L			A1,pSB              * pSB apunta al primero del buffSB
		MOVE.L			A1,pSBRTI			* puntero para la RTI
		MOVE.B			#1,emptySB			* El buffSB inicialmente no está lleno
        LEA             finSB,A1               * Direccion de fin buffSB
        MOVE.L          A1,pfinSB           * Puntero a dir de fin buffSB

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
		CMP.L 		#0,D0
		BEQ 		LA_R
		CMP.L 		#1,D0
		BEQ 		LB_R
		CMP.L 		#2,D0
		BEQ			LA_T
		CMP.L 		#3,D0
		BEQ 		LB_T
        MOVE.L      #$FFFFFFFF,D0
        BRA         L_FIN


LA_R:
        MOVE.L      pSA,A1          * Carga puntero
        MOVE.L      pSARTI,A2       * Carga puntero RTI
        CMP.L       A1,A2           * Se comparan los punteros
        BNE         LA_RLEE         * Si son distintos leo
        MOVE.B      emptySA,D2      * Flag de vacio
        CMP.B       #1,D2           * Son iguales, buffer vacio?
        BNE.L       LA_RLEE         * No son iguales, leo
        MOVE.L      #$FFFFFFFF,D0   * Punteros iguales y/o buffer vacio
        BRA         L_FIN
LA_RLEE:
        MOVE.B      (A1)+,D0        * Lee el caracter en D0
        MOVE.L      A1,pSA          * Actualiza puntero pSA
        MOVE.L      pfinSA,A3       * PUNTERO DE fin
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
        CMP.L       A1,A2           * Se comparan los punteros
        BNE         LA_TLEE         * Si no son iguales, leo
        MOVE.B      fullPA,D2       * Flag de lleno
        CMP.B       #0,D2           * Si lo son, buffer lleno?
        BNE         LA_TLEE         * Si no, leo
        MOVE.L      #$FFFFFFFF,D0   * Punteros iguales y/o buffer lleno
        BRA         L_FIN           * salida
LA_TLEE:
        MOVE.B      (A2)+,D0        * Lee el caracter en d0
        MOVE.L      A2,pPARTI       * Actualiza Puntero
        MOVE.L      pfinPA,A3       * Carga puntero de fin
        CMP.L       A2,A3           * Compara
        BNE         LA_TAFIN        * Si no son iguales, empiezo a salir
        LEA         buffPA,A2       * Actualiza puntero al principio
        MOVE.L      A2,pPARTI
LA_TAFIN:
        CMP.L       A1,A2           * Compara con RTI
        BNE         L_FIN           * Salida
        MOVE.B      #0,fullPA       * Flag
        BRA         L_FIN           * Salida


LB_R:
        MOVE.L      pSB,A1          * Carga puntero
        MOVE.L      pSBRTI,A2       * Carga puntero RTI
        CMP.L       A1,A2           * Se comparan los punteros
        BNE         LB_RLEE         * Si son distintos leo
        MOVE.B      emptySB,D2      * Flag de vacio
        CMP.B       #1,D2           * Son iguales, buffer vacio?
        BNE.L       LB_RLEE         * No son iguales, leo
        MOVE.L      #$FFFFFFFF,D0   * Punteros iguales y/o buffer vacio
        BRA         L_FIN
LB_RLEE:
        MOVE.B      (A1)+,D0        * Lee el caracter en D0
        MOVE.L      A1,pSB          * Actualiza puntero pSA
        MOVE.L      pfinSB,A3       * PUNTERO DE fin
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
        CMP.L       A1,A2           * Se comparan los punteros
        BNE         LB_TLEE         * Si no son iguales, leo
        MOVE.B      fullPB,D2       * Flag de lleno
        CMP.B       #0,D2           * Si lo son, buffer lleno?
        BNE         LB_TLEE         * Si no, leo
        MOVE.L      #$FFFFFFFF,D0   * Punteros iguales y/o buffer lleno
        BRA         L_FIN           * salida
LB_TLEE:
        MOVE.B      (A2)+,D0        * Lee el caracter en d0
        MOVE.L      A2,pPBRTI       * Actualiza Puntero
        MOVE.L      pfinPB,A3       * Carga puntero de fin
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
		CMP.L 		#0,D0
		BEQ 		EA_R
		CMP.L 		#1,D0
		BEQ 		EB_R
		CMP.L 		#2,D0
		BEQ			EA_T
		CMP.L 		#3,D0
		BEQ 		EB_T
        MOVE.L      #$FFFFFFFF,D0
        BRA         L_FIN
EA_R:
        MOVE.L		pSA,A1		    * Llevo pSA a A1
        MOVE.L		pSARTI,A2		* Llevo pRTISA a A2
        CMP.L		A1,A2			* Comparo punteros
        BNE         EA_RESC			* Si no son iguales voy a EA_RESC para escribir normal
        MOVE.B		emptySA,D2		* Llevo emptySA a D2
        CMP.B		#0,D2			* Miro si no está vacío el buffer
        BNE         EA_RESC         * Si los punteros son iguales y está vacío voy a EA_RESC
        MOVE.L		#$FFFFFFFF,D0
        BRA         E_FIN           * Y salto a E_FIN
EA_RESC:
        MOVE.B		D1,(A2)+		* Llevo el carácter a A2 y lo incremento
        MOVE.L		#0,D0			* Pongo un 0 en D0 ya que se ha escrito el carácter correctamente
        MOVE.L		A2,pSARTI		* Actualizo puntero
        MOVE.L		pfinSA,A3		* Llevo puntero a A3
        CMP.L		A2,A3			* Miro si he llegado al final
        BNE         EA_RFIN         * Si no, salto
        LEA         buffSA,A2		* Si he llegado al final llevo buffSA a A2
        MOVE.L		A2,pSARTI		* Y actualizo punteros
EA_RFIN:
        CMP.L		A1,A2			* Comparo punteros
        BEQ         E_FIN			* Si son iguales voy a E_FIN
        MOVE.B		#0,emptySA		* Si no, pongo un 0 en emptySA
        BRA         E_FIN			* Y salto a E_FIN

EA_T:
        MOVE.L		pPA,A1          * Llevo puntero a A1
        MOVE.L		pPARTI,A2		* Llevo puntero a A2
        CMP.L		A1,A2			* Comparo punteros
        BNE         EA_TESC			* Si no son iguales voy a EA_TESC para escribir
        MOVE.B		fullPA,D2		* Llevo puntero a D2
        CMP.B		#1,D2			* Miro si está lleno el buffer
        BNE         EA_TESC			* Si punteros son iguales y está lleno salto
        MOVE.L		#$FFFFFFFF,D0	* Si punteros son iguales y no está lleno devuelv
        BRA         E_FIN			* Y salto a E_FIN
EA_TESC:
        MOVE.B		D1,(A1)+		* Llevo el carácter a A1 y lo incremento
        MOVE.L		#0,D0			* Pongo un 0 en D0 ya que se ha escrito el carácter correctamente
        MOVE.L		A1,pPA		    * Actualizo puntero
        MOVE.L		pfinPA,A3		* Llevo punter a A3
        CMP.L		A1,A3			* Miro si he llegado al final
        BNE         EA_TFIN		    *   Si no, salto
        LEA         buffPA,A1		* Si he llegado al final llevo buffPA a A1
        MOVE.L		A1,pPA		    * Y actualizo puntero
EA_TFIN:
        CMP.L		A1,A2			* Comparo punteros
        BNE         E_FIN			* Si no son iguales voy a E_FIN
        MOVE.B		#1,fullPA		* Si sí son iguales
        BRA         E_FIN

EB_R:
        MOVE.L		pSB,A1		* Llevo punteros a A1
        MOVE.L		pSBRTI,A2		* Llevo puntero a A2
        CMP.L		A1,A2			* Comparo punteros
        BNE         EB_RESC			* Si no son iguales salto
        MOVE.B		emptySB,D2		* Llevo emptySA a D2
        CMP.B		#0,D2			* Miro si no está vacío el buffer
        BNE         EB_RESC         * Si los punteros son iguales y está vacío voy a EB_RESC
        MOVE.L		#$FFFFFFFF,D0
        BRA         E_FIN           * Y salto a E_FIN
EB_RESC:
        MOVE.B		D1,(A2)+		* Llevo el carácter a A2 y lo incremento
        MOVE.L		#0,D0			* Pongo un 0 en D0 ya que se ha escrito el carácter correctamente
        MOVE.L		A2,pSBRTI		* Actualizo puntero
        MOVE.L		pfinSB,A3		* Llevo puntero a A3
        CMP.L		A2,A3			* Miro si he llegado al final
        BNE         EB_RFIN         * Si no, salto
        LEA         buffSB,A2		* Si he llegado al final llevo buffSA a A2 (buffer circular)
        MOVE.L		A2,pSBRTI		* Y actualizo puntero
EB_RFIN:
        CMP.L		A1,A2			* Comparo punteros
        BEQ         E_FIN			* Si son iguales voy a E_FIN
        MOVE.B		#0,emptySB		* Si no, pongo un 0 en emptySa
        BRA         E_FIN			* Y salto a E_FIN

EB_T:
        MOVE.L		pPB,A1		* Llevo puntero a A1
        MOVE.L		pPBRTI,A2		* Llevo puntero a A2
        CMP.L		A1,A2			* Comparo punteros
        BNE         EB_TESC			* Si no son iguales salto
        MOVE.B		fullPB,D2		* Llevo fullPB a D2
        CMP.B		#1,D2			* Miro si está lleno el buffer
        BNE         EB_TESC			* Si punteros son iguales y está lleno salto
        MOVE.L		#$FFFFFFFF,D0	* Si puntero son iguales y no está lleno devuelv
        BRA         E_FIN			* Y salto a ESC_FIN
EB_TESC:
        MOVE.B		D1,(A1)+		* Llevo el carácter a A1 y lo incremento
        MOVE.L		#0,D0			* Pongo un 0 en D0 ya que se ha escrito el carácter correctamente
        MOVE.L		A1,pPB          * Actualizo puntero
        MOVE.L		pfinPB,A3		* Llevo puntero a A3
        CMP.L		A1,A3			* Miro si he llegado al final
        BNE         EA_TFIN         * Si no, salto
        LEA         buffPB,A1		* Si he llegado al final llevo buffPA a A1
        MOVE.L		A1,pPB          * Y actualizo puntero
EB_TFIN:
        CMP.L		A1,A2			* Comparo punteros
        BNE         E_FIN			* Si no son iguales voy a E_FIN
        MOVE.B		#1,fullPB		* Si sí son iguales


E_FIN:
        RTS


*************** FIN ESCCAR *******************

**************************** SCAN ************************************************************
SCAN:
		LINK		A6,#0
		MOVE.L		8(A6),A4		* Dir. del buffer.
		MOVE.W		12(A6),D3		* Descriptor --> D3
		MOVE.W		14(A6),D4		* Tamaño --> D4
		MOVE.L		#0,D5			* Inicializo contador
		CMP.L		#0,D4			* Si tamaño = 0
		BEQ			SCAN_FIN
		CMP.B		#0,D3
		BEQ			SCAN_A			* Si descriptor = 0 lee de A
		CMP.B		#1,D3
		BEQ			SCAN_B			* Si descriptor = 1 lee de B
		MOVE.L		#$FFFFFFFF,D0	* Si no ERROR
		BRA			SCAN_FIN		* y sale de SCAN
		

SCAN_A:	
		MOVE.L 		#0,D0           *
		BSR 		LINEA           * Se comprueba la linea
		CMP.L 		#0,D0           * Si D0 es 0 salto a fin
		BEQ 		SCAN_FIN
        MOVE.L      D0,D6           * SI no, se guarda el resultado de linea y se compara con tamaño
		CMP.L		D4,D6           * Compruebo contadores
		BGT			SCAN_FIN		* Si son iguales nos salimos
SCA_LO:
        CMP.L       D5,D6
        BEQ         SCAN_FIN
        MOVE.L		#0,D0			* Un 00 en D0 para asegurarnos que esta vacio
		BSR 		LEECAR			* Saltamos a leecar con los dos bits a 0.
		CMP.L		#$FFFFFFFF,D0	* Si d0 = #$FFFFFFFF buffer vacio
		BEQ			SCAN_FIN		* Nos salimos si error.
		MOVE.B		D0,(A4)+		* El caracter leido,D0, lo metemos en A4
		ADD.L		#1,D5			* +1 en contador.
		BRA			SCA_LO			* Vuelvo a Scan
		
SCAN_B:
		MOVE.L 		#1,D0
		BSR 		LINEA
		CMP.L 		#0,D0
		BEQ 		SCAN_FIN
        MOVE.L      D0,D6
		CMP.L		D4,D6
		BGT			SCAN_FIN
SCB_LO:
        CMP.L       D5,D6
        BEQ         SCAN_FIN
        MOVE.L		#1,D0			* Un 01 en D0
		BSR 		LEECAR			* Saltamos a leecar
		CMP.L		#$FFFFFFFF,D0	* Si d0 = #$FFFFFFFF buffer vacio
		BEQ			SCAN_FIN		* Nos salimos si error.
		MOVE.B		D0,(A4)+		* El caracter leido,D0, lo metemos en A1
		ADD.L		#1,D5			* +1 en contador.
		BRA			SCB_LO			* Vuelvo a Scan

SCAN_FIN:
        MOVE.L      #0,D0           * Limpia D0
        MOVE.L 		D5,D0
        UNLK 		A6
		RTS


		
******************************* FIN SCAN *****************************************************
****************************  PRINT  *********************************************************
 

PRINT:  LINK		A6,#0
		MOVE.L		8(A6),A4		* Dirección del buffer.
		MOVE.W		12(A6),D3		* Descriptor --> D3
		MOVE.W		14(A6),D4		* Tamaño --> D4
		MOVE.L		#0,D5			* Inicialización D5 = 0
		CMP.L		#0,D4			* Si tamaño = 0
		BEQ			PRINT_FIN
		CMP.W		#0,D3
		BEQ			PRINT_A			* Si descriptor = 0 escribe en A
		CMP.W		#1,D3
		BEQ			PRINT_B			* Si descriptor = 1 escribe en B
		MOVE.L		#$FFFFFFFF,D5	* Si no ERROR,
		BRA			PRINT_FIN		* y sale de PRINT.
		
PRINT_A:
		MOVE.B		(A4)+,D1		* D1 caracter a escribir por ESCCAR
		MOVE.L		#2,D0			* 10 en D0
        BSR         ESCCAR
		CMP.L 		#0,D0
		BEQ 		PR_A
		MOVE.L		#$FFFFFFFF,D5	* Si d0 = #$FFFFFFFF buffer lleno
		BRA			FIN_PA			* Nos salimos

PR_A:
        ADD.L		#1,D5			* Contador ++
        CMP.L       #13,D1
        BEQ         FIN_PA
        CMP.L       D4,D5
        BEQ         FIN_PA
		BRA 		PRINT_A

FIN_PA:
		MOVE.W		#$2700,SR		* Inhibimos interrupciones
		BSET.B		#0,IMRcopia		* Habilitamos las interrupciones en A
		MOVE.B		IMRcopia,IMR	* Actualizamos IMR
		MOVE.W		#$2000,SR		* Permitimos de nuevo las interrupciones
		BRA         PRINT_FIN

PRINT_B:
		MOVE.B		(A4)+,D1		* D1 caracter a escribir por ESCCAR
		MOVE.L		#3,D0			* 11 en D0
        BSR         ESCCAR
		CMP.B 		#0,D0
		BEQ 		PR_B
		MOVE.L		#$FFFFFFFF,D5	* Si d0 = #$FFFFFFFF buffer lleno
		BRA         FIN_PB			* Nos salimos

PR_B:
        ADD.L		#1,D5			* Contador ++
        CMP.L       #13,D1
        BEQ         FIN_PB
        CMP.L       D4,D5
        BEQ         FIN_PB
		BRA 		PRINT_B

FIN_PB:
        MOVE.W		#$2700,SR		* Inhibimos interrupciones
		BSET.B		#4,IMRcopia		* Habilitamos las interrupciones en A
		MOVE.B		IMRcopia,IMR	* Actualizamos IMR
		MOVE.W		#$2000,SR		* Permitimos de nuevo las interrupciones        
        BRA PRINT_FIN

PRINT_FIN:
        MOVE.L      #0,D0           * Limpia D0
        MOVE.L 		D5,D0           * Mueve el contador a D0
        UNLK		A6
		RTS  
**************************** FIN PRINT ******************************************************

**********************  LINEA  ******************************
LINEA:
		CMP.L 		#0,D0
		BEQ 		LINA_R
		CMP.L 		#1,D0
		BEQ 		LINB_R
		CMP.L 		#2,D0
		BEQ			LINA_T
		CMP.L 		#3,D0
		BEQ 		LINB_T

LINA_R:
        MOVE.L		pSA,A1		    * Cargamos el puntero que vamos a utilizar
		MOVE.L 		pSARTI,A2		* Cargamos el puntero de SCAN
		MOVE.L		pfinSA,A3		* Cargamos el final del buff
        MOVE.L      #0,D0
        CMP.L       A1,A2           * Se comparan los punteros
        BNE         LINA_RN         * Si no son iguales se sigue en LINA_RN
        MOVE.B      emptySA,D2      * FLAG DE vacio
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
        MOVE.L		#0,D0
        CMP.L       A1,A2           * Se comparan los punteros
        BNE         LINA_TN         * SI no son iguales se sigue
        MOVE.B      fullPA,D2       * Flag de buffer lleno
        CMP.B       #1,D2           * Si lo son, se comprueba el flag de lleno
        BNE         LINA_TN         * Si flag lleno, salida
        MOVE.L      #0,D0           * Al salir, 0 -> D0
        BRA         LI_FIN          * Salida

LINA_TN:
        MOVE.B      (A2)+,D1        * Se lee y carga el caracter en D1
        ADD.L       #1,D0           * Contador ++
        CMP.L       A2,A3           * se ha llegado al fin?
        BNE         LINA_TFIN       *
        LEA         buffPA,A2       * Se resetea el puntero

LINA_TFIN:
        CMP.B       #13,D1          * Caracter leido igual a retorno de carro?
        BEQ         LI_FIN          * Si, salida.
        CMP.L       A1,A2           *
        BNE         LINA_TN
        MOVE.L      #0,D0           * 0 al salir.
        BRA         LI_FIN          * salida

LINE_B:
		BTST		#1,D0			* Comprobamos el bit 1
		BNE			LINB_T			* Si es 0 selecciona el buff de recepción

LINB_R:
        MOVE.L		pSB,A1		    * Cargamos el puntero que vamos a utilizar
		MOVE.L 		pSBRTI,A2		* Cargamos el puntero de SCAN
		MOVE.L		pfinSB,A3		* Cargamos el final del buff
        MOVE.L		#0,D0
        CMP.L       A1,A2           * Se comparan los punteros
        BNE         LINB_RN         * Si no son iguales se sigue en LINA_RN
        MOVE.B      emptySB,D2      * FLAG DE vacio
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
        MOVE.L      #0,D0           * Contador
        CMP.L       A1,A2           * Se comparan los punteros
        BNE         LINB_TN         * SI no son iguales se sigue
        MOVE.B      fullPB,D2       * Flag de buffer lleno
        CMP.B       #1,D2           * Si lo son, se comprueba el flag de lleno
        BNE         LINB_TN         * Si flag lleno, salida
        MOVE.L      #0,D0           * Al salir, 0 -> D0
        BRA         LI_FIN          * Salida

LINB_TN:
        MOVE.B      (A2)+,D1        * Se lee y carga el caracter en D1
        ADD.L       #1,D0           * Contador ++
        CMP.L       A2,A3           * se ha llegado al fin?
        BNE         LINB_TFIN       *
        LEA         buffPB,A2       * Se resetea el puntero

LINB_TFIN:
        CMP.B       #13,D1          * Caracter leido igual a retorno de carro?
        BEQ         LI_FIN          * Si, salida.
        CMP.L       A1,A2           *
        BNE         LINB_TN
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
        MOVE.B		LIN_TBA,D2
		CMP.B		#1,D2
		BNE         TR_A
        MOVE.B      #0,LIN_TBA
        MOVE.B      #10,TBA
        BRA         RTI_FIN

TR_A:
        MOVE.L		#2,D0			* BIT 0 = 0, BIT 1 = 1;
        BSR         LINEA
        CMP.L       #0,D0
        BEQ         FIN_TA
		MOVE.L		#2,D0			* BIT 0 = 0, BIT 1 = 1;
		BSR 		LEECAR			* Salto a leecar.
		CMP.L		#$FFFFFFFF,D0	* Si d0 = #$FFFFFFFF buffer vacio
		BEQ 		FIN_TA			* Si error fin.
		MOVE.B		D0,TBA			* Introducimos el caracter en la linea A de transmisión.	
		CMP.B 		#13,D0
        BNE         RTI_FIN
        MOVE.B      #1,LIN_TBA
		BRA 		RTI_FIN			* Si son iguales hemos terminado

FIN_TA:        	
        MOVE.W		#$2700,SR		* Si no hay más caracteres inhibo interrupciones
        BCLR.B		#0,IMRcopia		* Deshabilitamos interrupciones en la linea A
		MOVE.B		IMRcopia,IMR	* Actualizamos IMR
        MOVE.W		#$2000,SR		* Permito de nuevo las interrupciones
		BRA			RTI_FIN			* Saltamos al final de la rti
		
T_RDY_B:
        MOVE.B		LIN_TBB,D2
		CMP.B		#1,D2
		BNE         TR_B
        MOVE.B      #0,LIN_TBB
        MOVE.B      #10,TBB
        BRA         RTI_FIN

TR_B:
        MOVE.L		#3,D0			* BIT 0 = 1, BIT 1 = 1;
        BSR         LINEA
        CMP.L       #0,D0
        BEQ         FIN_TB
		MOVE.L		#3,D0			* BIT 0 = 1, BIT 1 = 1;
		BSR 		LEECAR			* Salto a leecar.
		CMP.L		#$FFFFFFFF,D0	* Si d0 = #$FFFFFFFF buffer vacio
		BEQ 		FIN_TB			* Si error fin.
		MOVE.B		D0,TBB			* Introducimos el caracter en la linea A de transmisión.
		CMP.B 		#13,D0
        BNE         RTI_FIN
        MOVE.B      #1,LIN_TBB
		BRA 		RTI_FIN			* Si son iguales hemos terminado
		
FIN_TB:       
        MOVE.W		#$2700,SR		* Si no hay más caracteres inhibo interrupciones
        BCLR.B		#4,IMRcopia		* Deshabilitamos interrupciones en la linea A
		MOVE.B		IMRcopia,IMR	* Actualizamos IMR
        MOVE.W		#$2000,SR		* Permito de nuevo las interrupciones
		BRA			RTI_FIN			* Saltamos al final de la rti

R_RDY_A:
		MOVE.B		RBA,D1			* Cogemos el caracter del puerto de recepción
		MOVE.L		#0,D0			* BIT 0 = 0, BIT 1 = 0;
		BSR			ESCCAR			* Vamos a rutina ESCCAR
        CMP.L       #0,D0           * BIT 0 = 0, BIT 1 = 0;
        BEQ         RTI_FIN
        MOVE.B      #0,emptySA
		BRA			RTI_FIN			* Si error, fin.

R_RDY_B:
		MOVE.B		RBB,D1			* Cogemos el caracter del puerto de recepción
		MOVE.B      #1,D0           * BIT 0 = 1, BIT 1 = 0;
		BSR		ESCCAR              * Vamos a rutina ESCCAR
        CMP.L       #0,D0
        BEQ         RTI_FIN
        MOVE.B      #0,emptySB
        BRA		RTI_FIN             * si error fin.

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



PR39:
    BSR INIT
    LEA pSA,A1
    MOVE.L #1,D1
	MOVE.B D1,(A1)+ 
	MOVE.L #2,D1
	MOVE.B D1,(A1)+	
	MOVE.L #3,D1
	MOVE.B D1,(A1)+
	MOVE.L #4,D1
	MOVE.B D1,(A1)+
	MOVE.L #5,D1
	MOVE.B D1,(A1)+
	MOVE.L #6,D1
	MOVE.B D1,(A1)+
	MOVE.L #7,D1
	MOVE.B D1,(A1)+
	MOVE.L #8,D1
	MOVE.B D1,(A1)+
	MOVE.L #9,D1	
	MOVE.B D1,(A1)+
	MOVE.L #$0D,D1
	MOVE.B D1,(A1)+ 
	MOVE.L A1,punSA
    MOVE.W #10,-(A7) * Tama~no de escritura
	MOVE.W #DESA,-(A7) * Puerto B
	MOVE.L DIRLEC,-(A7) * Direcci ́on de lectura
    BSR PRINT
    BREAK


