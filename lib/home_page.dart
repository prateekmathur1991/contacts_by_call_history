import 'package:contacts_by_call_history/contact_history_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:call_log/call_log.dart';
import 'package:dlibphonenumber/dlibphonenumber.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Least Used Contacts')),
      body: FutureBuilder(
        future: fetchContactsWithCallHistory(),
        builder:
            (BuildContext context, AsyncSnapshot<List<ContactHistoryWrapper>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: const CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                final contacts = snapshot.data ?? [];
                return ListView.builder(
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: (contacts[index].contact.photo != null && contacts[index].contact.photo!.isNotEmpty)
                          ? CircleAvatar(
                              backgroundImage: MemoryImage(contacts[index].contact.photo!),
                            )
                          : const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                      title: Text(contacts[index].contact.displayName),
                      trailing: Text('Calls: ${contacts[index].callCount}'),
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


  Future<List<ContactHistoryWrapper>> fetchContactsWithCallHistory() async {

    final contacts = await fetchContacts();
    final callLogs = await fetchCallLogs();

    final PhoneNumberUtil phoneUtilInstance = PhoneNumberUtil.instance;

    // Map to store call counts by phone number
    final Map<String, int> callCountMap = {};

    for (var log in callLogs) {
      try {
        final callLogNumberInstance = phoneUtilInstance.parse(log.number, 'IN');
        final number = phoneUtilInstance.format(callLogNumberInstance, PhoneNumberFormat.e164);
        callCountMap[number] = (callCountMap[number] ?? 0) + 1;
      } on NumberParseException catch (e) {
        // The dlibphonenumber package failed to parse the number
      }
    }

    // Create a list of ContactHistoryWrapper
    final List<ContactHistoryWrapper> contactHistoryList = [];

    for (var contact in contacts) {
      int totalCalls = 0;
      for (var phone in contact.phones) {
        try {
          final phoneNumberInstance = phoneUtilInstance.parse(phone.number, 'IN');
          final number = phoneUtilInstance.format(phoneNumberInstance, PhoneNumberFormat.e164);
          totalCalls += callCountMap[number] ?? 0;
        } on NumberParseException catch (e) {
          // The dlibphonenumber package failed to parse the number
        }
      }
      contactHistoryList.add(ContactHistoryWrapper(contact: contact, callCount: totalCalls));
    }

    // Sort by call count ascending (least used first)
    contactHistoryList.sort((a, b) => a.callCount.compareTo(b.callCount));

    return contactHistoryList;
  }
}
