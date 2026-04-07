%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "lglo.tab.h"


extern int   nb_ligne;
extern int   Col;
extern char *file_name;
%}

%option noyywrap
%option yylineno

lettre       [a-zA-Z]
chiffre      [0-9]
IDF          {lettre}({lettre}|{chiffre}|_{lettre}|_{chiffre})*
entier       {chiffre}+
reel         {chiffre}+\.{chiffre}+
entier_signe [+-]{chiffre}+
reel_signe   [+-]{chiffre}+\.{chiffre}+
chaine       \"[^"]*\"
commentaire  %[^\n]*\n

%%

"PROGRAM"     { printf("Mot cle PROGRAM\n");     Col += yyleng;  return mc_prog; }
"END"         { printf("Mot cle END\n");          Col += yyleng;  return mc_end;  }
"FUNC"        { printf("Mot cle FUNC\n");         Col += yyleng; return mc_func; }
"ENDF"        { printf("Mot cle ENDF\n");         Col += yyleng;  return mc_endf; }

"IN"          { printf("Mot cle IN\n");            Col += yyleng; return mc_in;  }
"OUT"         { printf("Mot cle OUT\n");           Col += yyleng; return mc_out; }

"IF"          { printf("Mot cle IF\n");            Col += yyleng; return mc_if;    }
"THEN"        { printf("Mot cle THEN\n");          Col += yyleng; return mc_then;  }
"ELSE"        { printf("Mot cle ELSE\n");          Col += yyleng;  return mc_else;  }
"ENDIF"       { printf("Mot cle ENDIF\n");         Col += yyleng;  return mc_endif; }

"DOWHILE"     { printf("Mot cle DOWHILE\n");       Col += yyleng; return mc_dowhile; }
"ENDDO"       { printf("Mot cle ENDDO\n");         Col += yyleng; return mc_enddo;   }

"EQUIVALENCE" { printf("Mot cle EQUIVALENCE\n");   Col += yyleng;  return mc_equivalence; }
"DIMENSION"   { printf("Mot cle DIMENSION\n");     Col += yyleng;  return mc_dimension;  }
"CALL"        { printf("Mot cle CALL\n");           Col += yyleng;  return mc_call;       }

"INTEGER"   { printf("type: INTEGER\n");   Col += yyleng; yylval.chaine = strdup(yytext);  return INTEGER;   }
"REAL"      { printf("type: REAL\n");      Col += yyleng; yylval.chaine = strdup(yytext); return REAL;      }
"LOGICAL"   { printf("type: LOGICAL\n");   Col += yyleng; yylval.chaine = strdup(yytext); return LOGICAL;   }
"CHARACTER" { printf("type: CHARACTER\n"); Col += yyleng; yylval.chaine = strdup(yytext); return CHARACTER; }

"OR"  { printf("operateur OR\n");  Col += yyleng;  return OR;  }
"AND" { printf("operateur AND\n"); Col += yyleng;  return AND; }
"GT"  { printf("operateur GT\n");  Col += yyleng;  return GT;  }
"GE"  { printf("operateur GE\n");  Col += yyleng;  return GE;  }
"EQ"  { printf("operateur EQ\n");  Col += yyleng;  return EQ;  }
"NE"  { printf("operateur NE\n");  Col += yyleng;  return NE;  }
"LE"  { printf("operateur LE\n");  Col += yyleng;  return LE;  }
"LT"  { printf("operateur LT\n");  Col += yyleng;  return LT;  }

"+" { printf("operateur +\n"); Col += yyleng; yylval.chaine = strdup(yytext);  return mc_plus;  }
"-" { printf("operateur -\n"); Col += yyleng; yylval.chaine = strdup(yytext);  return mc_moins; }
"*" { printf("operateur *\n"); Col += yyleng; yylval.chaine = strdup(yytext);  return mc_mul;   }
"/" { printf("operateur /\n"); Col += yyleng; yylval.chaine = strdup(yytext);  return mc_div;   }

"TRUE"  { 
    printf("booleen TRUE\n");  
    Col += yyleng; 
    yylval.entier = 1; 
    return True;  
}

"FALSE" { 
    printf("booleen FALSE\n"); 
    Col += yyleng; 
    yylval.entier = 0; 
    return False; 
}

{IDF} {
    yylval.chaine = strdup(yytext);
    if (yyleng > 10) {
        printf("warning : identifiant '%s' depasse 10 caracteres\n", yytext);
        return erreur;
    }
    printf("IDF %s\n", yytext);
    Col += yyleng;
    return Idf;
}

{reel_signe} {
    double val = atof(yytext);
    printf("reel signe %s\n", yytext);
    if (val < -32768.0 || val > 32767.0) {
        printf("constante hors intervalle : %s\n", yytext);
        return erreur;
    }
    yylval.reel = (float)val;
    Col += yyleng;
    return reel_signe;
}

{reel} {
    double val = atof(yytext);
    printf("reel %s\n", yytext);
    if (val > 32767.0) {
        printf("constante hors intervalle : %s\n", yytext);
        return erreur;
    }
    yylval.reel = (float)val;
    Col += yyleng;
    return reel;
}

{entier_signe} {
    int val = atoi(yytext);
    printf("entier signe %s\n", yytext);
    if (val < -32768 || val > 32767) {
        printf("constante hors intervalle : %s\n", yytext);
        return erreur;
    }
    yylval.entier = val;
    Col += yyleng;
    return entier_signe;
}

{entier} {
    int val = atoi(yytext);
    printf("entier %s\n", yytext);
    if (val > 32767) {
        printf("constante hors intervalle : %s\n", yytext);
        return erreur;
    }
    yylval.entier = val;
    Col += yyleng;
    return entier;
}

{chaine} {
    printf("chaine %s\n", yytext);
    yylval.chaine = strdup(yytext);
    Col += yyleng;
    return chaine;
}

{commentaire} {
    printf("commentaire : %s", yytext);
    nb_ligne++;
    Col = 1;
}

"=" { 
    printf("affectation\n");         
    Col += yyleng; yylval.chaine = strdup(yytext); 
    return aff;    
}

";" { 
    printf("point-virgule\n");       
    Col += yyleng; yylval.chaine = strdup(yytext); 
    return pvg;    
}

"," { 
    printf("virgule\n");             
    Col += yyleng; 
    yylval.chaine = strdup(yytext); 
    return vrg;    
}

"(" { 
    printf("parenthese ouvrante\n"); 
    Col += yyleng; 
    yylval.chaine = strdup(yytext); 
    return parouv; 
}


")" { 
    printf("parenthese fermante\n"); 
    Col += yyleng; yylval.chaine = strdup(yytext); 
    return parfer; 
}

"." { 
    printf("point\n");               
    Col += yyleng; 
    yylval.chaine = strdup(yytext); 
    return point;  
}

"{" { 
    
    printf("accolade ouvrante\n"); 
    Col += yyleng; 
    return mc_accolade_ouvrante; 
}

"}" { 
    printf("accolade fermante\n"); 
    Col += yyleng; 
    return mc_accolade_fermante; 
}

[ \t]  { 
    Col += yyleng; 
}

\n     { 
    nb_ligne++; 
    Col = 1; 
}

. {
    printf("\033[1;31mErreur lexicale ligne %d col %d fichier %s : caractere '%s' non reconnu\033[0m\n",
           nb_ligne, Col, file_name, yytext);
    return erreur;
}

%%
