import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/theme.dart';
import '../core/api_client.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  final _apiClient = ApiClient();

  Future<void> _register() async {
    // Validate fields
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field harus diisi!')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kata sandi tidak cocok!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _apiClient.dio.post('/auth/register', data: {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'role': 'owner',
      });

      if (response.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi berhasil! Silakan login.')),
        );
        Navigator.pop(context); // Back to login
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? 'Registrasi gagal. Coba lagi.';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkOlive,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.lightBeige),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              Center(
                child: Image.asset(
                  'assets/RUMA LOGO 1.png',
                  height: 120, // Adjust size as needed to match login
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 48),
              _buildTextField('Nama Lengkap', _nameController),
              const SizedBox(height: 16),
              _buildTextField('E-Mail', _emailController, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildTextField('Kata Sandi', _passwordController, obscureText: true),
              const SizedBox(height: 16),
              _buildTextField('Konfirmasi Kata Sandi', _confirmPasswordController, obscureText: true),
              const SizedBox(height: 48),
              Center(
                child: SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.lightBeige,
                      foregroundColor: AppTheme.textDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.darkOlive),
                          )
                        : const Text('Login'), // The button says "Login" in the design, keeping it consistent.
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool obscureText = false, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.lightBeige),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: const InputDecoration(),
          obscureText: obscureText,
          keyboardType: keyboardType,
        ),
      ],
    );
  }
}
