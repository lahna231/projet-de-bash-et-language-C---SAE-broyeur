#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define BUFFER 2000  // Taille maximale pour les noms de fichiers

int main(int argc, char *argv[]) {
    if (argc < 3) {
        perror("Veuillez fournir un fichier source et un mot de passe !");
        return 0;
    }

    char *fichier = argv[1];  //Nom de base du fichier source
    const char *mdp = argv[2];  // Mot de passe 
    int taille = strlen(mdp); // Taille du mot de passe

    // Allocation pour la gestion des fichiers transposés
    FILE **file2 = malloc(taille * sizeof(FILE *));
    if (!file2) {
        perror("Erreur d'allocation de mémoire pour les fichiers de détransposition !");
        return 0;
    }

    // Variable pour accumuler le nombre total de caractères
    long nb_caracteres = 0; 

    // Ouvrir les fichiers transposés et calculer la taille de chaque fichier
    for (int i = 0; i < taille; i++) {
        char filename[BUFFER];
        snprintf(filename, BUFFER, "%s_%d", fichier, i); 
        file2[i] = fopen(filename, "rb");  // Ouvrir les fichiers en mode lecture binaire
        if (!file2[i]) {
            perror("Erreur d'ouverture des fichiers transposés !");
            free(file2);  // Libérer la mémoire allouée 
            return 0;
        }

        // Lire caractère par caractère jusqu'à la fin du fichier et compter les caractères
        int c;
        while ((c = fgetc(file2[i])) != EOF) {
            nb_caracteres++;  // Incrémenter le compteur pour chaque caractère lu
        }
        
        fclose(file2[i]);  // Fermer le fichier après lecture
    }


    // Calculer le nombre de lignes dans la matrice
    int nb_lignes = (nb_caracteres + taille - 1) / taille;

    // Allocation et initialisation de la matrice pour stocker les données détransposées
    char **matrice2 = malloc(nb_lignes * sizeof(char *));
    if (!matrice2) {
        perror("Erreur d'allocation de mémoire pour la matrice détransposée !");
        free(file2);
        return 0;
    }

    for (int i = 0; i < nb_lignes; i++) {
        matrice2[i] = malloc(taille * sizeof(char));
        memset(matrice2[i], '\0', taille);  // Initialisation avec '\0'
    }

    // Création d'un tableau pour gérer l'ordre des colonnes basé sur le mot de passe    
    int tableau2[taille];
    for (int i = 0; i < taille; i++) tableau2[i] = i;
    for (int i = 0; i < taille - 1; i++) {
        for (int j = i + 1; j < taille; j++) {
             // Tri des indices selon les caractères du mot de passe
            if (mdp[tableau2[i]] > mdp[tableau2[j]]) {
                int temp = tableau2[i];
                tableau2[i] = tableau2[j];
                tableau2[j] = temp;
            }
        }
    }

    // Réouvrir les fichiers pour la détransposition
    for (int i = 0; i < taille; i++) {
        char filename[BUFFER];
        snprintf(filename, BUFFER, "%s_%d", fichier, i);  // Nom des fichiers transposés

        file2[i] = fopen(filename, "rb");
        if (!file2[i]) {
            perror("Erreur d'ouverture des fichiers transposés pour détransposition !");
            free(file2);
            return 0;
        }
    }

    // Remplir la matrice avec les caractères des fichiers transposés
    for (int j = 0; j < taille; j++) {
        for (int i = 0; i < nb_lignes; i++) {
            char c = fgetc(file2[j]);
            if (c != EOF) {
                matrice2[i][tableau2[j]] = c; // Stocker le caractère dans la matrice à la bonne position
            }
        }
    }

    // recréer le fichier d'origine pour y écrire les données détransposées
    FILE *initial2 = fopen(fichier, "wb");
    if (initial2 == NULL) {
        perror("Erreur d'ouverture du fichier pour écriture !");
        free(file2);
        free(matrice2);
        return 1;
    }

    // Réécrire le fichier à partir de la matrice détransposée
    for (int i = 0; i < nb_lignes; i++) {
        for (int j = 0; j < taille; j++) {
            if (matrice2[i][j] != '\0') { // Ignorer les caractères nuls '\0'
                fputc(matrice2[i][j], initial2);  // Écrire chaque caractère dans le fichier
            }
        }
    }

    // Fermeture des fichiers
    fclose(initial2);
    for (int i = 0; i < taille; i++) fclose(file2[i]);
    free(file2);

    // Libérer la mémoire de la matrice
    for (int i = 0; i < nb_lignes; i++) free(matrice2[i]);
    free(matrice2);

    // Suppression des fichiers transposés 
    for (int i = 0; i < taille; i++) {
        char filename[BUFFER];
        snprintf(filename, BUFFER, "%s_%d", fichier, i);  // Génération du nom du fichier
        remove(filename);  // Supprimer le fichier 
    }

    printf("Détransposition terminée avec succès, fichier source recréé et fichiers transposés supprimés.\n");

    return 0;
}