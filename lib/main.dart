import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/loading_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/masjid_provider.dart';
import 'constants/environment.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'widgets/global_loading_overlay.dart';

void main() {
final apiService = ApiService();
final authService = AuthService(api: apiService);
// Set environment (you can change this based on build flavor)
  AppConfig.currentEnv = Environment.staging;

  runApp(MyApp(authService: authService));
}

class MyApp extends StatelessWidget {
  final AuthService authService;

  const MyApp({super.key, required this.authService});
  

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoadingProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider(authService: authService)),
        ChangeNotifierProvider(create: (_) => MasjidProvider()),
        // ChangeNotifierProvider(create: (_) => LoadingProvider()),
        // ProxyProvider<LoadingProvider, AuthProvider>(
        //   update: (_, loadingProvider, __) => AuthProvider(
        //     authService: authService,
        //     loadingProvider: loadingProvider,
        //   ),
        // ),
      ],
      child: MaterialApp(
        title: 'Masjid Locator',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: GlobalLoadingOverlay(
          child: AuthWrapper(),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.initAuth();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (_isLoading) {
      return SplashScreen();
    }

    return authProvider.isAuth ? HomeScreen() : LoginScreen();
  }
}