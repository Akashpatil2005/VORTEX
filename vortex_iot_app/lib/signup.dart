import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:vortex_iot_app/Rescuer/Model/signupModel.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth fireAuth = FirebaseAuth.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 5),

              Lottie.network(
                'https://assets5.lottiefiles.com/packages/lf20_w51pcehl.json',
                height: 220,
              ),

              const SizedBox(height: 5),

              const Text(
                'Rescuer Registration',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Create your Vortex rescuer account',
                style: TextStyle(color: Colors.white70),
              ),

              const SizedBox(height: 24),

              buildField(
                controller: nameController,
                label: 'Full Name',
                icon: Icons.person_outline,
              ),

              const SizedBox(height: 16),

              buildField(
                controller: emailController,
                label: 'Email',
                icon: Icons.email_outlined,
              ),

              const SizedBox(height: 16),

              buildField(
                controller: phoneController,
                label: 'Phone Number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 16),

              // ROLE DROPDOWN
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonFormField<String>(
                  dropdownColor: const Color(0xFF1E293B),
                  iconEnabledColor: Colors.cyanAccent,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.badge_outlined,
                      color: Colors.white70,
                    ),
                    labelText: 'Select Role',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'RESCUER', child: Text('Rescuer')),
                    DropdownMenuItem(
                      value: 'ROBO_CONTROLLER',
                      child: Text('Robo Controller'),
                    ),
                  ],
                  onChanged: (value) {
                    roleController.text = value ?? '';
                  },
                ),
              ),

              const SizedBox(height: 16),

              buildField(
                controller: passwordController,
                label: 'Password',
                icon: Icons.lock_outline,
                isPassword: true,
              ),

              const SizedBox(height: 16),

              buildField(
                controller: confirmPasswordController,
                label: 'Confirm Password',
                icon: Icons.lock_reset_outlined,
                isPassword: true,
              ),

              const SizedBox(height: 28),

              // CREATE ACCOUNT BUTTON
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty ||
                        emailController.text.isEmpty ||
                        passwordController.text.isEmpty ||
                        roleController.text.isEmpty) {
                      return;
                    }

                    try {
                      // 1️⃣ Firebase Auth
                      UserCredential userCredential = await fireAuth
                          .createUserWithEmailAndPassword(
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                          );

                      User? user = userCredential.user;

                      if (user != null) {
                        // 2️⃣ Create model
                        signupModel newUser = signupModel(
                          uid: user.uid,
                          name: nameController.text.trim(),
                          email: emailController.text.trim(),
                          phone: phoneController.text.trim(),
                          role: roleController.text.trim(),
                        );

                        // 3️⃣ Convert model → Map
                        Map<String, dynamic> userMap = newUser.toMap();

                        // 4️⃣ Save Map to Firestore
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .set(userMap);

                        // 5️⃣ Clear fields
                        nameController.clear();
                        emailController.clear();
                        phoneController.clear();
                        roleController.clear();
                        passwordController.clear();
                        confirmPasswordController.clear();

                        Navigator.pop(context);
                      }
                    } catch (e) {
                      debugPrint('Signup Error: $e');
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
                    'Create Account',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already registered?',
                    style: TextStyle(color: Colors.white54),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Login',
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

  // 🔹 REUSABLE TEXT FIELD (UNCHANGED)
  Widget buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
