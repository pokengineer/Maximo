/*---- 1. Declaraciones ----*/
%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <math.h>
    #include <conio.h>
    #include "y.tab.h"
    int yycolumn = 1;
    #define YY_USER_ACTION  yylloc.first_line = yylloc.last_line = yylineno; \
                            yylloc.first_column = yycolumn; yylloc.last_column = yycolumn + yyleng -1; \
                            yycolumn += yyleng;

    void validarString(char[]);
    void validarInt(int);
%}

/*---- 2. Conjuntos y Regex ----*/

%option noyywrap
%option yylineno

DIGITO      [0-9]
LETRA       [a-zA-Z]
ESPACIO     [" "]
COMA        [","]
CARACTER	[a-z,A-Z,0-9]
ESPECIALES  ["!","#", "$", "%", "&", "/", "?", "¿", "¡", "°", "|", "^", "~", ",", ";", ":", ".", "@",  "_", "-", "¨", "`", "*", "º", "\", "¬"]
CADENA              \"[^"\n]+\"
CONST_INT       {DIGITO}+
ID              {LETRA}({LETRA}|{DIGITO}|_)*



/*---- 3. Definición de reglas ----*/

%%

"WRITE"         { return write; }
"="             { return asigna; }
"READ"          { return read; }
"maximo"        { return maximo; }
"("             { return para; }
")"             { return parc; }
","             { return coma; }
"/"				{ return opDiv; }

{CADENA}        {
                    yylval.tipo_str = yytext;
                    //validarString(yylval.tipo_str);
                    int longitud = strlen(yylval.tipo_str);
                    char aux[longitud];
                    strcpy(aux, yylval.tipo_str);
                    char cadena[longitud];
                    limpiarString(cadena, aux);
                   insertarTS(cadena, "CONST_STR", yylval.tipo_str, 0, 0);
                    return cte_s;
                }
{ID}            {   
                    yylval.tipo_str =strdup( yytext);
                    return id;
                }	
{CONST_INT}     {
                    yylval.tipo_int = atoi(yytext);
                    validarInt(yylval.tipo_int);
                    insertarTS(yytext, "CONST_INT", "", yylval.tipo_int, 0);
                    return cte;
                }
          
\n            { yycolumn = 1; } /*resetear a 1 cada vez que haya una nueva linea*/
\t
%%

/*---- 4. Código ----*/

void validarString(char cadena[])
{
    int largo = strlen(cadena);
    if(largo > 30)
    {
        yyerror("Error: Rango de string excedido. Se permite un maximo de 30 caracteres", 0, 0, 0);
    }
}


void validarInt(int numero)
{
    if(numero > 65535)
    {
        yyerror("Error: Valor de int excedido, el mayor posible es 65535", 0, 0, 0);
    }
}

int yyerror(char *mensaje, int fila, int ci, int cf)
{
    if(fila == 0 || ci == 0 || cf == 0) /* || fila <= yylineno)*/
        printf("\nLinea %d: %s.\n", yylineno, mensaje);
    else
        printf("\nLinea %d, %d-%d: %s.\n", fila, ci, cf, mensaje);
    
    system("Pause");
    exit(1);
}
