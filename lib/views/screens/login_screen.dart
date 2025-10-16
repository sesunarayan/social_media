import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media/views/screens/signup_screen.dart';
import '../../provider/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('assets/images/ic_background.jpg'))
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Text("Welcome Back!",
                        style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold,
                        )),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: emailController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        labelText: "Email",
                      labelStyle: TextStyle(color: Colors.white),
                      errorStyle: TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(6)
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(6)
                      ),
                      errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(6)
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(6)
                      ),
                    ),
                    validator: (value) =>
                    value!.isEmpty ? "Email is required" : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    style: TextStyle(color: Colors.white),
                    decoration:  InputDecoration(
                        labelText: "Password",
                      labelStyle: TextStyle(color: Colors.white),
                      errorStyle: TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(6)
                      ),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(6)
                        ),
                      errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(6)
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(6)
                      ),
                    ),
                    validator: (value) =>
                    value!.isEmpty ? "Password is required" : null,

                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : () {
                      if (formKey.currentState!.validate()) {
                        authProvider.login(
                          email: emailController.text.trim(),
                          password: passwordController.text.trim(),
                          context: context,
                        );
                      }
                    },
                    child: authProvider.isLoading
                        ? const CircularProgressIndicator()
                        : const Text("Login"),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const SignupScreen(),
                        ),
                      );
                    },
                    child: Text("Don't have an account? Sign up",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600
                        ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
