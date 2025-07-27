#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define BUFFER 2000 // Définition d'une constante pour les noms de fichiers


int main(int argc, char *argv[]) {
    if (argc != 3) {
        perror("Veuillez saisir un fichier et une valeur entière positive");
        return 0;
    }

    char *fichier = argv[1]; //le nom du fichier source
    int k = atoi(argv[2]); // Conversion du second argument en entier

    if (k <= 0) {
        perror("Erreur : la valeur doit etre positive ! ");
        return 0;
    }
    // Ouverture du fichier source en mode binaire pour lecture
    FILE *initial = fopen(fichier, "rb");
    if (!initial) {
        perror("Erreur : le fichier source n'existe pas ");
        return 0;
    }

    // Comptage du nombre de caractères dans le fichier
    int nb_caracteres = 0;
    char c;
    while ((c = fgetc(initial)) != EOF) { // Lecture des caractères un par un
        nb_caracteres++;
    }
    rewind(initial); // Revenir au début du fichier

    // Calcul du nombre de lignes de la matrice
    int nb_lignes = (nb_caracteres + k - 1) / k; // La matrice aura nb_lignes lignes et k colonnes

    // Allocation de la matrice 
    char **matrice = malloc(nb_lignes * sizeof(char *));
    for (int i = 0; i < nb_lignes; i++) {
        matrice[i] = malloc(k * sizeof(char));
        // Initialiser la matrice avec des caractères nuls
        memset(matrice[i], '\0', k * sizeof(char));  // Initialiser chaque case avec '\0' 
    }

    // Remplir la matrice avec les caractères du fichier
    int i = 0, j = 0;
    while ((c = fgetc(initial)) != EOF) {
        matrice[i][j] = c;
        j++;
        if (j == k) { // Lorsque nous avons rempli une ligne, passer à la suivante
            j = 0;
            i++;
        }
    }
    fclose(initial);

    // allouer Un tableau de pointeurs de fichiers pour stocker des pointeurs vers les fichiers de sortie
    FILE **fich = malloc(k * sizeof(FILE *));
    if (!fich) {
        perror("Erreur d'allocation mémoire pour les fichiers");
        return 0;
    }
   // créer et ouvrir k fichiers de sortie
    char filename[BUFFER]; // Buffer pour stocker les noms des fichiers
    for (int i = 0; i < k; i++) {
        snprintf(filename, BUFFER, "%s_%d", fichier, i);
        fich[i] = fopen(filename, "wb");  // Ouvrir le fichier en mode écriture binaire
        if (!fich[i]) {
            perror("Erreur de création de fichier !");
            for (int j = 0; j < i; j++) {
                fclose(fich[j]);
            }
            free(fich);
            for (int l = 0; l < nb_lignes; l++) {
                free(matrice[l]);
            }
            free(matrice);
            return 0;
        }
    }

    // Transposer la matrice et écrire dans les fichiers
    for (int j = 0; j < k; j++) {
        for (int i = 0; i < nb_lignes; i++) {
            if (matrice[i][j] != '\0') { // Évite d'écrire les caractères nuls
                fputc(matrice[i][j], fich[j]); // Écrire la colonne transposée dans le fichier correspondant
            }
        }
    }

    // Fermeture des fichiers et libération de la mémoire
    for (int i = 0; i < k; i++) {
        fclose(fich[i]);
    }
    free(fich);

    for (int i = 0; i < nb_lignes; i++) {
        free(matrice[i]);
    }
    free(matrice);

    printf("Fichiers créés avec succès !\n");
    
    // Supprime le fichier source
    remove(argv[1]);

    return 0;
}
