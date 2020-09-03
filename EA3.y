/*---- 1. Declaraciones ----*/

%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>
#include <conio.h>
#include "y.tab.h"
#define YYERROR_VERBOSE 1
FILE  *yyin;


/* --- Tabla de simbolos --- */
typedef struct
{
        char *nombre;
        char *nombreASM;
        char *tipo;
        union Valor{
                int valor_int;
                double valor_double;
                char *valor_str;
        }valor;
        int longitud;
}t_data;

typedef struct s_simbolo
{
        t_data data;
        struct s_simbolo *next;
}t_simbolo;

typedef struct
{
        t_simbolo *primero;
}t_tabla;


void crearTablaTS();
int insertarTS(const char*, const char*, const char*, int, double);
t_data* crearDatos(const char*, const char*, const char*, int, double);
void guardarTS();
t_simbolo * getLexema(const char *);
char* limpiarString(char*, const char*);
char* reemplazarString(char*, const char*);
t_tabla tablaTS;

int  i=0, contadorString = 0;
char vecAux[100];
char* punt;

/* --- aca escribo mensajes de error --- */
char mensajes[100]; 
/* ---  Arbol   --- */
typedef struct treeNode {
    char* value;
    int nodeId;
    struct treeNode* left;
    struct treeNode* right;
} ast;
FILE *file;
int contadorId = 0;
ast * _write, * _read, *_asig, * _max, *_fact, *_if;
ast* _pProg ,* _pSent;
ast* _aux;
FILE*  intermedia;
ast* newNode();
ast* newLeaf();
void print2DUtil(ast *root, int space);
void print2D(ast *root);
void generarGraphviz(ast* arbol);
void recorrerArbolGraphviz(ast* arbol, FILE* pf);

/* --- Assembler --- */
int vectorEtiquetas[50], topeVectorEtiquetas = -1;
void generarAssembler();
void crearHeader(FILE *);
void crearSeccionData(FILE *);
void crearSeccionCode(FILE *);
void crearFooter(FILE *);
void recorrerArbol( ast * , FILE *);

void    generarAssemblerAsignacion( ast * root , FILE *archAssembler);
void    generarAssemblerAsignacionSimple( ast * root , FILE *archAssembler);

int branchN = 0;

bool esValor(const char *);
%}



%union {
int tipo_int;
double tipo_double;
char *tipo_str;
}

/*---- 2. Tokens - Start ----*/

%start S
%token coma
%token asigna
%token opDiv
%token para
%token parc
%token write
%token read
%token maximo
%token <tipo_str>id
%token <tipo_int>cte
%token <tipo_str>cte_s


/*---- 3. Definición de reglas gramaticales ----*/
%locations

%%

S:      
        PROG    { //printf("\n1\n");
                generarAssembler(); 
                guardarTS();
                print2D( _pProg ); 
                generarGraphviz( _pProg);
                printf("\nCompilacion Exitosa\n"); 
                 }
        ;

PROG:   
        SENT  { //printf("\n2"); 
                _pProg = _pSent;
                }
        |   PROG SENT   {  //printf("\n2bis"); 
                            _pProg = newNode( ";", _pProg, _pSent);
                        }
        ;

SENT:
         READ       { _pSent = _read;}
         | WRITE    { _pSent = _write; }
         | ASIG     { _pSent = _asig;}
         ;
        
ASIG:
        id asigna MAX opDiv FACTOR  { 
                                    //printf("\n6"); 
                                    strcpy(vecAux, $1 );
                                    punt = strtok(vecAux, " ;\n"); 
                                    if(insertarTS(punt, "INT", "", 0, 0) != 0)
                                    {
                                    sprintf(mensajes, "%s%s%s", "Error: la variable '", punt, "' ya fue declarada");
                                    }
                                    _aux = newNode("/", _max , _fact );
                                    _asig = newNode("=", newLeaf( punt ) , _aux);  
                                    }
        | id asigna MAX             {           
                                    //printf("\n7"); 
                                    strcpy(vecAux, $1 );
                                    punt = strtok(vecAux, " ;\n"); 
                                    if(insertarTS(punt, "INT", "", 0, 0) != 0)
                                    {
                                    sprintf(mensajes, "%s%s%s", "Error: la variable '", punt, "' ya fue declarada");
                                    }     
                                    _asig = newNode("=", newLeaf( punt ) , _max );                            
                                    }
        ;

MAX:
        maximo para LISTA parc { //printf("\n8"); 

                                }
        ;

FACTOR:
        id { //printf("\n9"); 
            strcpy(vecAux,  $1 );
            punt = strtok(vecAux, " ;\n"); 
            if(insertarTS(punt, "INT", "", 0, 0) != 0)
            {
             sprintf(mensajes, "%s%s%s", "Error: la variable '", punt, "' ya fue declarada");
            }
            _fact = newLeaf( punt );          
            }
        | cte { //printf("\n10");
            itoa( $1 ,vecAux, 10);
            punt = strtok(vecAux,";\n");
            int valor = atoi(punt);
            if(insertarTS(punt, "CONST_INT", "", valor , 0) != 0)
            {
             sprintf(mensajes, "%s%s%s", "Error: la variable '", punt, "' ya fue declarada");
            }
            _fact = newLeaf( punt );
            }
        ;

READ:
        read id {  
                //printf("\n11");
                strcpy(vecAux, $2);
                punt = strtok(vecAux, " ;\n"); 
                if(insertarTS(punt, "INT", "", 0, 0) != 0)
                {
                sprintf(mensajes, "%s%s%s", "Error: la variable '", punt, "' ya fue declarada");
                }
                strcpy(vecAux, $2);
                punt = strtok(vecAux,";\n");
                _read = newNode("READ", NULL ,newLeaf( punt ));

                }
        ;

LISTA:
        cte {   //printf("\n12");
            itoa( $1 ,vecAux, 10);
            punt = strtok(vecAux,";\n");
            _max = newNode("=", newLeaf(  "@max") , newLeaf( punt ) );
            }
        |LISTA coma cte {//printf("\n13");
                        itoa( $3 ,vecAux, 10);
                        punt = strtok(vecAux,";\n");
                        _if = newNode( "IF",  newNode("<", newLeaf(  "@max") , newLeaf( punt ) ) , newNode("=", newLeaf(  "@max") , newLeaf( punt ) ) );
                        _max = newNode(";", _max , _if );
                        }
        ;

WRITE:
        write cte_s  {  
                        //printf("\n14"); 
                        strcpy(vecAux, $2);
                        punt = strtok(vecAux,";\n");
                        _write = newNode("WRITE", NULL, newLeaf( punt ) );
                        }
        | write id {  //printf("\n15");
                    strcpy(vecAux, $2);
                    punt = strtok(vecAux,";\n");
                    _write = newNode("WRITE", NULL, newLeaf( punt ) );
                    }
        ;

%%


/*---- 4. Código ----*/
int main(int argc, char *argv[])
{
    if((yyin = fopen(argv[1], "rt"))==NULL)
    {
        printf("\nNo se puede abrir el archivo de prueba: %s\r\n", argv[1]);
        return -1;
    }
    else
    { 
        crearTablaTS();
        yyparse();

        fclose(yyin);
        system("Pause"); /*Esta pausa la puse para ver lo que hace via mensajes*/
        return 0;
    }
}

void crearTablaTS()
{
    t_data *data = (t_data*)malloc(sizeof(t_data));
    data = crearDatos("@max", "INT", "", 0, 0);

    if(data == NULL)
    {
        return;
    }

    t_simbolo* nuevo = (t_simbolo*)malloc(sizeof(t_simbolo));

    if(nuevo == NULL)
    {
        return;
    }

    nuevo->data = *data;
    nuevo->next = NULL;
    tablaTS.primero = nuevo;
}
/*---- Tabla de Símbolos ----*/

int insertarTS(const char *nombre, const char *tipo, const char* valString, int valInt, double valDouble)
{
    t_simbolo *tabla = tablaTS.primero;
    char nombreCTE[300] = "_";
    strcat(nombreCTE, nombre);
    
    while(tabla)
    {
        if(strcmp(tabla->data.nombre, nombre) == 0 || strcmp(tabla->data.nombre, nombreCTE) == 0)
        {
            return 1;
        }
        else if(strcmp(tabla->data.tipo, "CONST_STR") == 0)
        {
            
            if(strcmp(tabla->data.valor.valor_str, valString) == 0)
            {
                return 1;
            }
        }
        
        if(tabla->next == NULL)
        {
            break;
        }
        tabla = tabla->next;
    }
    
    t_data *data = (t_data*)malloc(sizeof(t_data));
    data = crearDatos(nombre, tipo, valString, valInt, valDouble);

    if(data == NULL)
    {
        return 1;
    }

    t_simbolo* nuevo = (t_simbolo*)malloc(sizeof(t_simbolo));

    if(nuevo == NULL)
    {
        return 2;
    }

    nuevo->data = *data;
    nuevo->next = NULL;

    if(tablaTS.primero == NULL)
    {
        tablaTS.primero = nuevo;
    }
    else
    {
        tabla->next = nuevo;
    }

    return 0;
}

t_data* crearDatos(const char *nombre, const char *tipo, const char* valString, int valInt, double valDouble)
{
    char full[200] = "_";
    char aux[200];

    t_data *data = (t_data*)calloc(1, sizeof(t_data));
    if(data == NULL)
    {
        return NULL;
    }

    data->tipo = (char*)malloc(sizeof(char) * (strlen(tipo) + 1));
    strcpy(data->tipo, tipo);
    if( strcmp(tipo, "STRING")==0 || strcmp(tipo, "INT")==0 || strcmp(tipo, "FLOAT")==0 )
    {
        data->nombre = (char*)malloc(sizeof(char) * (strlen(nombre) + 1));
        strcpy(data->nombre, nombre);
        data->nombreASM = (char*)malloc(sizeof(char) * (strlen(nombre) + 1));
        strcpy(data->nombreASM, nombre);

        //printf("\n\t\t el nombreASM de %s es %s", data->nombreASM, data->nombre);
        return data;
    }
    else
    {
        if(strcmp(tipo, "CONST_STR") == 0)
        {
            contadorString++;
            
            data->valor.valor_str = (char*)malloc(sizeof(char) * (strlen(valString) + 1));
            strcpy(data->valor.valor_str, valString);

            char auxString[200];
            strcpy(full, ""); 
            strcpy(full, "S_");  // "S_"
            reemplazarString(auxString, nombre);
            strcat(full, auxString); // "S_<nombre>"  
            char numero[10];
            sprintf(numero, "_%d", contadorString);
            strcat(full, numero); // "S_<nombre>_#"

            data->nombre = (char*)malloc(sizeof(char) * (strlen(full) + 1));
            data->nombreASM = (char*)malloc(sizeof(char) * (strlen(full) + 1));
            strcpy(data->nombre, full);
            strcpy(data->nombreASM, data->nombre);
        }
        if(strcmp(tipo, "CONST_INT") == 0)
        {
            sprintf(aux, "%d", valInt);
            strcat(full, aux);
            data->nombre = (char*)malloc(sizeof(char) * (strlen(full) + 1));
            strcpy(data->nombre, full);
            data->valor.valor_int = valInt;
            data->nombreASM = (char*)malloc(sizeof(char) * (strlen(full) + 1));
            strcpy(data->nombreASM, full);
        }
        return data;
    }
    return NULL;
}


char* limpiarString(char* dest, const char* cad)
{
    int i, longitud, j=0;
    longitud = strlen(cad);
    for(i=0; i<longitud; i++)
    {
        if(cad[i] != '"')
        {
            dest[j] = cad[i];
            j++;
        }
    }
    dest[j] = '\0';
    return dest;
}


char* reemplazarString(char* dest, const char* cad)
{
    int i, longitud;
    longitud = strlen(cad);

    for(i=0; i<longitud; i++)
    {
        if((cad[i] >= 'a' && cad[i] <= 'z') || (cad[i] >='A' && cad[i] <= 'Z') || (cad[i] >= '0' && cad[i] <= '9'))
        {
            dest[i] = cad[i];
        }
        else
        {
            dest[i] = '_';
        }
    }
    dest[i] = '\0';
    return dest;
}

void guardarTS()
{
    FILE* arch;
    if((arch = fopen("ts.txt", "wt")) == NULL)
    {
            printf("\nNo se pudo crear la tabla de simbolos.\n\n");
            return;
    }
    else if(tablaTS.primero == NULL)
            return;
    
    fprintf(arch, "%-35s%-30s%-30s%-30s\n", "NOMBRE", "TIPODATO", "VALOR", "LONGITUD");

    t_simbolo *aux;
    t_simbolo *tabla = tablaTS.primero;
    char linea[300];

    while(tabla)
    {
        aux = tabla;
        tabla = tabla->next;
        
        if(strcmp(aux->data.tipo, "INT") == 0)
        {
            sprintf(linea, "%-35s%-30s%-30s%-d\n", aux->data.nombre, aux->data.tipo, "--", strlen(aux->data.nombre));
        }
        else if(strcmp(aux->data.tipo, "CONST_INT") == 0)
        {
            sprintf(linea, "%-35s%-30s%-30d%-d\n", aux->data.nombre, aux->data.tipo, aux->data.valor.valor_int, strlen(aux->data.nombre) -1);
        }
        else if(strcmp(aux->data.tipo, "FLOAT") ==0)
        {
            sprintf(linea, "%-35s%-30s%-30s%-d\n", aux->data.nombre, aux->data.tipo, "--", strlen(aux->data.nombre));
        }
        else if(strcmp(aux->data.tipo, "CONST_REAL") == 0)
        {
            sprintf(linea, "%-35s%-30s%-30g%-d\n", aux->data.nombre, aux->data.tipo, aux->data.valor.valor_double, strlen(aux->data.nombre) -1);
        }
        else if(strcmp(aux->data.tipo, "STRING") == 0)
        {
            sprintf(linea, "%-35s%-30s%-30s%-d\n", aux->data.nombre, aux->data.tipo, "--", strlen(aux->data.nombre));
        }
        else if(strcmp(aux->data.tipo, "CONST_STR") == 0)
        {
            sprintf(linea, "%-35s%-30s%-30s%-d\n", aux->data.nombre, aux->data.tipo, aux->data.valor.valor_str, strlen(aux->data.valor.valor_str) -2);
        }
        fprintf(arch, "%s", linea);
        free(aux);
    }
    fclose(arch); 
}

/*---- Arbol ----*/
ast* newNode(char* operation, ast* leftNode, ast* rightNode) {
    ast* node = (ast*) malloc(sizeof(ast));
    node->value = operation;
    node->nodeId = contadorId;
    node->left = leftNode;
    node->right = rightNode;
    contadorId++;
    return node;
}

ast* newLeaf(char* value) {
    ast* node = (ast*) malloc(sizeof(ast));
    node->nodeId = contadorId;
    node->value = strdup(value);
    node->left = NULL;
    node->right = NULL;
    contadorId++;
    return node;
}

void print2DUtil(ast *root, int space) 
{ 
    
    // Base case 
    if (root == NULL) 
        return; 
  
    // Increase distance between levels 
    space += 10; 
  
    // Process right child first 
    print2DUtil(root->right, space); 
  
    // Print current node after space 
    fprintf( intermedia ,"\n");
    int i; 
    for (i = 10; i < space; i++) 
        fprintf( intermedia ," "); 
    fprintf( intermedia ,"%s\n", root->value); 
  
    // Process left child 
    print2DUtil(root->left, space); 
} 
  
// Wrapper over print2DUtil() 
void print2D(ast *root) 
{ 
    intermedia = fopen("intermedia.txt", "w");
    if ( intermedia == NULL) {
        printf("No se pudo crear el archivo intermedia.txt\n");
        exit(1);
    }
   // Pass initial space count as 0 
   print2DUtil(root, 0); 
   fclose( intermedia );
} 

void generarGraphviz(ast * arbol){
    FILE *pf = fopen("intermedia.gv", "w+"); 
        fprintf(pf,"digraph G {\n");    
        fprintf(pf,"\tnode [fontname = \"Arial\"];\n");
        recorrerArbolGraphviz( arbol , pf);
        fprintf(pf,"}");
        fclose(pf);
}

void recorrerArbolGraphviz(ast * arbol, FILE* pf)
{
    if(arbol==NULL)
        return;
    
    //printf( "%s\t%d\n", arbol->value , arbol->nodeId );

    if(arbol->left)
    {
          fprintf(pf," N%d -> N%d; \n",arbol->nodeId , arbol->left->nodeId);
          recorrerArbolGraphviz(arbol->left, pf);
    }

    if(arbol->right)
    {
          fprintf(pf," N%d -> N%d; \n",arbol->nodeId ,arbol->right->nodeId);
          recorrerArbolGraphviz(arbol->right, pf);
    }


    if(strchr(arbol->value,'\"'))
        fprintf(pf," N%d [label = %s]\n",arbol->nodeId ,arbol->value );
    else fprintf(pf," N%d [label = \"%s\"]\n",arbol->nodeId ,arbol->value );
}

void generarAssembler()
{
    // ast* copy = tree;
    file = fopen("Final.asm", "w");
    if (file == NULL) {
        printf("No se pudo crear el archivo final.asm \n");
        exit(1);
    }
    crearHeader(file);
    crearSeccionData(file);
    crearSeccionCode(file);
    recorrerArbol( _pProg ,file );
    crearFooter(file);
    fclose(file);
}

void crearHeader(FILE *archAssembler){
    fprintf(archAssembler, "%s\n%s\n\n", "include number.asm", "include macros2.asm");
    fprintf(archAssembler, "%-30s%-30s\n", ".MODEL LARGE", "; Modelo de memoria");
    fprintf(archAssembler, "%-30s%-30s\n", ".386", "; Tipo de procesador");
    fprintf(archAssembler, "%-30s%-30s\n\n", ".STACK 200h", "; Bytes en el stack");
}

void crearSeccionData(FILE *archAssembler){
    t_simbolo *aux;
    t_simbolo *tablaSimbolos = tablaTS.primero;

    fprintf(archAssembler, "%s\n\n", ".DATA");

    //char linea[100];
    while(tablaSimbolos){
        aux = tablaSimbolos;
        tablaSimbolos = tablaSimbolos->next;
        if(strcmp(aux->data.tipo, "INT") == 0){
            //sprintf(linea, "%-35s%-30s%-30s%-d\n", aux->data.nombre, aux->data.tipo, "--", strlen(aux->data.nombre));
            fprintf(archAssembler, "%-15s%-15s%-15s%-15s\n", aux->data.nombre, "dd", "?", "; Variable int");
        }
        else if(strcmp(aux->data.tipo, "FLOAT") == 0){
            fprintf(archAssembler, "%-15s%-15s%-15s%-15s\n", aux->data.nombreASM, "dd", "?", "; Variable float");
        }
        else if(strcmp(aux->data.tipo, "STRING") == 0){ 
            fprintf(archAssembler, "%-15s%-15s%-15s%-15s\n", aux->data.nombreASM, "db", "?", "; Variable string");
        }
        else if(strcmp(aux->data.tipo, "CONST_INT") == 0){ 
            char valor[50];
            sprintf(valor, "%d.0", aux->data.valor.valor_int);
            fprintf(archAssembler, "%-15s%-15s%-15s%-15s\n", aux->data.nombreASM, "dd", valor, "; Constante int");
        }
        else if(strcmp(aux->data.tipo, "CONST_REAL") == 0){ 
            char valor[50];
            sprintf(valor, "%g", aux->data.valor.valor_double);
            fprintf(archAssembler, "%-15s%-15s%-15s%-15s\n", aux->data.nombreASM, "dd", valor, "; Constante float");
        }
        else if(strcmp(aux->data.tipo, "CONST_STR") == 0){
            char valor[200];
            sprintf(valor, "%s, '$', %d dup (?)",aux->data.valor.valor_str, strlen(aux->data.valor.valor_str) - 2);
            fprintf(archAssembler, "%-60s%-15s%-15s%-15s\n", aux->data.nombreASM, "db", valor, "; Constante string");
        }
        //fprintf(archAssembler, "%s", linea);
        //free(aux);
    }
    fprintf(archAssembler, "%-15s%-15s%-15s%-15s\n", "@ifI", "dd", "?", "; Variable para condición izquierda");
    fprintf(archAssembler, "%-15s%-15s%-15s%-15s\n", "@ifD", "dd", "?", "; Variable para condición derecha");
}

t_simbolo * getLexema(const char *valor){
    t_simbolo *lexema;
    t_simbolo *tablaSimbolos = tablaTS.primero;

    char nombreLimpio[32];
    limpiarString(nombreLimpio, valor);
    char nombreCTE[32] = "_";
    strcat(nombreCTE, nombreLimpio);
    int esID, esCTE, esASM, esValor =-1;
    char valorFloat[32];
    while(tablaSimbolos){
        //printf("%s\n", tablaSimbolos->data.nombreASM);
        esID = strcmp(tablaSimbolos->data.nombre, nombreLimpio);
        esCTE = strcmp(tablaSimbolos->data.nombre, nombreCTE);
        esASM = strcmp(tablaSimbolos->data.nombreASM, valor);
        if(strcmp(tablaSimbolos->data.tipo, "CONST_STR") == 0)
        {
            esValor = strcmp(valor, tablaSimbolos->data.valor.valor_str);
        }
        if(esID == 0 || esCTE == 0 || esASM == 0 || esValor == 0)
        { 
            lexema = tablaSimbolos;
            return lexema;
        }
        tablaSimbolos = tablaSimbolos->next;
    }
    printf( "Hubo un error en la declaracion de datos, falto declarar %s" ,nombreLimpio );
    return NULL;
}

void crearSeccionCode(FILE *archAssembler){
    fprintf(archAssembler, "\n%s\n\n%s\n\n", ".CODE", "inicio:");
    fprintf(archAssembler, "%-30s%-30s\n", "mov AX,@DATA", "; Inicializa el segmento de datos");
    fprintf(archAssembler, "%-30s\n%-30s\n\n", "mov DS,AX", "mov ES,AX");
}

void crearFooter(FILE *archAssembler){
    fprintf(archAssembler, "\n%-30s%-30s\n", "mov AX,4C00h", "; Indica que debe finalizar la ejecución");
    fprintf(archAssembler, "%s\n\n%s", "int 21h", "END inicio");
}


void recorrerArbol( ast * root , FILE *archAssembler)
{
    bool fueAsignacion = false;
    //printf( "%s\t", root->value);

    if ( root->left != NULL ) {
        recorrerArbol(root->left, archAssembler);
    }

    if ( (strcmp(root->value,";") == 0 ) ) {
        //aca no pasa nada
    }else if ( strcmp(root->value,"WRITE") == 0 ) {
        t_simbolo *lexema = getLexema( root->right->value );
        if( strcmp(lexema->data.tipo, "CONST_STR") == 0 )
        {
            fprintf(archAssembler, "displayString %s\nNEWLINE\n", lexema->data.nombreASM);
        }
        else{
            fprintf(archAssembler, "DisplayFloat %s,1\nNEWLINE\n", lexema->data.nombreASM);
        }
    }else if ( strcmp(root->value,"READ") == 0 )
    {
        t_simbolo *lexema = getLexema( root->right->value );
        fprintf(archAssembler, "GetFloat %s\nNEWLINE\n", lexema->data.nombreASM); //directamente levanto un float porque sino rompe la division
    }else if ( strcmp(root->value,"=") == 0 )
    {
        fueAsignacion = true;
        if (strcmp(root->right->value,"=") == 0 ) 
        {
            //cuando el maximo contiene un solo elemento es mas facil poner el codigo aca que llamar a las otras funciones.
            t_simbolo *lexema = getLexema( root->right->right->value );
            fprintf(archAssembler, "fld %s\n", lexema->data.nombreASM); //cargo el lado derecho 
            lexema = getLexema( root->left->value );
            fprintf(archAssembler, "fstp %s\n", lexema->data.nombreASM ); //lo guardo en la variable del lado izquierdo
        } else if ( (strcmp(root->right->value,"/") == 0 ) || (strcmp(root->right->value,";") == 0 ) ) {
            generarAssemblerAsignacion(root->right, archAssembler );
            t_simbolo *lexema = getLexema( root->left->value );
            fprintf(archAssembler, "fstp %s\n", lexema->data.nombreASM );
        } else {
            generarAssemblerAsignacionSimple(root, archAssembler );
        }
    }



    if( (root->right != NULL) && !(fueAsignacion) ) {
        recorrerArbol(root->right, archAssembler);
    }
}
void    generarAssemblerAsignacionSimple( ast * root , FILE *archAssembler )
{
        t_simbolo *lexema = getLexema( root->right->value );
        fprintf(archAssembler, "fld %s\n", lexema->data.nombreASM); //cargo el lado derecho
        lexema = getLexema( root->left->value );
        fprintf(archAssembler, "fstp %s\n", lexema->data.nombreASM ); //lo guardo en la variable del lado izquierdo
}


void    generarAssemblerMax( ast * root , FILE *archAssembler)
    {
        
        if ( strcmp(root->value,"=") == 0 )
        {
            
            fprintf(archAssembler, "\n;Comienza el codigo de maximo\n");
            generarAssemblerAsignacionSimple( root, archAssembler);
        }else{
            
            if( root->left != NULL ) {
                generarAssemblerMax( root->left , archAssembler);
            }
            if( strcmp(root->value,"IF") == 0  )
            {
                fprintf(archAssembler, "\n;Codigo if\n");
                //printf("izq izq es %s", root->left->left->value  );
                t_simbolo *lexemaI = getLexema( root->left->left->value );
                fprintf(archAssembler, "fld %s\n", lexemaI->data.nombreASM);
                fprintf(archAssembler, "fstp @ifI\n");
                //printf("izq der es %s", root->left->right->value  );
                t_simbolo *lexemaD = getLexema( root->left->right->value );
                fprintf(archAssembler, "fld %s\n", lexemaD->data.nombreASM);
                fprintf(archAssembler, "fstp @ifD\n");
                fprintf(archAssembler, "fld @ifI\n");       //carga @ifI
                fprintf(archAssembler, "fld @ifD\n");       //carga @ifD
                fprintf(archAssembler, "fxch\n");           //intercambia las posiciones 0 y 1
                fprintf(archAssembler, "fcom \n");          //compara 
                fprintf(archAssembler, "fstsw AX\nsahf\n"); //no se si porque sentencia es necesaria
                fprintf(archAssembler, "jae branch%d\n", branchN );// si dio false, salteate lo siguiente
                generarAssemblerAsignacionSimple( root->right, archAssembler); //como se que siempre va ser una asignacion ya le llamo esto
                fprintf(archAssembler, "branch%d:\n", branchN ); //aca cae si dio false
                branchN++;                                  //sumo el numero de branch

            }else if ( root->right != NULL ) {
                generarAssemblerMax( root->right , archAssembler);
            }

        }
    }

void    generarAssemblerAsignacion( ast * root , FILE *archAssembler)
{
    
    if ( (strcmp(root->value,"/") == 0 )  ) {
            generarAssemblerMax(root->left, archAssembler );
            fprintf(archAssembler, "fld @max\n");
            fprintf(archAssembler, "fld %s\n", root->right->value);
            fprintf(archAssembler, "fdiv\n");               //divido por el factor
        } else {
            generarAssemblerMax(root, archAssembler );
            fprintf(archAssembler, "fld @max\n");           
        }
}