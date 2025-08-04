
##  Binôme

- **MESSAHEL Lahna** 
- **AIT ALLALA Melynda** 

## Présentation du projet

Ce projet propose un **système de gestion de suppression et de restauration** de fichiers/dossiers via des scripts Bash et un programme en C.  
Il permet notamment de :
- Supprimer des fichiers ou dossiers via transposition et stockage sécurisé.
- Restaurer ces éléments à différents emplacements selon les options.
- Conserver un **index complet** des suppressions.
- Gérer automatiquement les conflits de noms.
- Automatiser la **transposition/détransposition** des données avec un mot de passe.

##  Technologies utilisées

###  Bash
- Gestion des suppressions/restaurations.
- Lecture et écriture dans l’index.
- Manipulation de fichiers, chemins, et options .
- Création automatique de dossiers si besoin.

###  C (avec `gcc`)
- Programme `detransposition.c` :
  - Lecture des fragments transposés.
  - Reconstruction du fichier original en respectant l’ordre défini par la clé de transposition.
  - Suppression des fragments après reconstitution.

### Fichiers système
- `.sh-trashbox/` : dossier corbeille auto-géré.
- `INDEX` : structure d’enregistrement simple sous forme `ID:CHEMIN:NOM:DATE`.

> L'intégration de Bash et C permet d’automatiser **transposition**, **stockage**, et **restauration complète** des données supprimées.


