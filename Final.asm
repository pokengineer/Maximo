include number.asm
include macros2.asm

.MODEL LARGE                  ; Modelo de memoria           
.386                          ; Tipo de procesador          
.STACK 200h                   ; Bytes en el stack           

.DATA

@max           dd             ?              ; Variable int 
S_Ingrese_un_valor_entero_positivo___1                      db             "Ingrese un valor entero positivo: ", '$', 34 dup (?); Constante string
X              dd             ?              ; Variable int 
_3             dd             3.0            ; Constante int
_2             dd             2.0            ; Constante int
_9             dd             9.0            ; Constante int
_4             dd             4.0            ; Constante int
_5             dd             5.0            ; Constante int
_6             dd             6.0            ; Constante int
max            dd             ?              ; Variable int 
_1             dd             1.0            ; Constante int
_7             dd             7.0            ; Constante int
resul          dd             ?              ; Variable int 
S_El_maximo_es___2                                          db             "El maximo es: ", '$', 14 dup (?); Constante string
S_El_resultado_es___3                                       db             "El resultado es: ", '$', 17 dup (?); Constante string
@ifI           dd             ?              ; Variable para condición izquierda
@ifD           dd             ?              ; Variable para condición derecha

.CODE

inicio:

mov AX,@DATA                  ; Inicializa el segmento de datos
mov DS,AX                     
mov ES,AX                     

displayString S_Ingrese_un_valor_entero_positivo___1
NEWLINE
GetFloat X
NEWLINE

;Comienza el codigo de maximo
fld _3
fstp @max

;Codigo if
fld @max
fstp @ifI
fld _2
fstp @ifD
fld @ifI
fld @ifD
fxch
fcom 
fstsw AX
sahf
jae branch0
fld _2
fstp @max
branch0:

;Codigo if
fld @max
fstp @ifI
fld _9
fstp @ifD
fld @ifI
fld @ifD
fxch
fcom 
fstsw AX
sahf
jae branch1
fld _9
fstp @max
branch1:

;Codigo if
fld @max
fstp @ifI
fld _4
fstp @ifD
fld @ifI
fld @ifD
fxch
fcom 
fstsw AX
sahf
jae branch2
fld _4
fstp @max
branch2:

;Codigo if
fld @max
fstp @ifI
fld _5
fstp @ifD
fld @ifI
fld @ifD
fxch
fcom 
fstsw AX
sahf
jae branch3
fld _5
fstp @max
branch3:

;Codigo if
fld @max
fstp @ifI
fld _6
fstp @ifD
fld @ifI
fld @ifD
fxch
fcom 
fstsw AX
sahf
jae branch4
fld _6
fstp @max
branch4:

;Codigo if
fld @max
fstp @ifI
fld _4
fstp @ifD
fld @ifI
fld @ifD
fxch
fcom 
fstsw AX
sahf
jae branch5
fld _4
fstp @max
branch5:

;Codigo if
fld @max
fstp @ifI
fld _4
fstp @ifD
fld @ifI
fld @ifD
fxch
fcom 
fstsw AX
sahf
jae branch6
fld _4
fstp @max
branch6:
fld @max
fstp max

;Comienza el codigo de maximo
fld _3
fstp @max

;Codigo if
fld @max
fstp @ifI
fld _1
fstp @ifD
fld @ifI
fld @ifD
fxch
fcom 
fstsw AX
sahf
jae branch7
fld _1
fstp @max
branch7:

;Codigo if
fld @max
fstp @ifI
fld _2
fstp @ifD
fld @ifI
fld @ifD
fxch
fcom 
fstsw AX
sahf
jae branch8
fld _2
fstp @max
branch8:

;Codigo if
fld @max
fstp @ifI
fld _2
fstp @ifD
fld @ifI
fld @ifD
fxch
fcom 
fstsw AX
sahf
jae branch9
fld _2
fstp @max
branch9:

;Codigo if
fld @max
fstp @ifI
fld _2
fstp @ifD
fld @ifI
fld @ifD
fxch
fcom 
fstsw AX
sahf
jae branch10
fld _2
fstp @max
branch10:

;Codigo if
fld @max
fstp @ifI
fld _4
fstp @ifD
fld @ifI
fld @ifD
fxch
fcom 
fstsw AX
sahf
jae branch11
fld _4
fstp @max
branch11:

;Codigo if
fld @max
fstp @ifI
fld _7
fstp @ifD
fld @ifI
fld @ifD
fxch
fcom 
fstsw AX
sahf
jae branch12
fld _7
fstp @max
branch12:

;Codigo if
fld @max
fstp @ifI
fld _9
fstp @ifD
fld @ifI
fld @ifD
fxch
fcom 
fstsw AX
sahf
jae branch13
fld _9
fstp @max
branch13:
fld @max
fld X
fdiv
fstp resul
displayString S_El_maximo_es___2
NEWLINE
DisplayFloat max,1
NEWLINE
displayString S_El_resultado_es___3
NEWLINE
DisplayFloat resul,1
NEWLINE

mov AX,4C00h                  ; Indica que debe finalizar la ejecución
int 21h

END inicio