import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _agreedToTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Logo + Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.eco, size: 40, color: Color(0xFF2ECC71)),
                    const SizedBox(width: 8),
                    Text("Create Account",
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),

                const SizedBox(height: 32),

                // Full Name
                TextField(
                  decoration: InputDecoration(
                    hintText: "Enter your full name",
                    labelText: "Full Name",
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),

                // Email
                TextField(
                  decoration: InputDecoration(
                    hintText: "Enter your email",
                    labelText: "Email Address",
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 16),

                // Password
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Create a password",
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: const Icon(Icons.visibility_outlined),
                  ),
                ),
                const SizedBox(height: 16),

                // Confirm Password
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Confirm your password",
                    labelText: "Confirm Password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: const Icon(Icons.visibility_outlined),
                  ),
                ),

                const SizedBox(height: 16),

                // Terms & Conditions
                Row(
                  children: [
                    Checkbox(
                      value: _agreedToTerms,
                      onChanged: (value) {
                        setState(() {
                          _agreedToTerms = value ?? false;
                        });
                      },
                    ),
                    const Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: "I agree to ",
                          style: TextStyle(color: Colors.grey),
                          children: [
                            TextSpan(
                              text: "Terms of Service",
                              style: TextStyle(
                                  color: Color(0xFF2ECC71),
                                  fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: " and the "),
                            TextSpan(
                              text: "Privacy Policy",
                              style: TextStyle(
                                  color: Color(0xFF2ECC71),
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Create Account button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _agreedToTerms
                        ? () {
                            // ✅ Navigate to Dashboard/Home after register
                            context.go('/home');
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2ECC71),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text("Create Account"),
                  ),
                ),

                const SizedBox(height: 16),

                // Already have account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    InkWell(
                      onTap: () {
                        context.go('/login');
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Color(0xFF2ECC71),
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline, // optional
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Divider with text
                Row(
                  children: const [
                    Expanded(child: Divider(thickness: 1)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text("Or sign up with",
                          style: TextStyle(color: Colors.grey)),
                    ),
                    Expanded(child: Divider(thickness: 1)),
                  ],
                ),
                const SizedBox(height: 16),

                // Google Sign-in button with real logo
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: Image.asset(
                    'lib/assets/images/Google__G__logo.png', // ✅ Official Google logo
                    height: 24,
                    width: 24,
                  ),
                  label: const Text(
                    "Sign up with Google",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    side: const BorderSide(color: Colors.grey),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
