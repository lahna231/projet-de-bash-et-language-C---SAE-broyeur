#!/bin/bash
# Vérifie si le script est exécuté dans le bon répertoire
working_directory=sae_broyeur
if ! pwd | grep $working_directory > /dev/null 2>&1 ; then
  echo "Vous n'êtes pas dans le dossier $working_directory !!";
  exit 1
fi

if [ $# -lt 1 ]
then
  echo "vous devez passer au moins un parametre "
  exit 1
fi
INDEX=".sh-trashbox/INDEX"
# Cas où l'option -d est utilisée pour restaurer un fichier vers un répertoire spécifique
if [ "$1" = "-d" ]; then
   OUTPUT=$2
   document=$3
   CHEMIN=$(pwd)# Obtient le répertoire courant où les documents seront detransposee
   # Recherche le numéro associé au document
   numero=$(grep "$document" "$INDEX" | sort -t ':' -k3 -r | head -n 1 | cut -d ':' -f1)
   num=".sh-trashbox/$numero"
   dossier=".sh-trashbox/$numero-$document"  
   key=$4   # Obtient La clé de transposition fournie par l'utilisateur

   if [ -d "$dossier" ]; then
   	    #CAS DES DOSSIERS 
# creation d'un fichier temporaire pour stocker les noms des fichier a detransposer
      ls "$dossier" | cut -d '_' -f1 | uniq > tmp
      # deplacer les fichiers tels qu'ils sont vers le chemin courant pour les detransposer
      for i in $(ls $dossier) 
      do
         mv "$dossier/$i" "$CHEMIN"
      done
      #faire la detransposition
      while read a
      do
          gcc detransposition.c -o detransposition
         ./detransposition "$a" "$key"
      done < tmp
      
      # Supprimer le dossier de la corbeille une fois vidé
      rmdir "$dossier"
      #creer le dossier $document   dans $OUTPUT
      mkdir -p "$OUTPUT/$document"
      # deplacer les fichiers detransposés vers leur dossier
      while read -r a; do
         mv "$a" "$OUTPUT/$document/$a"
      done < tmp
      # Supprime la ligne correspondante au numéro de fichier dans l'index
      sed -i "\|^$numero:|d" "$INDEX"

      #supprimer le fichier temporaire crée
      rm tmp
      # quitter le programme si l'exécution s'est terminée avec succès,      
      exit 0
   fi
   #CAS DES FICHIERS 
   # Déplace les fichiers associés au document depuis la corbeille vers le répertoire courant
   	  for i in $num-$document_*
      do
         mv $i $CHEMIN
      done 
      for i in $numero-*; do
         if [ -e "$i" ]; then
            # Supprimer le préfixe numérique du fichier
            new_name=$(echo "$i" | sed 's/^[0-9]*-//')  # Retirer le numéro initial
            mv "$i" "$new_name"
         fi
      done
      # Compile et exécute le programme pour la détransposition      
      gcc detransposition.c -o detransposition
      ./detransposition "$document" "$key"
      # Compile et exécute le programme pour la détransposition    
      mv "$document" "$OUTPUT/$document"
      echo "Document $document déplacé dans $OUTPUT."
      
fi
# Cas où l'option -r est utilisée pour restaurer un fichier vers son répertoire d'origine
if [ $1 = '-r' ]
then
      document=$2
      # Recherche le chemin d'origine du fichier et le numéro associé
      CHEMIN=$(grep "$document" "$INDEX" | sort -t ':' -k3 -r | head -n 1 | cut -d ':' -f2)
      numero=$(grep "$document" "$INDEX" | sort -t ':' -k3 -r | head -n 1 | cut -d ':' -f1)
      key=$3
      dossier=".sh-trashbox/$numero-$document"  
      num=".sh-trashbox/$numero"

     if [ -d "$dossier" ]; then
         #CAS DES DOSSIERS 
# creation d'un fichier temporaire pour stocker les noms des fichier a detransposer

   	   	ls "$dossier" | cut -d '_' -f1 | uniq > tmp
   	   	# deplacer les fichiers tels qu'ils sont vers le chemin courant pour les detransposer
   	   	for i in $(ls $dossier) 
   	   	do
   	   		mv "$dossier/$i" "$CHEMIN"
   	   	done
   	   	 #faire la detransposition

   	   	while read a
   	   	do
   	   		gcc detransposition.c -o detransposition
   	   		./detransposition "$a" "$key"
   	   	done < tmp
      
   	   	# Supprimer le dossier de la corbeille une fois vidé
   	   	rmdir "$dossier"
   	   	#creer le dossier $document   dans $OUTPUT
        mkdir -p "$CHEMIN/$document"
        # deplacer les fichiers detransposés vers leur dossier 
   	   	while read -r a; do
   	   		mv "$a" "$CHEMIN/$document/$a"
        done < tmp
        # Supprime la ligne correspondante au numéro de fichier dans l'index
         sed -i "\|^$numero:|d" "$INDEX"
         #supprimer le fichier temporaire crée
         rm tmp
         # quitter le programme si l'exécution s'est terminée avec succès,
         exit 0
     fi
     
      #CAS DES FICHIERS
      # Déplace les fichiers associés depuis la corbeille vers le répertoire d'origine
      for i in $num-$document_*
      do
         mv $i $CHEMIN
      done
     
     # Renomme les fichiers pour retirer le préfixe numérique
      for i in $numero-*
      do
           if [ -e "$i" ]; then
              # Supprimer le préfixe numérique du fichier
              new_name=$(echo "$i" | sed 's/^[0-9]*-//')  # Retirer le numéro initial
              mv "$i" "$new_name"
           fi
      done
     # Compile et exécute le programme pour la détransposition
      gcc detransposition.c -o detransposition
      ./detransposition "$document" "$key"
     
      echo "document $document restauré vers $CHEMIN."
fi

# Cas où l'option -d et -r n'est pas utilisée, restauration sans option
if [ $1 != '-r' ] && [ $1 != '-d' ]
then 
	  document=$1
      CHEMIN=$(pwd)
      numero=$(grep "$document" "$INDEX" | sort -t ':' -k3 -r | head -n 1 | cut -d ':' -f1)
      key=$2
      dossier=".sh-trashbox/$numero-$document"  
      num=".sh-trashbox/$numero"
      
      
      
     if [ -d "$dossier" ]; then
     #CAS DES DOSSIERS 
      # creation d'un fichier temporaire pour stocker les noms des fichier a detransposer

   	   	ls "$dossier" | cut -d '_' -f1 | uniq > tmp
   	   	# deplacer les fichiers tels qu'ils sont vers le chemin courant pour les detransposer   	   	
   	   	for i in $(ls $dossier) 
   	   	do
   	   		mv "$dossier/$i" "$CHEMIN"
   	   	done
   	   	while read a
   	   	do
   	      	#faire la detransposition		
   	   		gcc detransposition.c -o detransposition
   	   		./detransposition "$a" "$key"
   	   	done < tmp
      
   	   	# Supprimer le dossier de la corbeille une fois vidé
   	   	rmdir "$dossier"
   	   	#creer le dossier $document   dans $OUTPUT
   	   	mkdir -p "$CHEMIN/$document"
        # deplacer les fichiers detransposés vers leur dossier     
   	   	while read -r a; do
   	   		mv "$a" "$CHEMIN/$document/$a"
        done < tmp
        # Supprime la ligne correspondante au numéro de fichier dans l'index        
         sed -i "\|^$numero:|d" "$INDEX"
         #supprimer le fichier temporaire crée
         rm tmp
         # quitter le programme si l'exécution s'est terminée avec succès,
         exit 0
     fi
    
     #CAS DES FICHIERS
     # Déplace les fichiers depuis la corbeille vers le répertoire courant
      for i in $num-$document_*
      do
         mv $i $CHEMIN
      done
     
      # Renomme les fichiers pour retirer le préfixe numérique
      for i in $numero-*
      do
           if [ -e "$i" ]; then
              # Supprimer le préfixe numérique du fichier
              new_name=$(echo "$i" | sed 's/^[0-9]*-//')  # Retirer le numéro initial (par exemple, "3-")
              mv "$i" "$new_name"
           fi
      done
      # Compile et exécute le programme pour la détransposition
      gcc detransposition.c -o detransposition
      ./detransposition "$document" "$key"

fi
# Supprime la ligne correspondante au numéro de fichier dans l'index
sed -i "\|^$numero:|d" "$INDEX"
