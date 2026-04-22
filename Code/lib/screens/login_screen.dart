import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'signup_screen.dart';
import 'navbar_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passController = TextEditingController();

  bool isLoading = false;
  bool showPass = false;

  void login() async {
    setState(() => isLoading = true);

    var user = await AuthService.login(
      emailController.text.trim(),
      passController.text.trim(),
    );

    setState(() => isLoading = false);

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const NavBarScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login Failed ❌")),
      );
    }
  }

  void googleLogin() async {
    var user = await AuthService.signInWithGoogle();

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const NavBarScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green, Colors.teal],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Icon(Icons.eco,
                    size: 80, color: Colors.white),

                const SizedBox(height: 20),

                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    hintText: "Email",
                    filled: true,
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: passController,
                  obscureText: !showPass,
                  decoration: InputDecoration(
                    hintText: "Password",
                    filled: true,
                    suffixIcon: IconButton(
                      icon: Icon(showPass
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          showPass = !showPass;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: login,
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Login"),
                ),

                const SizedBox(height: 10),

                ElevatedButton.icon(
                  onPressed: googleLogin,
                  icon: const Icon(Icons.login),
                  label: const Text("Login with Google"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SignupScreen(),
                      ),
                    );
                  },
                  child: const Text("Create Account"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}