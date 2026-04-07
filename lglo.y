%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "lglo.tab.h"

int  yylex(void);
int  yyerror(char *msg);

int   nb_ligne     = 0;
int   Col          = 0;
char *file_name    = NULL;
FILE *yyin;
char *type_tracker;
char *source_tracker;

%}

%union {
    int   entier;
    char *chaine;
    float reel;
}

/* ── Mots-clés (pas de valeur sémantique) ── */
%token mc_prog mc_end mc_func mc_endf
%token mc_in mc_out
%token mc_if mc_then mc_else mc_endif
%token mc_dowhile mc_enddo
%token mc_equivalence mc_dimension mc_call
%token mc_accolade_ouvrante mc_accolade_fermante

/* ── Opérateurs arithmétiques ── */
%token <chaine> mc_plus mc_moins mc_mul mc_div

/* ── Séparateurs et identifiants ── */
%token <chaine> Idf aff pvg vrg parouv parfer point

/* ── Types et littéraux ── */
%token <chaine> INTEGER REAL LOGICAL CHARACTER chaine

/* ── Constantes numériques / booléennes ── */
%token <entier> entier entier_signe True False
%token <reel>   reel   reel_signe

/* ── Opérateurs de comparaison et logiques ── */
%token OR AND GT GE EQ NE LE LT

%token erreur

/* ── Précédences : du moins prioritaire au plus prioritaire ── */
%left OR AND
%left GT GE EQ NE LE LT
%left mc_plus mc_moins
%left mc_mul mc_div

%%


S : Fonctions
    {
        printf("\n\033[1;32m---------------------------------------------------\n");
        printf("compilation lexicale et syntaxique reussie\n");
        printf("---------------------------------------------------\033[0m\n");
    }


Fonctions : T1 Fonctions
    | T2 Fonctions
    | T3 Fonctions
    | T4 Fonctions
    | Programme_Principale

T1 : type1 parouv multipleVariables parfer mc_accolade_ouvrante DeclarationFonction mc_accolade_fermante mc_endf
T2 : type2 parouv multipleVariables parfer mc_accolade_ouvrante DeclarationFonction mc_accolade_fermante mc_endf
T3 : type3 parouv multipleVariables parfer mc_accolade_ouvrante DeclarationFonction mc_accolade_fermante mc_endf
T4 : type4 parouv multipleVariables parfer mc_accolade_ouvrante DeclarationFonction mc_accolade_fermante mc_endf

type1 : REAL      mc_func Idf { source_tracker = strdup($3); printf("Fonction REAL %s\n",      $3); }
type2 : CHARACTER mc_func Idf { source_tracker = strdup($3); printf("Fonction CHARACTER %s\n", $3); }
type3 : INTEGER   mc_func Idf { source_tracker = strdup($3); printf("Fonction INTEGER %s\n",   $3); }
type4 : LOGICAL   mc_func Idf { source_tracker = strdup($3); printf("Fonction LOGICAL %s\n",   $3); }

multipleVariables : Idf vrg multipleVariables
    | Idf
    | 

TYPE : REAL      { type_tracker = strdup($1); }
    | LOGICAL    { type_tracker = strdup($1); }
    | INTEGER    { type_tracker = strdup($1); }
    | CHARACTER  { type_tracker = strdup($1); }


Data : entier
    | entier_signe
    | reel
    | reel_signe
    | True
    | False
    | chaine
    | Idf



Expr : Expr mc_plus  Expr
    | Expr mc_moins  Expr
    | Expr mc_mul    Expr
    | Expr mc_div    Expr
    | Expr GT  Expr
    | Expr GE  Expr
    | Expr EQ  Expr
    | Expr NE  Expr
    | Expr LT  Expr
    | Expr LE  Expr
    | Expr OR  Expr
    | Expr AND Expr
    | parouv Expr parfer
    | Data


InstructionAffectation : Idf aff Expr
    { printf("Affectation : %s\n", $1); }

InstructionEntreSortie : mc_in  parouv Idf     parfer pvg
    { printf("Lecture : %s\n", $3); }
    | mc_out parouv Something parfer pvg
    { printf("Ecriture\n"); }

Something : Idf    vrg Something
    | chaine vrg Something
    | Idf
    | chaine

InstructionEquivalence : mc_equivalence Idf aff Data pvg
    { printf("Constante : %s\n", $2); }

InstructionAppel : mc_call Idf parouv Arguments parfer pvg
    { printf("Appel : %s\n", $2); }

Arguments : Data vrg Arguments
    | Data
    |


InstructionIfEls : U mc_endif pvg

U : V mc_else mc_accolade_ouvrante Instruction mc_accolade_fermante
    | V

V : W mc_accolade_ouvrante Instruction mc_accolade_fermante

W : mc_if parouv Expr parfer mc_then


InstructionDoWhile : Z mc_enddo pvg

Z : Y mc_accolade_ouvrante Instruction mc_accolade_fermante

Y : mc_dowhile parouv Expr parfer


List_Idf : Idf vrg List_Idf
    | InstructionAffectation vrg List_Idf
    | Idf
    | InstructionAffectation

List_tab : Idf mc_dimension parouv entier       parfer vrg List_tab
    | Idf mc_dimension parouv entier_signe parfer vrg List_tab
    | Idf mc_dimension parouv entier       parfer
    | Idf mc_dimension parouv entier_signe parfer


DeclarationFonction : TYPE List_Idf pvg DeclarationFonction
    | TYPE List_tab pvg DeclarationFonction
    | InstructionFonction

Declaration : TYPE List_Idf pvg Declaration
    | TYPE List_tab pvg Declaration
    | Instruction


InstructionFonction : InstructionEntreSortie     InstructionFonction
    | InstructionDoWhile     InstructionFonction
    | InstructionIfEls       InstructionFonction
    | InstructionEquivalence InstructionFonction
    | InstructionAppel       InstructionFonction
    | InstructionAffectation pvg InstructionFonction
    | InstructionAffectation pvg

Instruction : InstructionEntreSortie     Instruction
    | InstructionDoWhile     Instruction
    | InstructionIfEls       Instruction
    | InstructionEquivalence Instruction
    | InstructionAppel       Instruction
    | InstructionAffectation pvg Instruction
    | 


Programme_Principale : PGM Declaration mc_end

PGM : mc_prog Idf
    { source_tracker = strdup($2); printf("Programme : %s\n", $2); }

%%


int yyerror(char *msg) {
    printf("\033[1;31mErreur syntaxique a la ligne %d colonne %d fichier %s\033[0m\n",
           nb_ligne, Col, file_name);
    return 1;
}


int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf("Usage: %s <fichier_source>\n", argv[0]);
        return 1;
    }
    file_name = argv[1];
    yyin = fopen(file_name, "r");
    if (yyin == NULL) {
        printf("Erreur : impossible d'ouvrir '%s'\n", file_name);
        return 1;
    }
    yyparse();
    fclose(yyin);
    return 0;
}
