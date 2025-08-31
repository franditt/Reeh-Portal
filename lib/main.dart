import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';
import 'api_service.dart';
import 'auth_wrapper.dart';
import 'producer_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // NOTE: You'll need to configure Firebase for your project.
  // For web, this is done in web/index.html.
  // For other platforms, you would use the Firebase CLI and add the generated files.
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider(create: (_) => ApiService()),
        ChangeNotifierProvider(create: (_) => ProducerProvider()),
      ],
      child: MaterialApp(
        title: 'Producer Portal',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}
