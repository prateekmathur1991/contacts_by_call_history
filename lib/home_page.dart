import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  List<Contact>? _contacts;
  bool _permissionGranted = false;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  // 1. Request contact permission
  Future _requestPermission() async {
    final status = await Permission.contacts.request();
    
    if (status.isGranted) {
      setState(() {
        _permissionGranted = true;
      });
      _fetchContacts();
    } else if (status.isDenied) {
      setState(() {
        _permissionGranted = false;
      });
    } else if (status.isPermanentlyDenied) {
      // Permission permanently denied, open app settings
      openAppSettings();
    }
  }

  // 2. Fetch contacts once permission is granted
  Future _fetchContacts() async {
    if (_permissionGranted) {
      // Get all contacts. Setting 'withProperties' to true fetches phone numbers, emails, etc.
      // Setting 'withThumbnail' to true fetches the contact image thumbnail (may be slower).
      List<Contact> contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withThumbnail: true,
      );
      setState(() {
        _contacts = contacts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_permissionGranted == false) {
      return const Scaffold(
        body: Center(
          child: Text('Contact permission denied. Please enable it in settings.'),
        ),
      );
    }
    return ListView.builder(
        itemBuilder: (context, index) {
          Contact contact = _contacts![index];
          return ListTile(
            leading: (contact.thumbnail != null &&
                    contact.thumbnail!.isNotEmpty)
                ? CircleAvatar(backgroundImage: MemoryImage(contact.thumbnail!))
                : const CircleAvatar(child: Icon(Icons.person)),
            title: Text(contact.displayName),
            subtitle: Text(contact.phones.isNotEmpty
                ? contact.phones.first.number
                : 'No phone number'),
          );
        },
        itemCount: _contacts!.length);
  }
}
