import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'citizen_dashboard.dart';
import 'citizen_signup_page.dart';
import '../services/google_auth_service.dart';
import '../services/firestore_service.dart';

class CitizenLoginPage extends StatefulWidget {
  const CitizenLoginPage({super.key});

  @override
  State<CitizenLoginPage> createState() => _CitizenLoginPageState();
}

class _CitizenLoginPageState extends State<CitizenLoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌄 Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/eco_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 🪟 Glass Login Card
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: 320,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Citizen Login',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        _emailField(),
                        const SizedBox(height: 12),

                        _passwordField(),
                        const SizedBox(height: 20),

                        // 🔐 Login Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _login,
                            child: isLoading
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : const Text('Login'),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // 🔵 Google Sign-In
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.g_mobiledata, size: 30),
                            label: const Text("Sign in with Google"),
                            onPressed: _googleLogin,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // ➕ Signup
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CitizenSignupPage(),
                              ),
                            );
                          },
                          child: const Text('Create Account'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔐 Email & Password Login (NO Firestore write)
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const CitizenDashboard(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Login failed')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // 🔵 Google Login (SAVE Firestore profile once)
  Future<void> _googleLogin() async {
    try {
      final result = await GoogleAuthService.signInWithGoogle();
      final user = result?.user;
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const CitizenDashboard(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Google Sign-In failed")),
      );
    }
  }

  // 📧 Email Field
  Widget _emailField() {
    return TextFormField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: _inputDecoration('Email'),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Email is required';
        if (!value.contains('@')) return 'Enter a valid email';
        return null;
      },
    );
  }

  // 🔒 Password Field
  Widget _passwordField() {
    return TextFormField(
      controller: passwordController,
      obscureText: true,
      decoration: _inputDecoration('Password'),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Password is required';
        if (value.length < 6) return 'Password must be at least 6 characters';
        return null;
      },
    );
  }

  // 🎨 Input Decoration
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white.withOpacity(0.6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}
