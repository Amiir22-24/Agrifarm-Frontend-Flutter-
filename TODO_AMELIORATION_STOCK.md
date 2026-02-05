# TODO - Amélioration affichage Stock Screen

## Objectif
Améliorer l'affichage des prix et du nom du produit dans stock_screen.dart

## Tâches

### 1. Formatage des prix
- [x] Analyser le code existant
- [x] Ajouter des séparateurs de milliers (formatage français)
- [x] Améliorer les libellés des colonnes
- [x] Consolider le style visuel

### 2. Affichage du nom du produit
- [x] Augmenter la limite de caractères à 35
- [x] Afficher le type de culture en sous-ligne
- [x] Ajouter une icône de culture
- [x] Améliorer le tooltip avec informations complètes

### 3. Améliorations visuelles
- [x] Appliquer le style monnaie aux prix
- [x] Mettre en valeur la colonne "Valeur" en gras et vert avec fond coloré
- [x] Améliorer l'alignement des colonnes
- [x] Formatage décimal français (virgule au lieu de point)

## Progression
✅ Implémentation terminée - Toutes les améliorations ont été appliquées

## Résumé des modifications

### Formatage des prix
- Séparateurs de milliers français (espace)
- Séparateur décimal français (virgule)
- Exemple: `1 234,56 €` au lieu de `1234.56 €`

### Cellule Produit
- Icône contextuelle selon le type de culture (grain, légume, fruit, etc.)
- Nom du produit avec limite de 35 caractères
- Type de culture affiché en italique en dessous
- Tooltip complet avec nom et type

### Cellule Quantité
- Séparateur décimal français
- Unité affichée en plus petit en dessous

### Cellule Prix unitaire et Valeur
- Prix formaté avec style monnaie
- Valeur en gras vert avec fond coloré (vert clair)


