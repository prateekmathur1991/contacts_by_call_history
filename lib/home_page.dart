import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:call_log/call_log.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contacts with Call History')),
      body: FutureBuilder(
        future: fetchCallLogs(),
        builder:
            (BuildContext context, AsyncSnapshot<Iterable<CallLogEntry>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: const CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                final snapshotData = snapshot.data ?? [];
                final callLogList = snapshotData.toList();
                return ListView.builder(
                  itemCount: callLogList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('${callLogList[index].name} name here'),
                      subtitle: Text(callLogList[index].formattedNumber ?? 'FORMATTED NUMBER NOT FOUND'),
                      isThreeLine: true,
                    );
                  }
                );
              } else {
                return Center(child: const Text('No data found.'));
              }
            },
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(title: const Text('Least Used Contacts')),
  //     body: FutureBuilder(
  //       future: fetchContacts(),
  //       builder:
  //           (BuildContext context, AsyncSnapshot<List<Contact>> snapshot) {
  //             if (snapshot.connectionState == ConnectionState.waiting) {
  //               return Center(child: const CircularProgressIndicator());
  //             } else if (snapshot.hasError) {
  //               return Center(child: Text('Error: ${snapshot.error}'));
  //             } else if (snapshot.hasData) {
  //               final contacts = snapshot.data ?? [];
  //               return ListView.builder(
  //                 itemCount: contacts.length,
  //                 itemBuilder: (context, index) {
  //                   return ListTile(
  //                     leading: (contacts[index].photo != null && contacts[index].photo!.isNotEmpty)
  //                         ? CircleAvatar(
  //                             backgroundImage: MemoryImage(contacts[index].photo!),
  //                           )
  //                         : const CircleAvatar(
  //                             child: Icon(Icons.person),
  //                           ),
  //                     title: Text(contacts[index].displayName),
  //                     trailing: Text(contacts[index].phones.isNotEmpty ? contacts[index].phones.first.number : ''),
  //                   );
  //                 }
  //               );
  //             } else {
  //               return Center(child: const Text('No data found.'));
  //             }
  //           },
  //     ),
  //   );
  // }

  Future<List<Contact>> fetchContacts() async {
    PermissionStatus readContactsPermissionStatus = await Permission.contacts.request();
    if (readContactsPermissionStatus.isDenied || readContactsPermissionStatus.isRestricted) {
      throw Exception('Contacts permission denied or restricted');
    }

    return await FlutterContacts.getContacts(withProperties: true, withPhoto: true);
  }

  Future<Iterable<CallLogEntry>> fetchCallLogs() async {
    return await CallLog.get();
  }
}
