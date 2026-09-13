// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prana/providers/auth_provider.dart' as app;
import 'dart:async';
import 'dart:math';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  bool showPassword = false;
  bool isLoading = false;
  bool isParentMode = false;
  
  late AnimationController _floatingController;
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter email and password'),
          backgroundColor: Color(0xFFE67E22),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final authProvider = Provider.of<app.AuthProvider>(context, listen: false);
      
      User? user = await authProvider.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null) {
        if (isParentMode) {
          Navigator.pushReplacementNamed(context, '/parent_dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/screening');
        }
      }
    } catch (e) {
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => isLoading = true);

    try {
      final authProvider = Provider.of<app.AuthProvider>(context, listen: false);
      User? user = await authProvider.signInWithGoogle();

      if (user != null) {
        if (isParentMode) {
          Navigator.pushReplacementNamed(context, '/parent_dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/screening');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google sign in failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _handleGuestLogin() async {
    setState(() => isLoading = true);

    try {
      final authProvider = Provider.of<app.AuthProvider>(context, listen: false);
      User? user = await authProvider.signInAsGuest();

      if (user != null) {
        if (isParentMode) {
          Navigator.pushReplacementNamed(context, '/parent_dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Guest login failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5D7B88),
      body: SafeArea(
        child: Stack(
          children: [
            // Floating nature elements
            Positioned(
              top: 50,
              left: 20,
              child: AnimatedBuilder(
                animation: _floatingController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, sin(_floatingController.value * 2 * 3.14159) * 10),
                    child: Opacity(
                      opacity: 0.2,
                      child: const Icon(
                        Icons.emoji_nature,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ),
            
            Positioned(
              bottom: 100,
              right: 20,
              child: AnimatedBuilder(
                animation: _floatingController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, cos(_floatingController.value * 2 * 3.14159) * 15),
                    child: Opacity(
                      opacity: 0.15,
                      child: const Icon(
                        Icons.park,
                        size: 100,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ),
            
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    // 🧠 SIMPLE BRAIN LOGO
                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF4A6572),
                              Color(0xFF5D7B88),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            '🧠',
                            style: TextStyle(fontSize: 60),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Welcome text
                    const Text(
                      "Welcome Back!",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    const Text(
                      "Sign in to continue your mental fitness journey",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // PARENT/STUDENT TOGGLE BUTTONS
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => isParentMode = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: !isParentMode ? const Color(0xFFF9AA33) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.school,
                                      size: 20,
                                      color: !isParentMode ? Colors.white : Colors.white70,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Student',
                                      style: TextStyle(
                                        color: !isParentMode ? Colors.white : Colors.white70,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => isParentMode = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: isParentMode ? const Color(0xFFF9AA33) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.family_restroom,
                                      size: 20,
                                      color: isParentMode ? Colors.white : Colors.white70,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Parent',
                                      style: TextStyle(
                                        color: isParentMode ? Colors.white : Colors.white70,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Info card for Parent Mode
                    if (isParentMode)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Parent login gives you access to your child\'s wellness insights and daily summaries.',
                                style: TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 20),
                    
                    // Login Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 30,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Email Field
                          TextField(
                            controller: _emailController,
                            focusNode: _emailFocus,
                            decoration: InputDecoration(
                              hintText: isParentMode ? "Parent Email" : "Email",
                              prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF4A6572)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Password Field
                          TextField(
                            controller: _passwordController,
                            focusNode: _passwordFocus,
                            obscureText: !showPassword,
                            decoration: InputDecoration(
                              hintText: "Password",
                              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF4A6572)),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  showPassword ? Icons.visibility_off : Icons.visibility,
                                  color: const Color(0xFF4A6572),
                                ),
                                onPressed: () => setState(() => showPassword = !showPassword),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Demo Credentials Hint (Parent Mode)
                          if (isParentMode)
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9AA33).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Demo: parent@test.com / any password',
                                style: TextStyle(
                                  color: Color(0xFF4A6572),
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          
                          const SizedBox(height: 20),
                          
                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF9AA33),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 5,
                              ),
                              child: isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Text(
                                      isParentMode ? "LOGIN AS PARENT" : "LOGIN",
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ),
                          
                          const SizedBox(height: 15),
                          
                          // OR divider
                          const Row(
                            children: [
                              Expanded(child: Divider()),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text("OR", style: TextStyle(color: Colors.grey)),
                              ),
                              Expanded(child: Divider()),
                            ],
                          ),
                          
                          const SizedBox(height: 15),
                          
                          // Google Sign In
                          OutlinedButton.icon(
                            onPressed: isLoading ? null : _handleGoogleSignIn,
                            icon: const Icon(Icons.g_mobiledata, size: 30, color: Color(0xFF4A6572)),
                            label: const Text(
                              'Continue with Google',
                              style: TextStyle(color: Color(0xFF4A6572)),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF4A6572)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              minimumSize: const Size(double.infinity, 50),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Guest Mode
                          TextButton(
                            onPressed: isLoading ? null : _handleGuestLogin,
                            child: Text(
                              isParentMode ? "🌊 Continue as Parent Guest" : "🌊 Continue as Guest",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF4A6572),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 10),
                          
                          // Sign Up Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account? ",
                                style: TextStyle(color: Colors.grey),
                              ),
                              GestureDetector(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Sign up feature coming soon! Use Guest mode for now.'),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    color: Color(0xFF4A6572),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    const Text(
                      "Made with ❤️ in India",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Loading overlay
            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}