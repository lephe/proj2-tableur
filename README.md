# Projet 2 : Rendu 1 (Sébastien Michelland et Sébastien Baumert)

L'ensemble des questions a été traité, exception faite de la question 4.2
(intervalles) : pas à cause d'un problème technique, plus d'une communication
bancale.

Le dossier tests/ contient des tests unitaires. Le fichier "CHANGELOG.md"
recense les modifications apportées pour répondre à chaque question.


## Points intéressants

Il y a un nouveau fichier, "config.ml", qui stocke les options de ligne de
commande pour toute l'exécution.

Le tableur proposé fait de l'évaluation paresseuse et ne calculera strictement
rien tant qu'aucun affichage n'est demandé. Ça change le comportement de
plusieurs tests "collaboratifs" et évite quelques erreurs.

Les instructions qui causent des cycles sont donc systématiquement des Show*,
et un "_" est affiché si un cycle se produit (et pas une ancienne valeur de la
cellule, qui n'aura possiblement jamais été calculée).

Les noms de colonnes à plusieurs lettres sont gérés ; la feuille de calcul fait
100 * 100 par défaut pour exploiter cette fonctionnalité.


## Gestion des erreurs

Appeler un autre tableau comme une fonction est prévu uniquement pour les
*autres* tableaux. S'appeler soi-même en tant que sous-fonction est
explicitement interdit ; l'évaluation de fonctions mutuellement récursives
fournit un résultat indéfini au mieux, ne s'arrête jamais au pire.

L'application détecte les cycles à l'intérieur de chaque tableau mais fait
confiance à l'utilisateur pour éviter les cycles entre les tableaux.

Lors d'une évaluation de fonction, le calcul est abandonné dès que l'évaluation
de l'une des deux opérandes échoue (en cas de cycle), et dans ce cas aucune
erreur n'est émise, même si le numéro de tableau demandé est invalide.
