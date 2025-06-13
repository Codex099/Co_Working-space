import 'package:flutter/material.dart';
import 'package:flutter_projet_tutore/pages/sginIn.dart';
import 'package:flutter_projet_tutore/pages_parametres/AccountSettingsScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Settings Screen UI
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String userName = 'Loading...';

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  Future<void> fetchUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('user_id');
      if (userId == null) {
        setState(() {
          userName = 'User Name';
        });
        return;
      }

      final response = await http.get(
        Uri.parse('https://1c84-129-45-8-202.ngrok-free.app/users/$userId'),
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        setState(() {
          userName = userData['name'] ?? 'User Name';
        });
      } else {
        setState(() {
          userName = 'User Name';
        });
      }
    } catch (e) {
      setState(() {
        userName = 'User Name';
      });
      print('Error fetching user name: $e');
    }
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email'); // Supprime l'email stocké

    // Redirige vers la page de login
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 46, 104, 69),
        elevation: 0,
        title: const Text(
          'Account ',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(
                  Icons.person,
                  size: 48,
                  color: Color.fromARGB(255, 46, 104, 69),
                ),
                const SizedBox(width: 16),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.grey),
            title: const Text(
              'Account',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            subtitle: const Text(
              'change email or number',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AccountSettingsScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.notifications_none, color: Colors.grey),
            title: const Text(
              'Notifications',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            subtitle: const Text(
              'Enable or disable app notifications', // Changed subtitle here
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  bool isNotificationEnabled = true;
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return AlertDialog(
                        title: const Text('Notifications'),
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Allow Notifications'),
                            Switch(
                              value: isNotificationEnabled,
                              onChanged: (value) {
                                setState(() {
                                  isNotificationEnabled = value;
                                });
                              },
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline, color: Colors.grey),
            title: const Text(
              'Help',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            subtitle: const Text(
              'Help center, contact us',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Contact Us'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                'icons/logo.png',
                                width: 24,
                                height: 24,
                              ),
                              const SizedBox(width: 8),
                              const Text('WhatsApp: 0533000001'),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Image.asset(
                                'icons/telegram.png',
                                width: 24,
                                height: 24,
                              ),
                              const SizedBox(width: 8),
                              const Text('Telegram: 0733000001'),
                            ],
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Disconnect',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Disconnect'),
                      content: const Text(
                        'Are you sure you want to disconnect?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            logout(context);
                          },
                          child: const Text(
                            'Disconnect',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
    );
  }
}
