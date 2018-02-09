## Version débutants

*Q1.1*

Implémenté les fonctions sheet::eval_form et sheet::eval_cell.

*Q1.2*

Ajouté une variable "dirty" indiquant si la feuille a besoin d'être recalculée.
Renommé sheet_recompute and sheet_update : son nouveau rôle est de faire ce
qu'il faut pour s'assurer que la feuille est cohérente, sans forcément tout
recalculer.

Ajouté des commentaires au langage du tableur et un test "fibonacci" pour tester la propagation des données.

*Q1.3*

Ajouté des tokens MAX et MIN et des règles de parsing associées. Étendu le type
oper (avec renommage, parce que sans espaces de noms on se perd); étendu
cell::oper2string et sheet::eval_form.

Modifié lexer.mll pour autoriser les nombres négatifs en entrée.

Ajouté un test "functions" pour tester les cinq fonctions disponibles.

## Version intermédiaires

*Q2.2*

Créé un module CellSet pour manipuler des ensembles de cellules en temps
logarithmique.

Ajouté deux champs à la structure de cellule : links, qui indique l'ensemble
des cellules dont l'object considéré est une dépendance, et deps, qui donne
l'ensemble des dépendances d'une cellule.

Changé quelques noms de plus ; ça manque de conventions ce code.
- Convertir un objet de type "type" en chaîne de caractères: string_of_type
- Afficher un objet de type "type": print_type

Implémenté un mode d'évaluation paresseuse à l'aide des dépendances : un script
qui n'affiche rien ne calcule rien, et seules les cellules utilisées sont
évaluées. À chaque fois que la formule d'une cellule est changée, sa valeur,
ainsi que celle des cellules qui en dépendent, est invalidée.

Petite optimisation : si la nouvelle formule est une constante, sa valeur est
inscrite immédiatement dans la cellule mise à jour (au lieu de délayer
l'évaluation, qui pour le coup est triviale).

*Q2.3*

Implémenté la détection des cycles à l'aide d'un paramètre passé à
l'évaluateur : ensemble des cellules déjà évaluées pour un même appel à
evel_cell (ie. trace de la pile de récursion).

Une évaluation qui échoue renvoie silencieusement None, et affiche un message
d'erreur si le mode debug est activé.

Ajouté un petit module Config pour gérer les options de ligne de commande, et
implémenté l'option -naive pour revenir à l'évaluation bourrine de l'ensemble
de la grille à chaque affichage. L'évaluation paresseuse reste le défaut.

## Version avancés

...

## Conventions

Il est supposé que les valeurs écrites dans chaque cellule sont toujours les
évaluations de la formule asociée. Pour cette raison, sheet::update_cell_value
ne positionne pas le "dirty bit" (ce qui serait ironique lors du recalcul !).
