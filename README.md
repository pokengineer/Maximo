
# Consignas 
Sea un lenguaje sencillo que permite tres tipos de sentencias 
1)	READ 
2)	WRITE  
3)	ASIGNACIONES-MAXIMO 

##### READ 
Permite la lectura de una variable numérica 
##### WRITE 
Permite la escritura de una variable numérica y de una constante string 
##### ASIGNACION-MAXIMO 
Pueden ser de dos tipos: 
•	Calcula el máximo de una lista de constantes, lo divide por una variable entera o una constante, y se lo asigna a una variable. Por ejemplo:   f1=maximo(1,2,3,4)   / c 
•	Calcula el máximo de una lista de constantes, y se lo asigna a una variable. Por ejemplo:   
f1=maximo(1,2,3,4)    
 
 
Sea la gramática del lenguaje enunciado 
Gramática < { S, MAX, LISTA, WRITE, READ, PROG, SENT,ASIG,FACTOR },  { read, maximo, cte, id, asigna, para, parc, cte_s, write, coma, opDiv} , S , Reglas } 
Reglas:  
0.	S → PROG 
1.	PROG → SENT 
2.	PROG → PROG SENT 
3.	SENT → READ | WRITE | ASIG 
4.	ASIG → id asigna MAX   opDiv FACTOR 
5.	ASIG → id asigna MAX    
6.	MAX →  maximo para L parc   
7.	FACTOR →   id  
8.	FACTOR →  cte 
9.	READ → read id 
10.	LISTA → cte 
11.	LISTA → LISTA coma cte 
12.	WRITE → write cte_s 
13.	WRITE → write id 

## Se Pide:
Hacer un compilador completo que solo se base en la gramática dada y con los siguientes requisitos 
1)	Los elementos léxicos son los indicados como terminales en la definición de la gramática • 	CTE : secuencia de dígitos (Solo representa ctes enteras positivas) 
•	ID: letra seguida de letras o dígitos o una letra sola. 
•	WRITE,READ,MAXIMO : representan las palabras reservadas correspondientes 
•	ASIGNA :  = 
•	PARA: ( 
•	PARC: ) 
•	CTE_S:  texto de letras y símbolos únicamente, encerrados entre comillas. 
•	COMA: , 
•	opDiv: / 
 
2)	El programa testing.txt debe ser el siguiente 
	 	 	WRITE “Ingrese un valor entero positivo: “ 
READ X max = maximo (x1…..x8)   resul = maximo (x1…..x8)  / X 
	 	 	WRITE “El maximo es: “ 
	 	 	WRITE max 
WRITE “El resultado es: “ 
	 	 	WRITE resul 
