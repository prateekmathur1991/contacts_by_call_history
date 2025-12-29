import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contacts with Call History')),
      body: FutureBuilder(
        future: requestPermission(),
        builder:
            (BuildContext context, AsyncSnapshot<PermissionStatus> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData) {
                return Center(child: Text('Result: ${snapshot.data}'));
              } else {
                return const Text('No data found.');
              }
            },
      ),
    );
  }

  Future<PermissionStatus> requestPermission() async {
    return await Permission.contacts.request();
  }
}
