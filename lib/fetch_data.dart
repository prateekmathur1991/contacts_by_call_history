import 'package:permission_handler/permission_handler.dart';
import 'package:call_log/call_log.dart';
import 'package:dlibphonenumber/dlibphonenumber.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactHistoryWrapper {

  final Contact contact;
  final int callCount;

  ContactHistoryWrapper({
    required this.contact,
    required this.callCount,
  });
}

enum SortOption {
  leastUsed('Least Used'),
  mostUsed('Most Used'),
  alphabetical('Alphabetical');

  final String label;
  const SortOption(this.label);
}

Future<List<Contact>> fetchContacts() async {
  PermissionStatus readContactsPermissionStatus = await Permission.contacts
      .request();
  if (readContactsPermissionStatus.isDenied ||
      readContactsPermissionStatus.isRestricted) {
    throw Exception('Contacts permission denied or restricted');
  }

  return await FlutterContacts.getContacts(
    withProperties: true,
    withPhoto: true,
  );
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
      final number = phoneUtilInstance.format(
        callLogNumberInstance,
        PhoneNumberFormat.e164,
      );
      callCountMap[number] = (callCountMap[number] ?? 0) + 1;
    } on NumberParseException {
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
        final number = phoneUtilInstance.format(
          phoneNumberInstance,
          PhoneNumberFormat.e164,
        );
        totalCalls += callCountMap[number] ?? 0;
      } on NumberParseException {
        // The dlibphonenumber package failed to parse the number
      }
    }
    contactHistoryList.add(
      ContactHistoryWrapper(contact: contact, callCount: totalCalls),
    );
  }

  return contactHistoryList;
}
