import 'package:dtc_bus_community/controller/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:dtc_bus_community/consts/images.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LoginController _loginController = LoginController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                child: Image.asset(appLogo), // Ensure you have 'appLogo' defined in your images
                height: 77,
                width: 77,
              ),
            ),
            const SizedBox(height: 10.0),

            const Text(
              'Enter The Bus Community',
              style: TextStyle(fontSize: 20.0),
            ),
            const SizedBox(height: 16.0),

            // Email Field
            _buildTextFormField(
              controller: _emailController,
              prefixIcon: Icons.email,
              labelText: 'Email',
            ),
            const SizedBox(height: 16.0),

            // Password Field
            _buildTextFormField(
              controller: _passwordController,
              prefixIcon: Icons.lock_outline_rounded,
              labelText: 'Password',
              suffixIcon: Icons.visibility_off_outlined,
              obscureText: true,
            ),
            const SizedBox(height: 40.0),

            // Login Button
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                backgroundColor: Colors.orangeAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.0,
                ),
              )
                  : const Text('Login'),
            ),
            const SizedBox(height: 40.0),
          ],
        ),
      ),
    );
  }

  // Helper method to build the text form field
  Widget _buildTextFormField({
    required TextEditingController controller,
    required IconData prefixIcon,
    required String labelText,
    IconData? suffixIcon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(prefixIcon),
        suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
        labelText: labelText,
        border: OutlineInputBorder(),
      ),
      obscureText: obscureText,
    );
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _loginController.loginUser(email, password, context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An unexpected error occurred')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
