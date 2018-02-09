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

*Q2.1*

Créé un module CellSet pour manipuler des ensembles de cellules en temps
logarithmique.

Ajouté deux champs à la structure de cellule : links, qui indique l'ensemble
des cellules dont l'object considéré est une dépendance, et deps, qui donne
l'ensemble des dépendances d'une cellule.

Changé quelques noms de plus ; ça manque de conventions ce code.
- Convertir un objet de type "type" en chaîne de caractères: string_of_type
- Afficher un objet de type "type": print_type

## Version avancés

...

## Conventions

Il est supposé que les valeurs écrites dans chaque cellule sont toujours les
évaluations de la formule asociée. Pour cette raison, sheet::update_cell_value
ne positionne pas le "dirty bit" (ce qui serait ironique lors du recalcul !).
