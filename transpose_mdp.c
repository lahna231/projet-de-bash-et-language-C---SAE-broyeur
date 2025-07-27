#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define BUFFER 2000 // Définition d'une constante pour les noms de fichiers

int main(int argc, char *argv[]) {
    if (argc != 3) {
        perror("Veuillez fournir un fichier source et un mot de passe !");
        return 0;
    }

    char *fichier = argv[1]; //le nom du fichier source
    const char *mdp = argv[2]; // le mdp fourni par l'utilisateur
    int taille = strlen(mdp);  // Longueur du mot de passe

    // Allocation d'un tableau pour copier le mot de passe 
    char *tableau = malloc(taille * sizeof(char));
    if (!tableau) {
        perror("OUT OF MEMORY");
        return 0;
    }
    strcpy(tableau, mdp);  // Copie du mot de passe dans le tableau

    // Création d'un tableau d'indices correspondant à la longueur du mot de passe
    int tableau2[taille];
    for (int i = 0; i < taille; i++) tableau2[i] = i;
    // Tri des indices
    for (int i = 0; i < taille - 1; i++) {
        for (int j = i + 1; j < taille; j++) {
            if (tableau[tableau2[i]] > tableau[tableau2[j]]) {
                int temp = tableau2[i];
                tableau2[i] = tableau2[j];
                tableau2[j] = temp;
            }
        }
    }
    // Ouverture du fichier source en mode binaire pour lecture
    FILE *initial = fopen(fichier, "rb");
    if (!initial) {
        perror("Erreur : le fichier source n'existe pas !");
        free(tableau);
        return 0;
    }

    // Compter le nombre de caractères dans le fichier
    int nb_caracteres = 0;
    char c;
    while ((c = fgetc(initial)) != EOF) nb_caracteres++;

    // Calcul du nombre de lignes
    int nb_lignes = (nb_caracteres + taille - 1) / taille; // La matrice aura nb_lignes lignes et k colonnes
    
    // Allocation de la matrice
    char **matrice = malloc(nb_lignes * sizeof(char *));
    for (int i = 0; i < nb_lignes; i++) {
        matrice[i] = malloc(taille * sizeof(char));
        memset(matrice[i], '\0', taille); // Remplissage par '\0' au lieu d'espaces
    }

    // Remettre le fichier au début
    rewind(initial);

    // Remplir la matrice avec les caractères du fichier
    for (int i = 0; (c = fgetc(initial)) != EOF; i++) {
        matrice[i / taille][i % taille] = c;
    }
    fclose(initial);

   // Allocation d'un tableau de fichiers pour créer les fichiers
    FILE **file = malloc(taille * sizeof(FILE *));
    for (int i = 0; i < taille; i++) {
        // créer et ouvrir k fichiers de sortie
        char filename[BUFFER]; // Buffer pour stocker les noms des fichiers
        snprintf(filename, BUFFER, "%s_%d", fichier, i); // creation des fichiers 
        file[i] = fopen(filename, "wb"); // Ouvrir chaque fichier en mode écriture binaire
        if (!file[i]) {
            perror("Erreur de création de fichier !");
            for (int j = 0; j < i; j++) fclose(file[j]);
            free(file);
            for (int j = 0; j < nb_lignes; j++) free(matrice[j]);
            free(matrice);
            free(tableau);
            return 0;
        }
    }

    // Remplir les fichiers
   for (int j = 0; j < taille; j++) {
        for (int i = 0; i < nb_lignes; i++) {
            if (matrice[i][tableau2[j]] != '\0') { // Évite d'écrire les '\0'
                fputc(matrice[i][tableau2[j]], file[j]);
            }
        } 
    }
    printf("Fichiers créés avec succès !\n");

    // Fermeture des fichiers ouverts et libération de la mémoire
    for (int i = 0; i < taille; i++) fclose(file[i]);
    free(file);

    for (int i = 0; i < nb_lignes; i++) free(matrice[i]);
    free(matrice);
    free(tableau);

    // Supprime le fichier source
    remove(argv[1]);

    return 0;
}