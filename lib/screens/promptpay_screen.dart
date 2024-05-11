import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/me.dart';

class PromptPayScreen extends StatefulWidget {
  final int amount;
  const PromptPayScreen(this.amount, {super.key});

  @override
  _PromptPayScreenState createState() => _PromptPayScreenState();
}

class _PromptPayScreenState extends State<PromptPayScreen> {
  File? _image;
  final picker = ImagePicker();
  // image load network
  Image? _networkImage;
  Me? me;
  final Dio _dio = Dio();
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  String? token = '';
  bool isLoading = false;

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  _getMe() async {
    token = await _secureStorage.read(key: 'access_token');
    final responseUser = await _dio.get(
      'https://ecocharge.azurewebsites.net/user/me',
      options: Options(headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      }),
    );
    setState(() {
      me = Me.fromJson(responseUser.data);
    });
  }

  @override
  void initState() {
    _networkImage =
        Image.network('https://promptpay.io/0949892974/${widget.amount}',
            loadingBuilder: (context, child, loadingProgress) {
      if (loadingProgress == null) {
        return child;
      } else {
        return const CircularProgressIndicator();
      }
    });
    _getMe();
    super.initState();
  }

  Future<void> saveImageToDeviceGallery(String imageUrl) async {
    try {
      // Fetch the image using Dio
      Response response = await Dio()
          .get(imageUrl, options: Options(responseType: ResponseType.bytes));
      // Convert the response to bytes
      Uint8List bytes = Uint8List.fromList(response.data);
      // Save the image to the device's gallery
      await ImageGallerySaver.saveImage(bytes);
      print('Image saved to gallery successfully');
    } catch (e) {
      print('Failed to save image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PromptPay QR Code',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text('PromptPay QR Code',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            // show network image if available if not show loading
            _networkImage!,
            Text(
                "จำนวนเงิน : ${widget.amount} บาท",style: const TextStyle(fontSize: 20),),
            // button to save image
            ElevatedButton(
              onPressed: () {
                saveImageToDeviceGallery(
                    'https://promptpay.io/0949892974/${widget.amount}');
                // save _networkImage to gallery
                const snackBar = SnackBar(
                  duration: Duration(seconds: 2),
                  content: Text('Image saved to gallery.'),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
              child: const Text('บันทึก QR Code ลงเครื่อง'),
            ),
            if (_image != null)
              Image.file(
                _image!,
                height: 200,
              ),
            ElevatedButton(
              onPressed: getImage,
              child: const Text('เลือกสลิปการโอนเงิน'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {
                  if (_image != null) {
                    // show confirmation dialog
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title:
                                  const Text('Are you sure you want to pay?'),
                              content: Text('Amount: ${widget.amount} Baht'),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Cancel')),
                                TextButton(
                                    onPressed: () async {
                                      EasyLoading.show(
                                          status: 'loading...',
                                          maskType: EasyLoadingMaskType.black);
                                      String image =
                                          await _ImagetoBase64(_image!);
                                      await _topup(widget.amount, image);
                                      // show success message
                                      showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                                  title: const Text(
                                                      'Payment successful.'),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator
                                                              .pushNamedAndRemoveUntil(
                                                                  context,
                                                                  '/home',
                                                                  (route) =>
                                                                      false);
                                                        },
                                                        child: const Text('OK'))
                                                  ]));
                                    },
                                    child: const Text('OK'))
                              ],
                            ));
                  } else {
                    // show error message
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                                title: const Text(
                                    'Please select an image to upload.'),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('OK'))
                                ]));
                  }
                },
                child: const Text('Pay'))
          ],
        ),
      ),
    );
  }

  _ImagetoBase64(File image) async {
    Uint8List bytes = await image.readAsBytes();
    String img64 = base64Encode(bytes);
    print(img64);
    return img64;
  }

  _topup(int amount, String image) async {
    final response = await _dio.post(
      'https://ecocharge.azurewebsites.net/top_up/',
      data: {
        'image_base64': image,
        'amount': amount,
      },
      options: Options(headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      }),
    );
    print(response.data);
    EasyLoading.dismiss();
  }
}
