import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media/views/screens/login_screen.dart';

import '../../provider/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthProvider>(context);
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
                      child: const Text(
                          "Create an Account", style: TextStyle(fontSize: 24, color: Colors.white,
                      fontWeight: FontWeight.bold))),
                  const SizedBox(height: 25),
                  TextFormField(
                    controller: nameController,
                    style: TextStyle(color: Colors.white),
                    decoration:  InputDecoration(labelText: "Name",
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
                    value!.isEmpty ? "Enter name" : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: emailController,
                    style: TextStyle(color: Colors.white),
                    decoration:  InputDecoration(labelText: "Email",
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Enter email";
                      }

                      // Simple email regex
                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(value)) {
                        return "Enter a valid email";
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    style: TextStyle(color: Colors.white),
                    decoration:  InputDecoration(labelText: "Password",
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
                    value!.length < 6 ? "Min 6 chars required" : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: confirmController,
                    style: TextStyle(color: Colors.white),
                    obscureText: true,
                    decoration:
                     InputDecoration(labelText: "Confirm Password",
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
                    value != passwordController.text
                        ? "Passwords don't match"
                        : null,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: authVM.isLoading
                        ? null
                        : () {
                      if (formKey.currentState!.validate()) {
                        authVM.signUpUser(
                          name: nameController.text.trim(),
                          email: emailController.text.trim(),
                          password: passwordController.text.trim(),
                          context: context
                        );
                      }
                    },
                    child: authVM.isLoading
                        ? const CircularProgressIndicator()
                        : const Text("Sign Up"),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child:  Text("Already have an account? Login",
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
