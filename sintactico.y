%{
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <math.h>
#include <string.h>
#include "y.tab.h"
#include "ts.h"
#include "tercetos.h"
#include "validacion.h"

FILE  *yyin,*fArbol;
char *yytext;
%}

%union{
 char s[20];
}

%token DEFVAR
%token ENDDEF

%token <s>ID
%token MAYOR MAYOR_IGUAL MENOR MENOR_IGUAL IGUAL DISTINTO   
%token ASIG SUMA RESTA MUL DIV
%token P_A P_C LL_A LL_C PA_A PA_C P_Y_C DP COMA

%token ENTERO
%token REAL
%token CADENA
%token INT
%token FLOAT
%token STRING

%token AND
%token OR

%token IF
%token ELSE
%token WHILE
%token AVG

%%
raiz
    :programa                                                                  {printf("Generando Tabla de Simbolos\n");symbolTableToHtml(symbolTable,"ts.html");}
    ;

programa
		:sentencias																{printf("COMPILACION OK\n");}
		;								
sentencias								
			:sentencias sent													{printf("GRUPO DE SENTENCIAS\n");}
			|sent																{printf("SENTENCIA INDIVIDUAL\n");}
			;								
sent								
	:asignacion																	{printf("ASIGNACION\n");}
	|decision																	{printf("DECISION\n");}
	|declaracion																{printf("DECLARACION\n");}
	|iteracion																	{printf("ITERA\n");}
	|promedio																	{printf("AVG\n");}
	;

asignacion
			:ID ASIG formato_asignacion
			;
formato_asignacion
					:expresion													{printf("ASIGNACION SIMPLE\n");}
					|ID ASIG formato_asignacion									{printf("ASIGNACION MULTIPLE\n");}
					;
decision
		:IF P_A condiciones P_C LL_A sentencias LL_C							{printf("IF\n");}
		|IF P_A condiciones P_C LL_A sentencias LL_C ELSE LL_A sentencias LL_C	{printf("IF-ELSE\n");}
		;
		
declaracion
			:DEFVAR declaraciones ENDDEF										{saveIdType();printf("BLOQUE DECLARACION\n");}
			;	
declaraciones
				:declaraciones formato_declaracion
				|formato_declaracion
				;
formato_declaracion
					:ID DP tipo_dato											{validarLongitudId(yylval.s);saveId(yylval.s);crearTerceto(yylval.s,"-1","-1");printf("DECLARACION SIMPLE\n");}	
					|ID COMA formato_declaracion								{validarLongitudId($1);saveId($1);printf("DECLARACION MULTIPLE\n");}
					;
tipo_dato
		:INT																	{saveType("int");printf("INT\n");}
		|FLOAT																	{saveType("float");printf("FLOAT\n");}
		|STRING																	{saveType("string");printf("STRING\n");}
		;			
		
iteracion
            :WHILE P_A condiciones P_C LL_A sentencias LL_C                      {printf("WHILE\n");}
			;						
condiciones									
			:condiciones operador condicion										{printf("Condiciones Multiples\n");}
			|condicion															{printf("Condicion Individual\n");}
			;									
operador									
		:AND																	{printf("&&\n");}
		|OR																		{printf("||\n");}
		;									
condicion									
		:expresion MAYOR expresion												{printf(">\n", yytext);}
		|expresion MAYOR_IGUAL expresion										{printf(">=\n", yytext);}
		|expresion MENOR expresion												{printf("<\n", yytext);}
		|expresion MENOR_IGUAL  expresion										{printf("<=\n", yytext);}
		|expresion IGUAL  expresion												{printf("==\n", yytext);}
		|expresion DISTINTO  expresion											{printf("!=\n", yytext);}
		;									

promedio
		:AVG P_A PA_A formato_promedio PA_C P_C									{printf("FUNCION PROMEDIO (AVG)\n");}
		;
formato_promedio
				:expresion
				|expresion COMA formato_promedio
				;
expresion									
		:expresion RESTA termino												{printf("RESTA\n");}
		|expresion SUMA termino													{printf("SUMA\n");}
		|termino																{printf("TERMINO\n");}
		;									

termino									
		:termino MUL factor														{printf("MULTIPLICACION\n");}
		|termino DIV factor														{printf("DIVISION\n");}
		|factor																	{printf("FACTOR\n");}
		;									

factor									
		:ID																		{validarLongitudId(yylval.s);printf("ID\n");}
		|tipo																	{printf("CTE\n");}
		|P_A expresion P_C														{printf("EXPRESION\n");}
		;									

tipo									
	:ENTERO																		{validarInt(yytext);printf("ENTERO\n");}
	|REAL																		{validarFloat(yytext);printf("FLOAT\n");}
	|CADENA																		{validarString(yytext);printf("CADENA\n");}
	;

%%

int main(int argc,char *argv[])
{
  if ((yyin = fopen(argv[1], "rt")) == NULL)
  {
	printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
  }
  else
  {
	yyparse();
  }
  fclose(yyin);
  return 0;
}
