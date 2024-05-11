import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    final Dio _dio = Dio();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter your email to reset password',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  emailController.text = value;
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text;
                if (email.isEmpty) {
                  EasyLoading.showError('Please enter your email');
                  return;
                }
                try {
                  EasyLoading.show(status: 'loading...');
                  await _dio.post(
                    'https://ecocharge.azurewebsites.net/reset_password/',
                    data: {
                      'email': email,
                    },
                  );
                  EasyLoading.dismiss();
                  EasyLoading.showSuccess(
                      'Please check your email to reset password');
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Reset Password'),
                          content: const Text(
                              'Please check your email to reset password'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                    context, '/login');
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      });
                } catch (e) {
                  EasyLoading.dismiss();
                  EasyLoading.showError('Failed to reset password');
                }
              },
              child: const Text('Reset Password'),
            ),
          ],
        ),
      ),
    );
  }
}
