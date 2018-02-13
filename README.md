(Notes en vrac)

Lors d'une évaluation de fonction, le calcul est abandonné dès que l'évaluation
de l'une des deux opérandes échoue (en cas de cycle), et dans ce cas aucune
erreur n'est émise, même si le numéro de tableau demandé est invalide.

Appeler un autre tableau comme une fonction est prévu uniquement pour les
*autres* tableaux. La détection de cycle va cesser de marcher si on s'appelle
soi-même en tant que sous-fonction.

Convention: si une cellule est invalide (value = None), alors tous ses liens
(cellules qui en dépendent) le sont aussi. Donc : penser à bien invalider
récursivement.
