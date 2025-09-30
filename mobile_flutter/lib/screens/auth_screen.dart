import 'package:flutter/material.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/screens/objects_screen.dart';

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
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => ObjectsScreen(di:widget.di)), (route) => false);
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
      backgroundColor: Color.fromARGB(255, 208, 208, 208),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 10)
                  )
                ]
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTitle(),
                  _buildLoginField(),
                  const SizedBox(height: 16),
                  _buildPasswordField(),
                  const SizedBox(height: 24),
                  _buildSubmitButton(),
                ],
              )
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() => Padding(
    padding: EdgeInsets.only(bottom: 30, top: 20),
    child: Text(
      "Авторизация",
      style: TextStyle(
        fontFamily: "Inter",
        fontSize: 26,
      ),
      textAlign: TextAlign.center)
  );

  Widget _buildLoginField() => Padding(
    padding: EdgeInsets.only(top: 25),
    child: TextFormField(
      style: TextStyle(
        fontFamily: "Inter",
      ),
      controller: _loginController,
      decoration: InputDecoration(
        labelText: 'Логин',
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.black38)
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.black87,width: 2)
        )
      ),
      validator: (value) =>
      value == null || value.isEmpty ? 'Пожалуйста, введите логин' : null,
    )
  );

  Widget _buildPasswordField() => TextFormField(
    style: TextStyle(
      fontFamily: "Inter",
    ),
    controller: _passwordController,
    decoration: InputDecoration(
        labelText: 'Пароль',
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: Colors.black38)
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: Colors.black87,width: 2)
        )
    ),
    obscureText: true,
    validator: (value) =>
    value == null || value.isEmpty ? 'Пожалуйста, введите пароль' : null,
  );

  Widget _buildSubmitButton() => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromARGB(255, 180, 19, 19),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4)
        ),
        textStyle: TextStyle(
          fontSize: 20,
          fontFamily: "Inter"
        )
      ),
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
