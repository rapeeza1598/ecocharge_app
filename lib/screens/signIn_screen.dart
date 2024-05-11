import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/me.dart';
import '../models/token.dart';
import 'otp.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Dio _dio = Dio();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> _login() async {
    try {
      EasyLoading.show(status: 'Logging in...');

      Response response = await _dio.post(
        'https://ecocharge.azurewebsites.net/token',
        data: {
          'username': _usernameController.text,
          'password': _passwordController.text,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'accept': 'application/json',
          },
        ),
      );
      Token token = Token.fromJson(response.data);
      final responseUser = await _dio.get(
        'https://ecocharge.azurewebsites.net/user/me',
        options: Options(headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer ${token.accessToken}',
        }),
      );
      Me me = Me.fromJson(responseUser.data);
      // Save the access token securely
      await _secureStorage.write(key: 'access_token', value: token.accessToken);
      await _secureStorage.write(key: 'id', value: me.id.toString());
      EasyLoading.dismiss();

      // Navigate to the next screen after successful login
      Navigator.pushReplacementNamed(context, '/home');
    } on DioError catch (error) {
      if (error.response!.statusCode == 400 &&
          error.response!.data['detail'] == 'User not verified') {
        EasyLoading.dismiss();
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('User not verified'),
                content:
                    const Text('Please verify your email before logging in'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EnterOTPScreen(
                                  _usernameController.text,
                                  _passwordController.text)));
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            });
      } else {
        EasyLoading.dismiss();
        EasyLoading.showError('Login failed');
      }
    }
  }

  @override
  void initState() {
    _checkToken();
    super.initState();
  }

  void _checkToken() async {
    try {
      final String? token = await _secureStorage.read(key: 'access_token');
      final String? userId = await _secureStorage.read(key: 'id');
      final response = await _dio.get(
        'https://ecocharge.azurewebsites.net/user/me',
        options: Options(headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        }),
      );
      Me me = Me.fromJson(response.data);
      if (userId == null) {
        await _secureStorage.write(key: 'id', value: me.id.toString());
      }
      if (response.statusCode == 200) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/Electric car-rafiki.png'),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: const Text('Don\'t have an account? Register here'),
            ),
            const SizedBox(
              height: 100,
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/forgot-password');
              },
              child: const Text('Forgot password?'),
            ),
          ],
        ),
      ),
    ));
  }
}
