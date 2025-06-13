import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({Key? key}) : super(key: key);

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _loading = false;
  int? userId; ////////////////////////

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('user_id');
    if (userId == null) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Utilisateur non connecté')));
      return;
    }
    final url = Uri.parse(
      'https://1c84-129-45-8-202.ngrok-free.app/users/$userId',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _nameController.text = data['name'] ?? '';
          _emailController.text = data['email'] ?? '';
          _phoneController.text = data['number']?.toString() ?? '';
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to load profile')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error loading profile')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _updateProfileField(String field, String value) async {
    setState(() => _loading = true);
    if (userId == null) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Utilisateur non connecté')));
      return;
    }
    final url = Uri.parse(
      'https://1c84-129-45-8-202.ngrok-free.app/users/$userId',
    );
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({field: value}),
      );
      if (response.statusCode == 200) {
        setState(() {
          if (field == 'name') _nameController.text = value;
          if (field == 'email') _emailController.text = value;

          if (field == 'number') _phoneController.text = value;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$field mis à jour !')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la mise à jour de $field')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur réseau')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 46, 104, 69),
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 40,
                        color: Color.fromARGB(255, 46, 104, 69),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Personal Information',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          color: Color.fromARGB(255, 46, 104, 69),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('Name'),
                    subtitle: Text(_nameController.text),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        final controller = TextEditingController(
                          text: _nameController.text,
                        );
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text('Edit Name'),
                                content: TextField(
                                  controller: controller,
                                  decoration: const InputDecoration(
                                    labelText: 'Name',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      await _updateProfileField(
                                        'name',
                                        controller.text,
                                      );
                                    },
                                    child: const Text('Save'),
                                  ),
                                ],
                              ),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: const Text('Email'),
                    subtitle: Text(_emailController.text),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        final controller = TextEditingController(
                          text: _emailController.text,
                        );
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text('Edit Email'),
                                content: TextField(
                                  controller: controller,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      await _updateProfileField(
                                        'email',
                                        controller.text,
                                      );
                                    },
                                    child: const Text('Save'),
                                  ),
                                ],
                              ),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.phone_outlined),
                    title: const Text('Phone'),
                    subtitle: Text(_phoneController.text),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        final controller = TextEditingController(
                          text: _phoneController.text,
                        );
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text('Edit Phone'),
                                content: TextField(
                                  controller: controller,
                                  decoration: const InputDecoration(
                                    labelText: 'Phone',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      await _updateProfileField(
                                        'number',
                                        controller.text,
                                      );
                                    },
                                    child: const Text('Save'),
                                  ),
                                ],
                              ),
                        );
                      },
                    ),
                  ),
                ],
              ),
    );
  }
}
