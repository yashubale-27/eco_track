import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'citizen_dashboard.dart';
import '../services/firestore_service.dart';

class CitizenSignupPage extends StatefulWidget {
  const CitizenSignupPage({super.key});

  @override
  State<CitizenSignupPage> createState() => _CitizenSignupPageState();
}

class _CitizenSignupPageState extends State<CitizenSignupPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _emailField(),
              const SizedBox(height: 12),

              _passwordField(),
              const SizedBox(height: 12),

              _confirmPasswordField(),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _signup,
                  child: isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text('Create Account'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      final userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      final user = userCredential.user;
      if (user != null) {
        await FirestoreService.saveUserProfile(
          name: 'Citizen',
          email: user.email!,
          role: 'citizen',
        );
      }
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const CitizenDashboard(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Signup failed'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }
  // 📧 Email Field
  Widget _emailField() {
    return TextFormField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(labelText: 'Email'),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Email is required';
        }
        if (!value.contains('@')) {
          return 'Enter a valid email';
        }
        return null;
      },
    );
  }

  // 🔒 Password Field
  Widget _passwordField() {
    return TextFormField(
      controller: passwordController,
      obscureText: true,
      decoration: const InputDecoration(labelText: 'Password'),
      validator: (value) {
        if (value == null || value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

  // 🔒 Confirm Password Field
  Widget _confirmPasswordField() {
    return TextFormField(
      controller: confirmPasswordController,
      obscureText: true,
      decoration: const InputDecoration(labelText: 'Confirm Password'),
      validator: (value) {
        if (value != passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }
}
