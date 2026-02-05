// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cultures_provider.dart';
import 'providers/ventes_provider.dart';
import 'providers/stock_provider.dart';
import 'providers/weather_provider.dart';

import 'providers/recolte_provider.dart';
import 'providers/notifications_provider.dart';
import 'providers/rapport_provider.dart';

import 'providers/chat_provider.dart';
import 'providers/user_provider.dart';

import 'services/chat_service.dart';
import 'utils/constants.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/register_screen.dart';
import 'screens/welcome_screen.dart';

import 'screens/add_culture_screen.dart';
import 'models/culture.dart';
import 'screens/stock_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/rapport_screen_new.dart';
import 'screens/notifications_screen.dart';
import 'screens/cultures_screen.dart';
import 'screens/add_vente_screen.dart';
import 'screens/ventes_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CulturesProvider()),
        ChangeNotifierProvider(create: (_) => VentesProvider()),
        ChangeNotifierProvider(create: (_) => StockProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => RecolteProvider()),
        ChangeNotifierProvider(create: (_) => NotificationsProvider()),
        ChangeNotifierProvider(create: (_) => RapportProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider.create()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'AgriFarm',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        home: const AuthWrapper(),



        routes: {
          '/welcome': (context) => const WelcomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/add-culture': (context) => const AddCultureScreen(),
          '/edit-culture': (context) => AddCultureScreen(
                culture: ModalRoute.of(context)?.settings.arguments as Culture?,
              ),
          '/stock': (context) => const StockScreen(),
          '/chat': (context) => const ChatScreen(),
          '/rapports': (context) => const RapportScreen(),
          '/notifications': (context) => const NotificationsScreen(),
          '/cultures': (context) => const CulturesScreen(),
          '/ventes': (context) => const VentesScreen(),
          '/ventes/add': (context) => const AddVenteScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Provider.of<AuthProvider>(context, listen: false).checkAuthStatus();
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isAuthenticated) {
          return const HomeScreen();
        }
        return const WelcomeScreen();
      },
    );
  }
}