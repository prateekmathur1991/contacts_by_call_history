import 'package:flutter_contacts/flutter_contacts.dart';

class ContactHistoryWrapper {

  final Contact contact;
  final int callCount;

  ContactHistoryWrapper({
    required this.contact,
    required this.callCount,
  });
}