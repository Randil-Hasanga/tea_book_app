// import 'dart:ui';

// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:frontend/services/user_services.dart';
// import 'package:get_it/get_it.dart';
// import 'package:dio/dio.dart';

// class Login extends StatefulWidget {
//   const Login({super.key});

//   @override
//   State<Login> createState() => _LoginState();
// }

// class _LoginState extends State<Login> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();

//   UserServices? _userServices;

//   double? _deviceWidth, _deviceHeight;
//   TextScaler? _textScaleFactor;

//   final dio = Dio();

//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _userServices = GetIt.instance.get<UserServices>();
//     print(_userServices!.base_url);
//   }

//   Future<void> _login() async {
//     if (_formKey.currentState?.validate() ?? false) {
//       setState(() {
//         _isLoading = true;
//       });

//       try {
//         final response = await dio.post(
//           '${_userServices!.base_url}/user/login',
//           data: {
//             'email': _emailController.text,
//             'password': _passwordController.text,
//           },
//         );

//         print('user role ${response.data['user']['role']}');

//         if (response.statusCode == 200) {
//           _userServices!.user_id = response.data['user']['id'];
//           _userServices!.role = response.data['user']['role'];
//           final role = response.data['user']['role'];
//           switch (role) {
//             case 'admin':
//               Navigator.popAndPushNamed(context, '/admin_dashboard');
//               break;
//             case 'supplier':
//               Navigator.popAndPushNamed(context, '/supplier-dashboard');
//               break;
//             case 'collector':
//               Navigator.popAndPushNamed(context, '/collector_dashboard');
//               break;
//             default:
//               Navigator.popAndPushNamed(context, '/login');
//               break;
//           }
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Login failed: ${response.data['error']}')),
//           );
//         }
//       } catch (e) {
//         print('Error during login: $e');
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Please check username and password')),
//         );
//       } finally {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     _deviceHeight = MediaQuery.of(context).size.height;
//     _deviceWidth = MediaQuery.of(context).size.width;
//     _textScaleFactor = MediaQuery.textScalerOf(context);

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 SingleChildScrollView(
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(horizontal: _deviceWidth! * 0.08),
//                     child: _loginForm(),
//                   ),
//                 ),
//               ],
//             ),
//             if (_isLoading) _blurredLoadingScreen(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _blurredLoadingScreen() {
//     return Stack(
//       children: [
//         BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
//           child: Container(
//             color: Colors.black.withOpacity(0.5),
//           ),
//         ),
//         const Center(
//           child: CircularProgressIndicator(color: Colors.white),
//         ),
//       ],
//     );
//   }

//   Widget _loginForm() {
//     return Form(
//       key: _formKey, // Attach form key here
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 padding: EdgeInsets.all(0),
//                 child: Icon(
//                   Icons.eco,
//                   size: _deviceWidth! * 0.25,
//                   color: Color(0xFF13AA52),
//                 ),
//               ),
//               _titleText(),
//               SizedBox(width: _deviceWidth! * 0.1),
//             ],
//           ),
//           SizedBox(height: _deviceHeight! * 0.04),
//           _userNameTextField(),
//           SizedBox(height: _deviceHeight! * 0.03),
//           _passwordTextField(),
//           SizedBox(height: _deviceHeight! * 0.05),
//           _loginButton(),
//           SizedBox(height: _deviceHeight! * 0.02),
//           _forgotPasswordButton(),
//           SizedBox(height: _deviceHeight! * 0.05),
//         ],
//       ),
//     );
//   }

//   Widget _titleText() {
//     return Container(
//       child: Text(
//         'Login',
//         textAlign: TextAlign.center,
//         style: TextStyle(
//           fontSize: _textScaleFactor!.scale(50), // Larger font for better readability
//           fontWeight: FontWeight.bold,
//           color: Color(0xFF13AA52),
//         ),
//       ),
//     );
//   }

//   Widget _userNameTextField() {
//     return TextFormField(
//       controller: _emailController,
//       decoration: InputDecoration(
//         labelText: 'Username',
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//         prefixIcon: Icon(Icons.email, size: _deviceWidth! * 0.06),
//       ),
//       validator: (value) {
//         if (value == null || value.isEmpty) {
//           return 'Please enter your email';
//         }
//         return null;
//       },
//     );
//   }

//   Widget _passwordTextField() {
//     return TextFormField(
//       controller: _passwordController,
//       obscureText: true,
//       decoration: InputDecoration(
//         labelText: 'Tea Book Id / Collector Id',
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//         prefixIcon: Icon(Icons.lock, size: _deviceWidth! * 0.06),
//       ),
//       validator: (value) {
//         if (value == null || value.isEmpty) {
//           return 'Please enter your password';
//         }
//         return null;
//       },
//     );
//   }

//   Widget _loginButton() {
//     return ElevatedButton(
//       onPressed: _login,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: const Color(0xFF13AA52),
//         padding: EdgeInsets.symmetric(
//           vertical: _deviceHeight! * 0.02,
//         ),
//         textStyle: TextStyle(
//           fontSize: _deviceWidth! * 0.045,
//         ),
//       ),
//       child: const Text(
//         'Login',
//         style: TextStyle(color: Colors.white),
//       ),
//     );
//   }

//   Widget _forgotPasswordButton() {
//     return TextButton(
//       onPressed: () {
//         // Handle forgot password logic
//       },
//       child: const Text(
//         'Forgot Password?',
//         style: TextStyle(color: Color(0xFF13AA52)),
//       ),
//     );
//   }
// }


import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
  final dio = Dio();

  double? _deviceWidth, _deviceHeight;
  TextScaler? _textScaleFactor;

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

        print('User role: ${response.data['user']['role']}');

        if (response.statusCode == 200) {
          _userServices!.user_id = response.data['user']['id'];
          _userServices!.role = response.data['user']['role'];
          final role = response.data['user']['role'];
          switch (role) {
            case 'admin':
              Navigator.popAndPushNamed(context, '/admin_dashboard');
              break;
            case 'supplier':
              Navigator.popAndPushNamed(context, '/supplier-dashboard');
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
          const SnackBar(content: Text('Please check username and password')),
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
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _textScaleFactor = MediaQuery.textScalerOf(context);

    return Scaffold(
      resizeToAvoidBottomInset: true, // Fixes keyboard overflow
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: _deviceWidth! * 0.08),
                child: _loginForm(),
              ),
            ),
            if (_isLoading) _blurredLoadingScreen(),
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
          SizedBox(height: _deviceHeight! * 0.15,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.eco, size: _deviceWidth! * 0.25, color: Color(0xFF13AA52)),
              _titleText(),
              SizedBox(width: _deviceWidth! * 0.1),
            ],
          ),
          SizedBox(height: _deviceHeight! * 0.04),
          _userNameTextField(),
          SizedBox(height: _deviceHeight! * 0.03),
          _passwordTextField(),
          SizedBox(height: _deviceHeight! * 0.05),
          _loginButton(),
          SizedBox(height: _deviceHeight! * 0.02),
          _forgotPasswordButton(),
          SizedBox(height: _deviceHeight! * 0.05),
        ],
      ),
    );
  }

  Widget _titleText() {
    return Text(
      'Login',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: _textScaleFactor!.scale(50),
        fontWeight: FontWeight.bold,
        color: Color(0xFF13AA52),
      ),
    );
  }

  Widget _userNameTextField() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: 'Username',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        prefixIcon: Icon(Icons.email, size: _deviceWidth! * 0.06),
      ),
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
      decoration: InputDecoration(
        labelText: 'Tea Book Id / Collector Id',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        prefixIcon: Icon(Icons.lock, size: _deviceWidth! * 0.06),
      ),
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
        backgroundColor: const Color(0xFF13AA52),
        padding: EdgeInsets.symmetric(vertical: _deviceHeight! * 0.02),
        textStyle: TextStyle(fontSize: _deviceWidth! * 0.045),
      ),
      child: const Text('Login', style: TextStyle(color: Colors.white)),
    );
  }

  Widget _forgotPasswordButton() {
    return TextButton(
      onPressed: () {
        // Handle forgot password logic
      },
      child: const Text('Forgot Password?', style: TextStyle(color: Color(0xFF13AA52))),
    );
  }
}
