import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pinput/pinput.dart';

import '../models/me.dart';
import '../models/token.dart';

class EnterOTPScreen extends StatefulWidget {
  final String email;
  final String password;
  const EnterOTPScreen(this.email, this.password, {super.key});

  @override
  State<EnterOTPScreen> createState() => _EnterOTPScreenState();
}

class _EnterOTPScreenState extends State<EnterOTPScreen> {
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  final Dio _dio = Dio();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  @override
  void initState() {
    sendMail();
    super.initState();
  }

  void sendMail() {
    _dio.post(
      'https://ecocharge.azurewebsites.net/send-otp/',
      data: {
        "email": widget.email,
      },
    ).then((value) {
      log(value.toString());
    }).catchError((e) {
      log(e.toString());
    });
  }

  void getUserMe() async {
    EasyLoading.show(status: 'Logging in...');

    Response response = await _dio.post(
      'https://ecocharge.azurewebsites.net/token',
      data: {
        'username': widget.email,
        'password': widget.password,
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
  }

  @override
  Widget build(BuildContext context) {
    const focusedBorderColor = Color.fromRGBO(23, 171, 144, 1);
    const fillColor = Color.fromRGBO(243, 246, 249, 0);
    const borderColor = Colors.orange;

    final defaultPinTheme = PinTheme(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Color.fromRGBO(255, 128, 0, 1),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter OTP'),
        centerTitle: true,
      ),
      body: Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Directionality(
              // Specify direction if desired
              textDirection: TextDirection.ltr,
              child: Pinput(
                length: 6,
                controller: pinController,
                focusNode: focusNode,
                androidSmsAutofillMethod:
                    AndroidSmsAutofillMethod.smsUserConsentApi,
                listenForMultipleSmsOnAndroid: true,
                defaultPinTheme: defaultPinTheme,
                separatorBuilder: (index) => const SizedBox(width: 5),
                hapticFeedbackType: HapticFeedbackType.lightImpact,
                onCompleted: (pin) async {
                  EasyLoading.show(status: 'Validating...');
                  try {
                    final response = await _dio.post(
                      'https://ecocharge.azurewebsites.net/verify-otp/',
                      data: {
                        "email": widget.email,
                        'otp': pin,
                      },
                    );
                    if (response.statusCode == 200) {
                      getUserMe();
                      EasyLoading.showSuccess('OTP verified');
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/home', (route) => false);
                    } else {
                      EasyLoading.showError('Invalid OTP ${pin}');
                    }
                  } catch (e) {
                    log(e.toString());
                    EasyLoading.showError('Invalid OTP');
                  }
                },
                cursor: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      width: 22,
                      height: 1,
                      color: focusedBorderColor,
                    ),
                  ],
                ),
                focusedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: focusedBorderColor),
                  ),
                ),
                submittedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    color: fillColor,
                    borderRadius: BorderRadius.circular(19),
                    border: Border.all(color: focusedBorderColor),
                  ),
                ),
                errorPinTheme: defaultPinTheme.copyBorderWith(
                  border: Border.all(color: Colors.redAccent),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                focusNode.unfocus();
                formKey.currentState!.validate();
              },
              child: const Text('Resend OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
