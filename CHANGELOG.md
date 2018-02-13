## Version débutants

*Q1.1*

Implémenté les fonctions sheet::eval_form et sheet::eval_cell.

*Q1.2*

Ajouté une variable "dirty" indiquant si la feuille a besoin d'être recalculée.
Renommé sheet_recompute and sheet_update : son nouveau rôle est de faire ce
qu'il faut pour s'assurer que la feuille est cohérente, sans forcément tout
recalculer.

Ajouté des commentaires au langage du tableur et un test "fibo10" pour tester
la propagation des données.

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

*Q3.1*

Changé le type number en un type num qui énumère F (constructeur de float) et I
(constructeur d'int). Les opérations de base (`+ - * / min max`) ont été
réimplémentées dans cell.ml.

*Q3.2*

...

*Q3.3*

Modifié la fonction d'initialisation, désormais sheet_create qui est appelée
par Array.make de façon automatique (on n'a plus l'état transitoir où le
tableau aliase le même record sur toutes les cellules).

Ajouté des tokens SWITCHTO (/SwitchTo/) et SHEET (/s[0-9]+/) au lexer, et une
règle de production dans le parser pour cette commande.

Créé un test basique "sheets" pour vérifier que les cellules utilisées ne
s'écrasent pas les unes les autres.

*Q3.4*

Ajouté un type de formule, Func of int * form * form, pour les appels de
tableaux. Corrigé un terrible bug où l'invalidation des dépendances lors de la
modification d'une cellule n'était pas récursive. x)

Écrit un nouveau test qui calcule une exponentation en temps linéaire (exposant
borné à 8).

Ajouté le support des noms de colonnes à plusieurs lettres. C'est plus
compliqué que ça en a l'air, donc j'ai laissé un bout de tests dans main.ml.
On pourrait mettre une option dessus, éventuellement.
