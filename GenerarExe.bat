flex EA3.l
bison -dyv EA3.y
gcc.exe lex.yy.c y.tab.c -o EA3.exe
del lex.yy.c
del y.tab.c
del y.tab.h
del y.output
EA3.exe testing.txt
dot -T png intermedia.gv -o Intermedia.png
del intermedia.gv 