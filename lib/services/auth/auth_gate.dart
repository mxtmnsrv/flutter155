import 'package:GarageSync/pages/CustomerMainScreen.dart';
import 'package:GarageSync/pages/ManagerMainScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:GarageSync/pages/Login.dart';
import 'package:GarageSync/services/auth/auth_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final _authService = AuthService();

    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // Check for errors
            if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong!'));
            }

            // Check if user is logged in
            if (snapshot.hasData) {
              // User is logged in.
              // Use displayName as username. It can be null or empty, so provide a default.
              final String userIdentifier = snapshot.data!.uid;

              // Use FutureBuilder to check if the logged-in user is a customer
              return FutureBuilder<Map<String, dynamic>?>(
                future: _authService.getUserDetails(userIdentifier), // Call the combined function
                builder: (context, userDetailsSnapshot) {
                  if (userDetailsSnapshot.hasError) {
                    return const Center(child: Text('Error fetching user details!'));
                  }
                  if (userDetailsSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (userDetailsSnapshot.hasData && userDetailsSnapshot.data != null) {
                    final Map<String, dynamic> userDetails = userDetailsSnapshot.data!;
                    final bool isCustomer = userDetails['isCustomer'] as bool;
                    final String username = userDetails['name'] as String; // Already defaults to 'User' if null

                    if (isCustomer) {
                      return CustomerMainScreen(
                        username: username, // Pass the fetched name
                        key: ValueKey(username), // Use UID for key as it's more stable
                      );
                    } else {
                      return ManagerMainScreen(
                        username: username, // Pass the fetched name
                        key: ValueKey(username),
                      );
                    }
                  } else {
                    print("Could not fetch user details for UID: $userIdentifier. Showing login.");
                    return LoginPage(); // Fallback to LoginPage or an error screen
                  }
                },
              );
            } else {
              // User is not logged in, show LoginScreen
              return LoginPage();
            }
          }),
    );
  }
}
