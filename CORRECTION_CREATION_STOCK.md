# CORRECTION : Création d'un Stock - AgriFarm App

## ❌ INFORMATIONS INCORRECTES (à corriger)

**Données mentionnées incorrectement :**
- `user_id` : Mentionné comme obligatoire mais c'est automatique
- `produit` : Champ inexistant
- `date_entree` : Mauvais nom de champ
- `date_sortie` : Champ inexistant
- `quantite` : Limite minimum non vérifiée (0 accepté mais devrait être > 0)
- Champs manquants : `prixUnitaire`, `dateAchat`

## ✅ INFORMATIONS CORRECTES

### URL pour la création
```
POST /api/stocks
Content-Type: application/json
Authorization: Bearer {token}
```

### Structure JSON pour création de stock

```json
{
  "culture_id": 1,           // OBLIGATOIRE - ID de la culture associée
  "quantite": 100.5,         // OBLIGATOIRE - Quantité numérique (min 0)
  "unite": "kg",            // OBLIGATOIRE - Unité (kg, tonne, sac, litre)
  "prix_unitaire": 25.50,   // OBLIGATOIRE - Prix en euros
  "date_achat": "2024-01-15", // OBLIGATOIRE - Date d'achat (format YYYY-MM-DD)
  "statut": "disponible",   // OBLIGATOIRE - Statut (disponible, epuise, etc.)
  "date_expiration": "2025-01-15", // OPTIONNEL - Date d'expiration
  "description": "Engrais organique", // OPTIONNEL - Description
  "fournisseur": "BioFertil"  // OPTIONNEL - Nom du fournisseur
}
```

### Détail des champs

#### 🔴 CHAMPS OBLIGATOIRES
| Champ | Type | Description | Validation |
|-------|------|-------------|------------|
| `culture_id` | Integer | ID de la culture associée | Doit exister en base |
| `quantite` | Float | Quantité en stock | Minimum 0 |
| `unite` | String | Unité de mesure | Max 50 caractères |
| `prix_unitaire` | Float | Prix unitaire en € | Minimum 0 |
| `date_achat` | Date | Date d'achat | Format YYYY-MM-DD |
| `statut` | String | Statut du stock | Max 50 caractères |

#### 🟡 CHAMPS OPTIONNELS
| Champ | Type | Description |
|-------|------|-------------|
| `date_expiration` | Date | Date d'expiration (format YYYY-MM-DD) |
| `description` | String | Description du stock |
| `fournisseur` | String | Nom du fournisseur |

#### ⚪ CHAMPS AUTOMATIQUES
| Champ | Type | Description |
|-------|------|-------------|
| `user_id` | Integer | Identifiant utilisateur (pris du token JWT) |
| `id` | Integer | ID unique (généré automatiquement) |

### Exemple complet

```json
{
  "culture_id": 5,
  "quantite": 25.0,
  "unite": "sac",
  "prix_unitaire": 15.99,
  "date_achat": "2024-12-01",
  "date_expiration": "2025-12-01",
  "statut": "disponible",
  "description": "Semences de blé hybride",
  "fournisseur": "GraineMax"
}
```

### URL Backend
- **Base URL** : `http://localhost:8000/api`
- **Endpoint** : `/stocks`
- **Méthode** : `POST`

### Réponse attendue (201 Created)
```json
{
  "stock": {
    "id": 123,
    "culture_id": 5,
    "quantite": 25.0,
    "unite": "sac",
    "prix_unitaire": 15.99,
    "date_achat": "2024-12-01",
    "date_expiration": "2025-12-01",
    "statut": "disponible",
    "description": "Semences de blé hybride",
    "fournisseur": "GraineMax",
    "created_at": "2024-12-01T10:30:00.000Z"
  }
}
```

### Notes importantes

1. **culture_id** : Ce champ est **obligatoire** et doit référencer une culture existante
2. **Statut par défaut** : "disponible" si non spécifié
3. **Prix unitaire** : Obligatoire pour le calcul de la valeur totale
4. **Date format** : Format ISO (YYYY-MM-DD) pour l'API
5. **Authentification** : Token JWT requis dans le header Authorization

### Validation côté frontend
Le formulaire `AddStockDialog` dans `stock_screen.dart` valide :
- ✅ Culture sélectionnée
- ✅ Quantité saisie (> 0)
- ✅ Prix unitaire saisi (> 0)
- ✅ Date d'achat sélectionnée

## 🔧 Corrections à apporter

1. **Remplacer** `user_id` par `culture_id` (obligatoire)
2. **Supprimer** `produit` (remplacé par `culture_id`)
3. **Remplacer** `date_entree` par `date_achat`
4. **Supprimer** `date_sortie` (champ inexistant)
5. **Ajouter** `prix_unitaire` (obligatoire)
6. **Ajouter** validation minimum pour `quantite` (> 0)
7. **Modifier** statut par défaut à "disponible"

---

*Document généré le ${new Date().toLocaleDateString()} - Basé sur l'analyse du code source AgriFarm*
