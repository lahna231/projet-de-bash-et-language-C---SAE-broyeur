#!/bin/bash
# Déclaration du nom du répertoire de travail attendu
working_directory=sae_broyeur

# Vérification que l'utilisateur se trouve dans le répertoire attendu
if ! pwd | grep $working_directory > /dev/null 2>&1 ; then
  # Si le répertoire actuel ne contient pas le nom "sae_broyeur", afficher un message d'erreur
  echo "Vous n'êtes pas dans le dossier $working_directory !!";
  # Sortie du script avec un code d'erreur (1)
  exit 1
fi

# Vérification si le dossier .sh-trashbox existe
if [ -d .sh-trashbox ]
then
  # Si le dossier existe, afficher un message confirmant son existence
  echo "le dossier exist deja "
else 
  # créer le dossier .sh-trashbox
  mkdir .sh-trashbox
  echo "le dossier est bien crée"
fi

# Initialisation du fichier ID dans le dossier .sh-trashbox
echo "1" > .sh-trashbox/ID

# Création d'un fichier INDEX vide dans le dossier .sh-trashbox
touch .sh-trashbox/INDEX

echo " la corbeille a été bien nitialisée"