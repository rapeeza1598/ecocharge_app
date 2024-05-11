import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/me.dart';
import 'signIn_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          UserAvatar(),
          UserInfo(),
          AccountSettings(),
        ],
      ),
    );
  }
}

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    // Replace this with your user avatar widget
    return Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(vertical: 16),
        child: CircleAvatar(
          radius: 60,
          child: Icon(Icons.person, size: 100),
        ));
  }
}

class UserInfo extends StatefulWidget {
  const UserInfo({super.key});

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  Me? me;
  final Dio _dio = Dio();
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  @override
  void initState() {
    _getMe();
    super.initState();
  }

  _getMe() async {
    final String? token = await _secureStorage.read(key: 'access_token');
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

  Widget _getImage(){
    return Image.network('https://ecocharge.azurewebsites.net/image/${me!.id}');
  }

  @override
  Widget build(BuildContext context) {
    if (me == null) {
      return const ListTile(
        leading: Icon(Icons.person),
        title: Text('Loading...'),
        subtitle: Text(''),
      );
    }
    return ListTile(
      leading: const Icon(Icons.person),
      title: Text('${me!.firstName} ${me!.lastName}'),
      subtitle: Text(me!.email),
    );
  }
}

class AccountSettings extends StatelessWidget {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  const AccountSettings({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.wallet),
          title: const Text('Wallet Balance'),
          onTap: () {
            Navigator.pushNamed(context, '/wallet');
          },
        ),
        // ListTile(
        //   leading: const Icon(Icons.settings),
        //   title: const Text('Account Settings'),
        //   onTap: () {
        //     // Handle navigation to the account settings screen.
        //   },
        // ),
        ListTile(
          leading: const Icon(Icons.security),
          title: const Text('Security & Privacy'),
          onTap: () {
            Navigator.pushNamed(context, '/security-privacy');
          },
        ),
        ListTile(
          leading: const Icon(Icons.exit_to_app),
          title: const Text('Sign Out'),
          onTap: () async {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      title: const Text('Sign Out'),
                      content: const Text('Are you sure you want to sign out?'),
                      actions: [
                        TextButton(
                            onPressed: () async {
                              await _secureStorage.deleteAll();
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const SignInScreen()));
                            },
                            child: const Text('Yes')),
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('No')),
                      ],
                    ));
          },
        ),
      ],
    );
  }
}
