# ✅ INFORMATIONS CORRECTES - Création Stock AgriFarm

## 🎯 VERSION CORRIGÉE

### Données nécessaires pour créer un stock :

**🔴 OBLIGATOIRES :**
- `culture_id` : Identifiant de la culture (entier) → **Remplace "produit"**
- `quantite` : Quantité en stock (double, min 0)
- `unite` : Unité de mesure (chaîne, ex: "kg", "tonne", "sac", "litre")
- `prix_unitaire` : Prix unitaire en euros (double) → **Nouveau champ manquant**
- `date_achat` : Date d'achat → **Remplace "date_entree"**
- `statut` : Statut (chaîne, ex: "disponible")

**🟡 OPTIONNELS :**
- `date_expiration` : Date d'expiration (peut être null)
- `description` : Description (chaîne)
- `fournisseur` : Nom du fournisseur (chaîne)

**⚪ AUTOMATIQUES :**
- `user_id` : ID utilisateur (pris du token JWT)

### URL pour la création :
```
POST /api/stocks
Content-Type: application/json
Authorization: Bearer {token}
```

## ❌ CORRECTIONS APPORTÉES

| **INCORRECT** | **CORRECT** | **RAISON** |
|---------------|-------------|------------|
| `user_id` (obligatoire) | `culture_id` (obligatoire) | `user_id` est automatique |
| `produit` | `culture_id` | Le produit = culture associée |
| `date_entree` | `date_achat` | Nom de champ correct |
| `date_sortie` | **SUPPRIMÉ** | Champ inexistant |
| - | `prix_unitaire` (obligatoire) | Champ manquant |
| `quantite` (min 0) | `quantite` (min 0, mais validation frontend > 0) | Validation frontend stricte |
| `statut` (générique) | `statut` ("disponible" par défaut) | Valeur par défaut définie |

## 📋 EXEMPLE JSON CORRECT

```json
{
  "culture_id": 5,
  "quantite": 25.0,
  "unite": "sac",
  "prix_unitaire": 15.99,
  "date_achat": "2024-12-01",
  "statut": "disponible",
  "description": "Semences de blé hybride",
  "fournisseur": "GraineMax"
}
```

## 🔍 POINTS CLÉS

1. **`culture_id` est obligatoire** - Doit référencer une culture existante
2. **`prix_unitaire` est obligatoire** - Pour calculer la valeur totale
3. **`date_achat` remplace `date_entree`** - Nom correct du champ
4. **`date_sortie` n'existe pas** - Supprimer cette information
5. **Statut par défaut** : "disponible"
6. **Validation frontend** : Quantité > 0, Prix > 0

---

*Corrections basées sur l'analyse du code source AgriFarm*
