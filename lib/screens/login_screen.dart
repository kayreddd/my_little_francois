import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import '../database/database_service.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isResettingPassword = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final user = await DatabaseService.instance.getUser(
        _usernameController.text,
        _passwordController.text,
      );

      if (user != null) {
        if (mounted) {
          // Naviguer vers l'écran d'accueil
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(user: user),
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Nom d\'utilisateur ou mot de passe incorrect';
        });
      }
    }
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      final user = await DatabaseService.instance.getUserByEmail(_emailController.text);
      
      if (user != null && user.username == _usernameController.text) {
        // TODO: Implement password reset logic
        setState(() {
          _errorMessage = 'Un email de réinitialisation a été envoyé';
          _isResettingPassword = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Utilisateur non trouvé';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isResettingPassword ? 'Réinitialiser le mot de passe' : 'Connexion'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Nom d\'utilisateur',
                  border: OutlineInputBorder(),
                ),
                validator: RequiredValidator(errorText: 'Veuillez entrer votre nom d\'utilisateur'),
              ),
              const SizedBox(height: 16),
              if (!_isResettingPassword) ...[
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Mot de passe',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: RequiredValidator(errorText: 'Veuillez entrer votre mot de passe'),
                ),
              ] else ...[
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: MultiValidator([
                    RequiredValidator(errorText: 'Veuillez entrer votre email'),
                    EmailValidator(errorText: 'Veuillez entrer un email valide'),
                  ]),
                ),
              ],
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isResettingPassword ? _resetPassword : _login,
                child: Text(_isResettingPassword ? 'Réinitialiser' : 'Se connecter'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isResettingPassword = !_isResettingPassword;
                    _errorMessage = null;
                  });
                },
                child: Text(_isResettingPassword
                    ? 'Retour à la connexion'
                    : 'Mot de passe oublié ?'),
              ),
              const SizedBox(height: 8),
              if (!_isResettingPassword)
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: const Text('Créer un compte'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
