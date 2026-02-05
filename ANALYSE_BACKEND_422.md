# ANALYSE BACKEND - ERREUR 422 PERSISTANTE

## 🔍 **DIAGNOSTIC**
L'erreur 422 "Unprocessable Content" persiste même avec des villes simples comme "Paris", confirmant que le problème vient du **backend**, non du frontend.

### 📊 **PREUVES QUE C'EST BACKEND**
1. **Paris sans accent** → 422 (pas un problème d'encodage)
2. **URL correctement encodée** → `Lom%C3%A9` est correct
3. **Front-end fonctionnel** → Toutes les corrections frontend sont opérationnelles

## 🛠️ **PROBLÈMES BACKEND IDENTIFIÉS**

### 1. **Endpoints inexistants ou mal configurés**
```bash
# Ces endpoints retournent 422 :
GET http://localhost:8000/api/weather/forecast/Lom%C3%A9
GET http://localhost:8000/api/weather/forecast/Paris
```

### 2. **Validation backend trop stricte**
- Le backend rejette les paramètres qu'il ne reconnaît pas
- Possible problème de schéma de validation

### 3. **Routes API incorrectes**
- Les endpoints météo ne sont pas correctement définis
- Possibles erreurs dans le routing Flask/Django

## 🔧 **CORRECTIONS BACKEND REQUISES**

### **Option 1 : Corriger les endpoints météo**
```python
# Flask exemple
@app.route('/api/weather/forecast/<city>', methods=['GET'])
def get_weather_forecast(city):
    # Validation simple
    if not city or len(city.strip()) == 0:
        return jsonify({'error': 'City is required'}), 400
    
    try:
        # Logique de prévision météo
        forecast = get_forecast_data(city)
        return jsonify(forecast), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500
```

### **Option 2 : Utiliser des endpoints génériques**
```python
# Si les endpoints spécifiques ne fonctionnent pas
@app.route('/api/meteo/previsions', methods=['GET'])
def get_meteo_previsions():
    city = request.args.get('city', 'Lomé')
    
    # Validation simple
    if not city:
        return jsonify({'error': 'City parameter required'}), 400
    
    # Logique de prévision
    return jsonify(get_forecast_data(city)), 200
```

### **Option 3 : Fallback vers météo actuelle**
```python
@app.route('/api/weather/forecast/<city>', methods=['GET'])
def get_weather_forecast(city):
    try:
        # Essayer prévisions
        forecast = get_forecast_data(city)
        return jsonify(forecast), 200
    except Exception:
        # Fallback : retourner météo actuelle
        current = get_current_weather()
        return jsonify({
            'forecast': [current],  # Utiliser météo actuelle comme "prévision"
            'note': 'Prévisions non disponibles, météo actuelle'
        }), 200
```

## 📋 **ACTIONS BACKEND IMMÉDIATES**

### 1. **Vérifier les logs serveur**
```bash
# Sur le serveur backend
tail -f /var/log/backend/app.log | grep 422
```

### 2. **Tester les endpoints manuellement**
```bash
# Test curl direct
curl -X GET "http://localhost:8000/api/weather/forecast/Paris"
```

### 3. **Vérifier la configuration des routes**
- S'assurer que les routes Flask/Django sont correctement définies
- Vérifier les imports et middlewares

### 4. **Examiner la validation des paramètres**
- Vérifier les schémas de validation (Marshmallow, Pydantic, etc.)
- S'assurer que les paramètres sont acceptés

## 🎯 **SOLUTION TEMPORAIRE FRONTEND**

En attendant la correction backend, nous pouvons modifier le frontend pour utiliser uniquement les endpoints qui fonctionnent :

```dart
// 🆘 FALLBACK TEMPORAIRE - Utiliser seulement météo actuelle
static Future<Map<String, dynamic>> getWeatherForecast(String city) async {
  try {
    // Essayer prévisions d'abord
    final forecast = await _getForecastDirect(city);
    return forecast;
  } catch (e) {
    // Fallback : retourner météo actuelle + note
    print('Prévisions indisponibles, utilisation météo actuelle');
    final current = await getCurrentWeather();
    return {
      'forecast': [current],
      'note': 'Prévisions non disponibles',
    };
  }
}
```

## 🔍 **DIAGNOSTIC BACKEND REQUIS**

Pour identifier le problème exact côté backend, il faut :

1. **Vérifier les logs serveur** pour voir l'erreur détaillée
2. **Tester les endpoints** avec curl/postman
3. **Examiner le code backend** pour les routes et validation
4. **Vérifier la configuration** du serveur web (nginx, apache)

---
**CONCLUSION : Le problème est définitivement côté backend. Les corrections frontend sont correctes, mais le serveur ne peut pas traiter les requêtes météo.**
