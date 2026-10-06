import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:vortex_iot_app/Rescuer/View/RescuerOverviewPage.dart';
import 'package:vortex_iot_app/RoboController/View/RoboControllerHome.dart';
import 'package:vortex_iot_app/bottomNavBar.dart';
import 'package:vortex_iot_app/service/auth_service.dart';
import 'package:vortex_iot_app/signup.dart';
import 'package:vortex_iot_app/Rescuer/Model/signupModel.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? userRole;

  // 🔥 INIT METHOD AFTER LOGIN
  Future<void> _initUser(User user) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        log("User document not found");
        return;
      }

      signupModel loggedUser = signupModel.fromMap(
        doc.data() as Map<String, dynamic>,
      );

      userRole = loggedUser.role.trim().toLowerCase();

      log("USER ROLE: $userRole");

      _navigateByRole();
    } catch (e) {
      log("Init User Error: $e");
    }
  }

  //  ROLE BASED NAVIGATION
  void _navigateByRole() {
    if (userRole == 'robo_controller') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => RoboControllerHomePage()),
      );
    } else if (userRole == 'rescuer') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Bottomnavbar()),
      );
    } else {
      log("Unknown role detected: $userRole");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              const Text(
                'Welcome back User',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Sign in to continue your rescue journey',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),

              const SizedBox(height: 12),

              Lottie.network(
                "https://assets2.lottiefiles.com/packages/lf20_qp1q7mct.json",
                height: 180,
              ),

              const SizedBox(height: 20),

              // 📧 EMAIL
              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintText: 'sanket@gmail.com',
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: Colors.white70,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 🔒 PASSWORD
              TextField(
                controller: passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintText: '••••••••',
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Colors.white70,
                  ),
                  suffixIcon: const Icon(
                    Icons.visibility_off_outlined,
                    color: Colors.white54,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 🔐 LOGIN BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      if (emailController.text.trim().isEmpty ||
                          passwordController.text.trim().isEmpty) {
                        return;
                      }

                      User? user = await AuthServices().loginUser(
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                      );

                      if (user == null) return;

                      await _initUser(user);
                    } catch (e) {
                      log("Login Error: $e");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              //WITHOUT LOGIN NAVIGATION
              Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Bottomnavbar()),
                      );
                    },
                    child: Text("Res"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RoboControllerHomePage(),
                        ),
                      );
                    },
                    child: Text("Ctrl"),
                  ),
                ],
              ),

              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Don’t have an account?',
                    style: TextStyle(color: Colors.white54),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignUpPage()),
                      );
                    },
                    child: const Text(
                      'Create one',
                      style: TextStyle(color: Colors.cyanAccent),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
