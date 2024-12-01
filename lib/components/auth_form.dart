import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/errors/auth_exception.dart';
import 'package:shop/models/auth.dart';

enum AuthMode { login, singup }

class AuthForm extends StatefulWidget {
  const AuthForm({super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm>
    with SingleTickerProviderStateMixin {
  AuthMode _authMode = AuthMode.login;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  AnimationController? _animationController;
  Animation<double>? _opacityAnimation;
  Animation<Offset>? _slideAnimation;

  bool _isLogin() {
    return _authMode == AuthMode.login;
  }

  bool _isSignUp() {
    return _authMode == AuthMode.singup;
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 300,
      ),
    );

    _opacityAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
        CurvedAnimation(parent: _animationController!, curve: Curves.linear));
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -1.5),
      end: Offset(0.0, 0.0),
    ).animate(
        CurvedAnimation(parent: _animationController!, curve: Curves.linear));

    // _heightAnimation?.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    _animationController?.dispose();
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    _formKey.currentState?.save();
    Auth auth = Provider.of<Auth>(context, listen: false);

    try {
      if (_isLogin()) {
        await auth.login(
          _authData['email']!,
          _authData['password']!,
        );
      } else {
        await auth.signup(
          _authData['email']!,
          _authData['password']!,
        );
      }
    } on AuthException catch (e) {
      _showErrorDialog(e.toString());
    } catch (e) {
      _showErrorDialog('Ocorreu um erro inesperado!');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: Text('Ocorreu um erro'),
          content: Text(msg),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(), child: Text('Ok'))
          ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.linear,
        padding: EdgeInsets.all(16),
        height: _isLogin() ? 350 : 450,
        // height: _heightAnimation?.value.height ?? (_isLogin() ? 350 : 450),
        width: deviceSize.width * 0.8,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  label: Text('E-mail'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                onSaved: (email) => _authData['email'] = email ?? '',
                validator: (_email) {
                  final email = _email ?? '';

                  if (email.trim().isEmpty || !email.contains('@')) {
                    return 'informe um e-mail válido';
                  }

                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  label: Text('Senha'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onSaved: (password) => _authData['password'] = password ?? '',
                keyboardType: TextInputType.text,
                obscureText: true,
                controller: _passwordController,
                validator: (_password) {
                  final password = _password ?? '';

                  if (password.isEmpty || password.length < 5) {
                    return 'informe uma senha válida';
                  }

                  return null;
                },
              ),
              SizedBox(height: 10),
              AnimatedContainer(
                constraints: BoxConstraints(
                  minHeight: _isLogin() ? 0 : 60,
                  maxHeight: _isLogin() ? 0 : 120,
                ),
                duration: Duration(milliseconds: 300),
                curve: Curves.linear,
                child: FadeTransition(
                  opacity: _opacityAnimation!,
                  child: SlideTransition(
                    position: _slideAnimation!,
                    child: TextFormField(
                      decoration: InputDecoration(
                        label: Text('Confirmar Senha'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: _isLogin()
                          ? null
                          : (_password) {
                              final password = _password ?? '';
                    
                              if (password != _passwordController.text) {
                                return 'Senhas não conferem';
                              }
                    
                              return null;
                            },
                      keyboardType: TextInputType.text,
                      obscureText: true,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (_isLoading)
                CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 30,
                    ),
                  ),
                  child: Text(_isLogin() ? 'Entrar' : 'Registrar'),
                ),
              Spacer(),
              TextButton(
                  onPressed: _switchMode,
                  child: Text(_isLogin()
                      ? 'Não tenho uma conta!'
                      : 'Já tenho uma conta!'))
            ],
          ),
        ),
      ),
    );
  }

  void _switchMode() {
    setState(() {
      if (_isLogin()) {
        _authMode = AuthMode.singup;
        _animationController?.forward();
      } else {
        _authMode = AuthMode.login;
        _animationController?.reverse();
      }
    });
  }
}
