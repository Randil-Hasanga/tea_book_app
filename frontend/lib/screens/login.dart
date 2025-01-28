import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frontend/services/user_services.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  UserServices? _userServices;

  String? _email;
  String? _password;

  final dio = Dio();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _userServices = GetIt.instance.get<UserServices>();
    print(_userServices!.base_url);
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await dio.post(
          '${_userServices!.base_url}/user/login',
          data: {
            'email': _emailController.text,
            'password': _passwordController.text,
          },
        );

        print('user role ${response.data['user']['role']}');

        if (response.statusCode == 200) {

          _userServices!.user_id = response.data['user']['id'];
          final role =
              response.data['user']['role'];
          switch (role) {
            case 'admin':
              Navigator.popAndPushNamed(context, '/admin_dashboard');
              break;
            case 'supplier':
              Navigator.popAndPushNamed(context, '/supplier_dashboard');
              break;
            case 'collector':
              Navigator.popAndPushNamed(context, '/collector_dashboard');
              break;
            default:
              Navigator.popAndPushNamed(context, '/login');
              break;
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed: ${response.data['error']}')),
          );
        }
      } catch (e) {
        print('Error during login: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred. Please try again.')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.green,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: _loginForm(),
            ),
            if (_isLoading)
              _blurredLoadingScreen(),
          ],
        ),
      ),
    );
  }

  Widget _blurredLoadingScreen() {
    return Stack(
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Container(
            color: Colors.black.withOpacity(0.5),
          ),
        ),
        const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ],
    );
  }

  Widget _loginForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Welcome Back!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 40),
          _emailTextField(),
          const SizedBox(height: 20),
          _passwordTextField(),
          const SizedBox(height: 40),
          _loginButton(),
          const SizedBox(height: 20),
          _forgotPasswordButton(),
        ],
      ),
    );
  }

  Widget _emailTextField() {
    return TextFormField(
      controller: _emailController,
      decoration: const InputDecoration(
        labelText: 'Email',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.email),
      ),
      onSaved: (newValue) => _email = newValue,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        return null;
      },
    );
  }

  Widget _passwordTextField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: true,
      decoration: const InputDecoration(
        labelText: 'Password',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.lock),
      ),
      onSaved: (newValue) => _password = newValue,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        return null;
      },
    );
  }

  Widget _loginButton() {
    return ElevatedButton(
      onPressed: _login,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(vertical: 15),
        textStyle: const TextStyle(fontSize: 18),
      ),
      child: const Text('Login'),
    );
  }

  Widget _forgotPasswordButton() {
    return TextButton(
      onPressed: () {
        // Handle forgot password logic
      },
      child: const Text(
        'Forgot Password?',
        style: TextStyle(color: Colors.green),
      ),
    );
  }
}
