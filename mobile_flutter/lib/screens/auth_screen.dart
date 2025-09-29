import 'package:flutter/material.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/screens/map.dart';

import '../auth/auth_provider.dart';
class AuthScreen extends StatefulWidget {
  final IDependencyContainer di;
  const AuthScreen({super.key, required this.di});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      await widget.di.getDependency<IAuthProvider>(IAuthProviderDIToken).login(
        _loginController.text,
        _passwordController.text,
        const Duration(seconds: 5),
      );
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (_) => MapScreen()));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Авторизация')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLoginField(),
              const SizedBox(height: 16),
              _buildPasswordField(),
              const SizedBox(height: 24),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginField() => TextFormField(
    controller: _loginController,
    decoration: const InputDecoration(
      labelText: 'Логин',
      border: OutlineInputBorder(),
    ),
    validator: (value) =>
    value == null || value.isEmpty ? 'Пожалуйста, введите логин' : null,
  );

  Widget _buildPasswordField() => TextFormField(
    controller: _passwordController,
    decoration: const InputDecoration(
      labelText: 'Пароль',
      border: OutlineInputBorder(),
    ),
    obscureText: true,
    validator: (value) =>
    value == null || value.isEmpty ? 'Пожалуйста, введите пароль' : null,
  );

  Widget _buildSubmitButton() => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: _isLoading ? null : _submit,
      child: _isLoading
          ? const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      )
          : const Text('Войти'),
    ),
  );

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
