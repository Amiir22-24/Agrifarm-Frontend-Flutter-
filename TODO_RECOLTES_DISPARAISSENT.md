# TODO - Correction Récoltes qui disparaissent

## Problème
Les récoltes créées ne s'affichaient pas dans l'app Flutter.

## Cause identifiée
Le backend Laravel retourne une **structure paginée**:
```json
{
    "current_page": 1,
    "data": [ {...}, {...} ],
    "total": 4
}
```

Mais le code Flutter attendait une **liste directe**.

## Modifications apportées

### Fichier: `lib/services/recolte_service.dart`

**Méthode `getRecoltes()` - Avant:**
```dart
if (response.statusCode == 200) {
  final data = jsonDecode(response.body);
  return (data as List).map((json) => Recolte.fromJson(json)).toList();
}
```

**Méthode `getRecoltes()` - Après:**
```dart
if (response.statusCode == 200) {
  final data = jsonDecode(response.body);
  
  // ✅ CORRECTION: Le backend retourne une structure paginée avec "data"
  if (data is Map<String, dynamic> && data['data'] != null) {
    // Format paginé: {data: [...], current_page: 1, ...}
    final List<dynamic> dataList = data['data'] as List<dynamic>;
    return dataList.map((json) => Recolte.fromJson(json as Map<String, dynamic>)).toList();
  } else if (data is List) {
    // Format liste directe
    return data.map((json) => Recolte.fromJson(json as Map<String, dynamic>)).toList();
  }
  
  return [];
}
```

## Résultat
✅ Les récoltes de l'utilisateur (ID 4) s'affichent maintenant correctement:
- 4 récoltes de Maïs (15kg, 25kg, 50kg, 15kg)
- Toutes de qualité "excellente"
- Dates: 2026-02-03

## Note
L'app utilise maintenant l'endpoint `/api/recoltes` qui retourne les données paginées, et le service Flutter filtre correctement ces données pour les afficher.

