# INFORMATIONS CORRIGÉES - Création d'un Stock AgriFarm

## Données nécessaires :

**CHAMPS OBLIGATOIRES :**
- `culture_id` : Identifiant de la culture associée (obligatoire, numérique entier)
- `quantite` : Quantité en stock (obligatoire, numérique, minimum 0, validé > 0 au frontend)
- `unite` : Unité de mesure (obligatoire, chaîne de caractères, max 50)
- `prix_unitaire` : Prix unitaire en euros (obligatoire, numérique, minimum 0)
- `date_achat` : Date d'achat du stock (obligatoire, format date YYYY-MM-DD)
- `statut` : Statut du stock (obligatoire, chaîne de caractères, par défaut "disponible")

**CHAMPS OPTIONNELS :**
- `date_expiration` : Date d'expiration du stock (optionnel, peut être null, format date)
- `description` : Description du stock (optionnel, chaîne de caractères)
- `fournisseur` : Nom du fournisseur (optionnel, chaîne de caractères)

**CHAMPS AUTOMATIQUES :**
- `user_id` : Identifiant de l'utilisateur (automatique depuis le token JWT)

**CHAMPS INEXISTANTS À SUPPRIMER :**
- ❌ `produit` : N'existe pas (remplacé par `culture_id`)
- ❌ `date_entree` : Mauvais nom (c'est `date_achat`)
- ❌ `date_sortie` : Ce champ n'existe pas dans le modèle

## URL pour la création :
L'URL pour créer un stock est : **/api/stocks** avec une requête **POST**.

**Headers requis :**
- `Content-Type: application/json`
- `Authorization: Bearer {token_jwt}`

## Exemple JSON corrigé :

```json
{
  "culture_id": 5,
  "quantite": 25.0,
  "unite": "sac",
  "prix_unitaire": 15.99,
  "date_achat": "2024-12-01",
  "statut": "disponible",
  "date_expiration": "2025-12-01",
  "description": "Semences de blé hybride",
  "fournisseur": "GraineMax"
}
```

## Corrections principales apportées :

1. ✅ **`culture_id` remplace `produit`** - Le produit est déterminé par la culture associée
2. ✅ **`date_achat` remplace `date_entree`** - Nom de champ correct
3. ✅ **`prix_unitaire` ajouté comme obligatoire** - Champ manquant dans l'analyse originale
4. ✅ **`date_sortie` supprimé** - Ce champ n'existe pas
5. ✅ **`user_id` listed comme automatique** - Pas besoin de l'envoyer manuellement
6. ✅ **`statut` avec valeur par défaut** - "disponible" par défaut

## Notes importantes :

- La `culture_id` doit référencer une culture existante
- Le `prix_unitaire` est utilisé pour calculer la `valeurTotale` automatiquement
- Les dates doivent être au format `YYYY-MM-DD`
- Le frontend valide : culture sélectionnée, quantité > 0, prix > 0, date d'achat présente
