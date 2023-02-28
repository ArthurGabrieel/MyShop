import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/exception/auth_exception.dart';

import '../models/auth.dart';

enum AuthMode { Signup, Login }

class AuthForm extends StatefulWidget {
  const AuthForm({Key? key}) : super(key: key);

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm>
    with SingleTickerProviderStateMixin {
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  AuthMode _authMode = AuthMode.Login;
  final Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  AnimationController? _controller;
  Animation<double>? _opacityAnimation;
  Animation<Offset>? _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _opacityAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.linear,
      ),
    );

    _slideAnimation = Tween(
      begin: const Offset(0, -1.5),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.linear,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  bool _isLogin() => _authMode == AuthMode.Login;

  void _switchAuthMode() {
    setState(() {
      if (_isLogin()) {
        _authMode = AuthMode.Signup;
        _controller?.forward();
      } else {
        _authMode = AuthMode.Login;
        _controller?.reverse();
      }
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('An error occurred!'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    setState(() => _isLoading = true);

    _formKey.currentState?.save();
    Auth auth = Provider.of(context, listen: false);

    try {
      if (_isLogin()) {
        // Login
        await auth.login(
          _authData['email']!,
          _authData['password']!,
        );
      } else {
        // Registrar
        await auth.signUp(
          _authData['email']!,
          _authData['password']!,
        );
      }
    } on AuthException catch (error) {
      _showErrorDialog(error.toString());
    } catch (error) {
      _showErrorDialog('Ocorreu um erro inesperado!');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Center(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        shadowColor: Colors.grey,
        elevation: 8.0,
        child: AnimatedContainer(
            height: _isLogin() ? 310 : 400,
            width: deviceSize.width * 0.75,
            padding: const EdgeInsets.all(16.0),
            duration: const Duration(milliseconds: 250),
            child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                    onSaved: (email) => _authData['email'] = email ?? '',
                    validator: (_email) {
                      final email = _email ?? '';
                      if (email.trim().isEmpty) {
                        return 'Email is required!';
                      }
                      if (!email.contains('@')) {
                        return 'Invalid email!';
                      }
                      return null;
                    }),
                TextFormField(
                    obscureText: true,
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    onSaved: (password) =>
                        _authData['password'] = password ?? '',
                    validator: (_password) {
                      final password = _password ?? '';
                      if (password.trim().isEmpty) {
                        return 'Password is required!';
                      }
                      if (password.length < 5) {
                        return 'Password is too short!';
                      }
                      return null;
                    }),
                  if (!_isLogin())
                  AnimatedContainer(
                    constraints: BoxConstraints(
                      minHeight: _isLogin() ? 0 : 60,
                      maxHeight: _isLogin() ? 0 : 120,
                    ),
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.linear,
                    child: FadeTransition(
                      opacity: _opacityAnimation!,
                      child: SlideTransition(
                        position: _slideAnimation!,
                        child: TextFormField(
                          obscureText: true,
                          decoration:
                              const InputDecoration(labelText: 'Confirm Password'),
                          validator: (_password) {
                            final password = _password ?? '';
                            if (password != passwordController.text) {
                              return 'Passwords do not match!';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                const SizedBox(
                  height: 20,
                ),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30.0,
                            vertical: 8.0,
                          ),
                        ),
                        child: Text(
                          _isLogin() ? 'LOGIN' : 'SIGNUP',
                        ),
                      ),
                const Spacer(),
                TextButton(
                  onPressed: _switchAuthMode,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30.0,
                      vertical: 4,
                    ),
                    textStyle: const TextStyle(
                      color: Colors.deepPurple,
                    ),
                  ),
                  child: Text(
                    _isLogin() ? 'SIGNUP INSTEAD' : 'LOGIN INSTEAD',
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
