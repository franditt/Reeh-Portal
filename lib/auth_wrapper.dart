import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';
import 'api_service.dart';
import 'producer_provider.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/profile_completion_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final apiService = Provider.of<ApiService>(context);
    final producerProvider = Provider.of<ProducerProvider>(context, listen: false);

    if (authService.user == null) {
      // User is logged out, clear producer data
      producerProvider.clearProducer();
      return const LoginPage();
    } else {
      // User is logged in, check if their profile is complete
      return FutureBuilder<Map<String, dynamic>?>(
        future: apiService.getProducer(authService.user!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')),
            );
          } else if (snapshot.hasData && snapshot.data != null) {
            // Producer profile exists, store it in the provider
            producerProvider.setProducer(snapshot.data!);
            return const HomePage();
          } else {
            // Producer profile does not exist, needs to be created
            return const ProfileCompletionPage();
          }
        },
      );
    }
  }
}
