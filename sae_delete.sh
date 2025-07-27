#!/bin/bash
# Vérifie si le script est exécuté dans le répertoire de travail spécifique
working_directory=sae_broyeur
if ! pwd | grep $working_directory > /dev/null 2>&1 ; then
  echo "Vous n'êtes pas dans le dossier $working_directory !!";
  exit 1
fi

if [ $# -ne 2 ]; then
    echo "Vous devez saisir un nom d'un fichier ou un dossier existant ou son chemin, et une clef."
    exit 1
fi

if [ ! -e "$1" ]; then
    echo "Le fichier ou le dossier passé n'existe pas."      
    exit 1
fi
# Récupération des informations sur le fichier ou dossier
document=$(realpath "$1")  # Obtenir le chemin absolu du fichier/dossier
FILENAME=$(basename "$document")  # Extraire le nom du fichier/dossier
DIRNAME=$(dirname "$document")   # Extraire le répertoire contenant le fichier
N=$(head -n 1 < .sh-trashbox/ID)
corbeille=".sh-trashbox"
key=$2
# Vérifie si l'entrée est un fichier
if [ -f "$document" ]; then
    # Traitement pour un fichier
    # Compilation et exécution du programme de transposition
    gcc transpose_mdp.c -o transpose_mdp
    ./transpose_mdp "$1" "$key"
    # Déplacer les fichiers transposés vers la corbeille
    for i in "$1"_*; do
        mv "$i" "$corbeille/$N-$(basename "$i")"
    done
    # Enregistrement dans INDEX
    TIME=$(date +%Y%m%d%H%M%S)
    echo "$N:$DIRNAME/:$FILENAME:$TIME" >> .sh-trashbox/INDEX
    # Mise à jour de l'ID
    N=$((N + 1))
    echo $N > .sh-trashbox/ID

    echo "Le fichier $FILENAME a été bien supprimé en transposition."
else
# --- Traitement pour un dossier ---
    # Créer une structure vide du dossier dans la corbeille
    mkdir -p "$corbeille/$N-$FILENAME"
    # Parcourir les fichiers et sous-dossiers du dossier à supprimer
    for i in "$document"/*; do
        if [ -f "$i" ]; then
             # Si c'est un fichier, transposer et déplacer chaque fichier
            gcc transpose_mdp.c -o transpose_mdp
            ./transpose_mdp "$i" "$key"
            # Déplacer les fichiers transposés dans la structure du dossier corbeille
            for p in "$i"_*; do
                mv "$p" "$corbeille/$N-$FILENAME/$(basename "$p")"
            done
        elif [ -d "$i" ]; then
            # Si c'est un sous-dossier, appeler récursivement ce script
            ./sae_delete.sh "$i" "$key"
        fi
    done

    # Enregistrement pour le dossier parent dans INDEX
    TIME=$(date +%Y%m%d%H%M%S)
    echo "$N:$DIRNAME/:$FILENAME:$TIME" >> .sh-trashbox/INDEX

    # Mise à jour de l'ID
    N=$((N + 1))
    echo $N > .sh-trashbox/ID

    echo "Le dossier $FILENAME et son contenu ont été bien supprimés en transposition."
    # Supprimer le dossier original une fois vidé
    rmdir "$FILENAME"
fi
