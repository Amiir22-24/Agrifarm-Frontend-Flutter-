// lib/models/user.dart - VERSION COMPLÈTE AVEC PROFIL
class User {
  final int id;
  final String name;
  final String email;
  final UserProfile? profile;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profile: json['profile'] != null 
          ? UserProfile.fromJson(json['profile'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (profile != null) 'profile': profile!.toJson(),
    };
  }

  // Copier avec modifications
  User copyWith({
    int? id,
    String? name,
    String? email,
    UserProfile? profile,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profile: profile ?? this.profile,
    );
  }

  // Utilitaires
  bool get hasProfile => profile != null;
  String get displayName => name.isNotEmpty ? name : email;
  
  String? get phone => profile?.phone;
  String? get address => profile?.address;
  String? get farmName => profile?.farmName;
  String? get defaultWeatherCity => profile?.defaultWeatherCity;
}


class UserProfile {
  final int? id;
  final String phone; // Maintenant obligatoire
  final String address; // Maintenant obligatoire
  final String defaultWeatherCity; // Maintenant obligatoire
  final String? farmName; // Optionnel

  UserProfile({
    this.id,
    required this.phone,
    required this.address,
    required this.defaultWeatherCity,
    this.farmName,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      phone: json['phone'],
      address: json['address'],
      farmName: json['farm_name'] ?? json['farmName'],
      defaultWeatherCity: json['default_weather_city'] ?? json['defaultWeatherCity'],
    );
  }


  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'phone': phone,
      'address': address,
      'default_weather_city': defaultWeatherCity,
      if (farmName != null) 'farm_name': farmName,
    };
  }

  // Copier avec modifications
  UserProfile copyWith({
    int? id,
    String? phone,
    String? address,
    String? farmName,
    String? defaultWeatherCity,
  }) {
    return UserProfile(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      farmName: farmName ?? this.farmName,
      defaultWeatherCity: defaultWeatherCity ?? this.defaultWeatherCity,
    );
  }

  // Utilitaires
  bool get isEmpty => phone == null && address == null && farmName == null && defaultWeatherCity == null;
  bool get hasInfo => !isEmpty;
  
  String get fullInfo {
    final List<String> info = [];
    if (phone != null) info.add('📞 $phone');
    if (address != null) info.add('📍 $address');
    if (farmName != null) info.add('🚜 $farmName');
    if (defaultWeatherCity != null) info.add('🌤️ $defaultWeatherCity');
    
    return info.isNotEmpty ? info.join('\n') : 'Aucun profil configuré';
  }
}
